defmodule RGBPi.BLE do
  @moduledoc """
  BLE App
  """

  alias BlueHeron.Peripheral

  use GenStateMachine, callback_mode: :handle_event_function

  require Logger

  # called when entering all states
  @action_init [{:next_event, :internal, :init}]
  # called whenever bluetooth encounters an error, 
  # it then waits for 5 seconds before retrying the state init action
  @action_timeout [{:timeout, 5000, nil}]

  @behaviour BlueHeron.GATT.Server

  # readonly  properties:         0b0000010
  # writeonly properties:         0b0001000
  # read/write properties:        0b0001010
  # notify properties:            0b0010000
  # read/notify properties:       0b0010010
  # write/notify properties:      0b0011000
  # read/write/notify properties: 0b0011010

  alias RGBPi.BLE.{
    GenericAccessService,
    RGBService
  }

  @impl BlueHeron.GATT.Server
  def profile() do
    [
      GenericAccessService.service(),
      RGBService.service()
    ]
  end

  @impl BlueHeron.GATT.Server
  def read({mod, id}) when is_atom(mod) do
    try do
      mod.read(id)
    catch
      type, reason ->
        Logger.error(%{ble_read: type, reason: reason})
        "error"
    end
  end

  @impl BlueHeron.GATT.Server
  def write({mod, id}, value) when is_atom(mod) do
    try do
      mod.write(id, value)
    catch
      type, reason ->
        Logger.error(%{ble_write: type, reason: reason})
        "error"
    end
  end

  def disable() do
    :gen_statem.cast(__MODULE__, :disable)
  end

  def enable() do
    :gen_statem.cast(__MODULE__, :enable)
  end

  @doc false
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc false
  def start_link(args) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, args, [])
  end

  @impl GenStateMachine
  def init(_args) do
    data = %{context: nil, peripheral: nil}
    actions = @action_init
    {:ok, :reset, data, actions}
  end

  # reset state

  @impl GenStateMachine
  def handle_event(:internal, :init, :reset, data) do
    config = %BlueHeronTransportUART{
      device: "ttyS0",
      uart_opts: [speed: 115_200]
    }

    case BlueHeron.transport(config) do
      {:ok, context} ->
        Logger.info("Bluetooth loaded")
        actions = @action_init
        {:next_state, :peripheral, %{data | context: context}, actions}

      {:error, reason} ->
        Logger.error("Bluetooth failed to load: #{inspect(reason)}")
        actions = @action_timeout
        {:keep_state, data, actions}
    end
  end

  # peripheral state

  def handle_event(:internal, :init, :peripheral, data) do
    case Peripheral.start_link(data.context, __MODULE__) do
      {:ok, peripheral} ->
        Logger.info("Bluetooth peripheral started")
        data = %{data | peripheral: peripheral}
        actions = @action_init
        {:next_state, :advertise, data, actions}

      {:error, reason} ->
        Logger.error("Bluetooth failed to start peripheral: #{inspect(reason)}")
        actions = @action_timeout
        {:keep_state, data, actions}
    end
  end

  # advertise state

  def handle_event(:internal, :init, :advertise, data) do
    try do
      BlueHeron.Peripheral.set_advertising_parameters(data.peripheral, %{})

      # Advertising Data Flags: BR/EDR not supported, GeneralConnectable
      # Complete Local Name
      # Incomplete List of 128-bit Servive UUIDs
      advertising_data =
        <<0x02, 0x01, 0b00000110>> <>
          <<0x06, 0x09, "RGBPi">> <>
          <<0x11, 0x06, <<0x42A31ABD030C4D5CA8DF09686DD16CC0::little-128>>::binary>>

      BlueHeron.Peripheral.set_advertising_data(data.peripheral, advertising_data)

      BlueHeron.Peripheral.start_advertising(data.peripheral)
      Logger.info("Started advertising Bluetooth peripheral")
      :keep_state_and_data
    catch
      _, _ ->
        Logger.error("failed to start adverting bluetooth. Resetting module")
        actions = @action_init
        {:next_state, :reset, data, actions}
    end
  end

  def handle_event(:timeout, _old_state, state, data) do
    actions = @action_init
    {:next_state, state, data, actions}
  end
end
