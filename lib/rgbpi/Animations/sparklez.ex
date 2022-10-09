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
        step_time_ms: step_time_ms,
        animation_step: 0,
        timer_ref: nil
      }
      |> new_timer()

    {:ok, state}
  end

  # main animation loop
  def handle_info(:timer, state) do
    set_strip(state)
    HAL.render()

    state = new_timer(state)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  defp set_strip(%{strip: 2} = _state) do
    HAL.set_pixel(0, Enum.random(0..150), random_color())
    HAL.set_pixel(1, Enum.random(0..150), random_color())
  end

  defp set_strip(%{strip: s} = _state) do
    HAL.set_pixel(s, Enum.random(0..150), random_color())
  end

  @full_color 200..255
  @partial_color 0..64

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

  defp new_timer(state) do
    timer_ref = Process.send_after(self(), :timer, state.step_time_ms)
    %{state | timer_ref: timer_ref}
  end
end
