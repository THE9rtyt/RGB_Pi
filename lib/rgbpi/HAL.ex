defmodule RGBPi.HAL do

  use GenServer

  require Logger

  @dma_channel 10
  @strip1_pin 12
  @strip1_length 30
  @strip2_pin 13
  @strip2_length 30

  def send(command) do
    GenServer.cast(__MODULE__, {:send, command})
  end

  def recieve() do
    GenServer.call(__MODULE__, :recieve)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    file = Application.app_dir(:rgbpi,["priv","RGB"]) |> String.to_charlist()

    args = [
      "#{@dma_channel}",
      "#{@strip1_pin}",
      "#{@strip1_length}",
      "#{@strip2_pin}",
      "#{@strip2_length}"
    ]

    port = connect_to_port(file, args)
  
    state = %{
      file: file,
      args: args,
      port: port
    }
  
    {:ok, state}
  end

  def handle_cast({:send, command}, state) do
    send_to_port(command, state.port)
    {:noreply, state}
  end

  def handle_call(:recieve, _from, state) do
    # do something?
    {:reply, state, state}
  end

  def handle_info({_port, {:data, {_, 'OK'}}}, state) do
    Logger.info("RGB: OK")
    {:noreply, state}
  end

  def handle_info({_port, {:data, {_, 'OK: ' ++ payload}}}, state) do
    Logger.info("RGB: #{payload}")
    {:noreply, state}
  end

  def handle_info({_port, {:data, {_, 'DBG: ' ++ payload}}}, state) do
    Logger.debug("RGB: #{payload}")
    {:noreply, state}
  end
  
  def handle_info({_port, {:data, {_, 'ERR: ' ++ payload}}}, state) do
    Logger.error("RGB: #{payload}")
    {:noreply, state}
  end

  def handle_info({_port, {:data, {_, _payload}}}, state) do
    {:noreply, state}
  end
  
  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.error("RGB: died with exit_status: #{status}")
    {:noreply, state}
  end
  
  defp connect_to_port(file, args) do
    Port.open({:spawn_executable, file}, [
      {:args, args},
      {:line, 1024},
      :use_stdio, 
      :stderr_to_stdout, 
      :exit_status
    ])
  end
    
  defp send_to_port(command, port) do
    Port.command(port , command <> "\n")
  end

end
