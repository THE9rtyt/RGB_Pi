defmodule RGBPi.Animations.Sparklez do
  alias RGBPi.HAL

  require Logger

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init({strip, step_time_ms}) do
    state =
      %{
        strip: strip,
        strip_length: nil,
        step_time_ms: step_time_ms,
        timer_ref: nil
      }
      |> get_length()
      |> new_timer()

    {:ok, state}
  end

  # main animation loop
  def handle_info(:timer, state) do
    HAL.render()
    
    state = new_timer(state)

    set_strip(state)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  defp set_strip(%{strip: 2} = state) do
    HAL.set_pixel(0, random_range(state), random_color())
    HAL.set_pixel(1, random_range(state), random_color())
  end

  defp set_strip(%{strip: s} = state) do
    HAL.set_pixel(s, random_range(state), random_color())
  end

  #minimum of 2 required
  @min_length 2
  @max_length 6

  defp random_range(%{strip_length: strip_length} = _state) do
    length = Enum.random(@min_length..@max_length)
    placement = Enum.random(0..strip_length-length)
    placement..placement+length
  end

  @full_color 200..255
  @partial_color 0..128

  defp random_color() do
    case Enum.random(0..2) do
      0 ->
        r = Enum.random(@full_color)
        g = Enum.random(@partial_color)
        b = Enum.random(@partial_color)
        {r, g, b}

      1 ->
        r = Enum.random(@partial_color)
        g = Enum.random(@full_color)
        b = Enum.random(@partial_color)
        {r, g, b}

      2 ->
        r = Enum.random(@partial_color)
        g = Enum.random(@partial_color)
        b = Enum.random(@full_color)
        {r, g, b}
    end
  end

  defp get_length(%{strip: 1} = state) do
    %{state | strip_length: Application.get_env(:rgbpi, :strip1_length)}
  end

  #we assume the strips are the same length when using mode 2
  defp get_length(%{strip: _} = state) do
    %{state | strip_length: Application.get_env(:rgbpi, :strip0_length)}
  end

  defp new_timer(state) do
    timer_ref = Process.send_after(self(), :timer, state.step_time_ms)
    %{state | timer_ref: timer_ref}
  end
end
