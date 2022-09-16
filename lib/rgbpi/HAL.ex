defmodule RGBPi.HAL do

  use GenServer

  require Logger

  @dma_channel 10
  @strip1_pin 12
  @strip1_length 30
  @strip2_pin 13
  @strip2_length 30

  def set_pixel(strip, pixel, "#" <> hexcolor) do
    GenServer.call(__MODULE__, {:set_pixel, strip, pixel, hexcolor})
  end

  def set_pixel(strip, pixel, {r,g,b} = _color) 
      when r in 0..255 and g in 0..255 and b in 0..255 do
    hexcolor = Base.encode16(<<0,r,g,b>>)
    GenServer.call(__MODULE__, {:set_pixel, strip, pixel, hexcolor})
  end

  def set_pixel(strip, pixel, {w,r,g,b} = _color) 
      when w in 0..255 and r in 0..255 and g in 0..255 and b in 0..255 do
    hexcolor = Base.encode16(<<w,r,g,b>>)
    GenServer.call(__MODULE__, {:set_pixel, strip, pixel, hexcolor})
  end

  def render() do
    GenServer.call(__MODULE__, :render)
  end

  # test function for sending commands calls directly to RGB
  @doc false
  def send(command) do
    GenServer.call(__MODULE__, {:send, command})
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

  def handle_call({:set_pixel, strip, pixel, color}, _from, state) do
    {:reply, send_to_port("set_pixel #{strip} #{pixel} 0x#{color}", state.port), state}
  end

  def handle_call(:render, _from, state) do
    {:reply, send_to_port("render", state.port), state}
  end

  def handle_call({:send, command}, _from, state) do
    {:reply, send_to_port(command, state.port), state}
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
    Logger.debug("RGB: sending command \"#{command}\"")
    Port.command(port , command <> "\n")
    recieve_from_port(port)
  end

  defp recieve_from_port(port) do
    receive do
      {^port, {:data, {_, 'OK'}}} -> :ok
      {^port, {:data, {_, 'OK: ' ++ payload}}} -> {:ok, to_string(payload)}
      {^port, {:data, {_, 'ERR: ' ++ payload}}} -> {:error,to_string(payload)}
      {^port, {:exit_status, status}} -> 
        Logger.error("RGB has died with exit_status: #{status}")
        raise "RGB has died with exit_status: #{status}"
    after
      500 -> {:error, "timeout waiting for RGB to reply"}
    end
  end

end
