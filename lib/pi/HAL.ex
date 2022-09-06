defmodule RGBPi.HAL do

  use GenStateMachine, callback_mode: [:handle_event_function]

  require Logger

  def send(command) do
    GenStateMachine.cast(__MODULE__, {:send, command})
  end

  def recieve() do
    GenStateMachine.call(__MODULE__, :recieve)
  end

  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    file = Application.app_dir(:rgbpi,["priv","c_src"]) |> String.to_charlist()

    port =
      Port.open({:spawn_executable, file}, 
        [{:line, 1024},
        :use_stdio, 
        :stderr_to_stdout, 
        :exit_status
      ])
  
    data = %{
      port: port
    }
  
    {:ok, :off, data}
  end

  def handle_event(:cast, {:send, command}, _state, data) do
    send_to_port(command, data.port)
    :keep_state_and_data
  end

  def handle_event(:info, {_port, {:data, {:eol, payload}}}, :off, _data) do
    Logger.debug("recieved #{payload}")
    :keep_state_and_data
  end

  def handle_event({:call, from}, :recieve, _state, data) do
    # do something?
    {:keep_state_and_data, [:reply, from, "eventual data"]}
  end
    
  defp send_to_port(command, port) do
    Port.command(port , command <> "\n")
  end
end
