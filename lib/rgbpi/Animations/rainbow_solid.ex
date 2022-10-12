defmodule RGBPi.Animations.RainbowSolid do
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
        animation_step: 0,
        step_time_ms: step_time_ms,
        timer_ref: nil
      }
      |> new_timer()

    {:ok, state}
  end

  # main animation loop
  def handle_info(:timer, state) do
    HAL.render()

    state =
      state
      |> animation_next_step()
      |> new_timer()

    set_strip(state)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  defp set_strip(%{animation_step: a, strip: 2} = _state) do
    HAL.fill_hue(0, a)
    HAL.fill_hue(1, a)
  end

  defp set_strip(%{animation_step: a, strip: s} = _state) do
    HAL.fill_hue(s, a)
  end

  defp animation_next_step(%{animation_step: a} = state) when a < 255 do
    %{state | animation_step: a + 1}
  end

  defp animation_next_step(state), do: %{state | animation_step: 0}

  defp new_timer(state) do
    timer_ref = Process.send_after(self(), :timer, state.step_time_ms)
    %{state | timer_ref: timer_ref}
  end
end
