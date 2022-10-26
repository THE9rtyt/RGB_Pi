defmodule RGBPi.Status do
  @moduledoc """
  a managed led strip control enviorment
    Qol wrapper around the RGBPi animations and HAL functions.
    handle start/kill animation servers
    will render leds at the end of each command

  mostly ment to make controlling from bluetooth easier.
  """

  alias RGBPi.{
    HAL,
    Animations
  }

  use GenStateMachine, callback_mode: [:handle_event_function]

  require Logger

  # every mode option will need 2 function calls
  #   an api call
  #   a handle_event call where you actually set what you want to do
  #     make sure to always begin with :ok = kill_animation(data.pid) to kill any animations

  def solid(color) do
    GenStateMachine.cast(__MODULE__, {:solid, color})
  end

  def solid_hsv(color) do
    GenStateMachine.cast(__MODULE__, {:solid_hsv, color})
  end

  def rainbow_a(speed) do
    GenStateMachine.cast(__MODULE__, {:rainbow_a, speed})
  end

  def rainbow_s(speed) do
    GenStateMachine.cast(__MODULE__, {:rainbow_s, speed})
  end

  def sparklez(speed) do
    GenStateMachine.cast(__MODULE__, {:sparklez, speed})
  end

  def off() do
    GenStateMachine.cast(__MODULE__, :off)
  end

  @doc false
  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc false
  def init(_args) do
    data = %{
      color: nil,
      pid: nil
    }

    {:ok, :both, data}
  end

  # solid modes

  def handle_event(:cast, {:solid, color}, _state, data) do
    :ok = kill_animation(data.pid)

    HAL.fill_strip(0, color)
    HAL.fill_strip(1, color)
    HAL.render()
    {:next_state, :solid, %{data | color: color}}
  end

  def handle_event(:cast, {:solid_hsv, hsv}, _state, data) do
    :ok = kill_animation(data.pid)

    HAL.fill_hue(0, hsv)
    HAL.fill_hue(1, hsv)
    HAL.render()

    {:ok, color} = HAL.hsv_to_rgb(hsv)
    {:next_state, :solid, %{data | color: color}}
  end

  # rainbow modes

  def handle_event(:cast, {:rainbow_a, speed}, _state, data) do
    :ok = kill_animation(data.pid)

    {:ok, pid} = Animations.RainbowAddressable.start_link({2, speed})

    {:next_state, :rainbow_a, %{data | pid: pid}}
  end

  def handle_event(:cast, {:rainbow_s, speed}, _state, data) do
    :ok = kill_animation(data.pid)

    {:ok, pid} = Animations.RainbowSolid.start_link({2, speed})

    {:next_state, :rainbow_s, %{data | pid: pid}}
  end

  # sparklez mode

  def handle_event(:cast, {:sparklez, speed}, _state, data) do
    :ok = kill_animation(data.pid)

    {:ok, pid} = Animations.Sparklez.start_link({2, speed})

    {:next_state, :sparklez, %{data | pid: pid}}
  end

  # off

  def handle_event(:cast, :off, _state, data) do
    :ok = kill_animation(data.pid)

    HAL.fill_strip(0, "#00000000")
    HAL.fill_strip(1, "#00000000")
    HAL.render()
    {:next_state, :off, data}
  end

  defp kill_animation(nil), do: :ok

  defp kill_animation(pid) do
    case Process.alive?(pid) do
      true ->
        GenServer.cast(pid, :stop)

      false ->
        :ok
    end
  end
end
