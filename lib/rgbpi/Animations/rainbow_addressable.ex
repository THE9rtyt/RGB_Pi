defmodule RGBPi.Animations.RainbowAddressable do
  alias RGBPi.HAL

  require Logger

  use GenServer

  # animation settings
  @update_time_ms 20

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(strip) do
    state =
      %{
        strip: strip,
        animation_step: 0,
        animation_speed_ms: @update_time_ms,
        timer_ref: nil
      }
      |> new_timer()

    {:ok, state}
  end

  # main animation loop
  def handle_info(__MODULE__, %{animation_step: a} = state) when a <= 255 do
    HAL.fill_hue(state.strip, a)
    HAL.render()

    state =
      state
      |> animation_next_step()
      |> new_timer()

    {:noreply, state}
  end

  defp animation_next_step(%{animation_step: a} = state) when a < 255 do
    %{state | animation_step: a + 1}
  end

  defp animation_next_step(state), do: %{state | animation_step: 0}

  defp new_timer(state) do
    timer_ref = Process.send_after(self(), __MODULE__, state.animation_speed_ms)
    %{state | timer_ref: timer_ref}
  end
end