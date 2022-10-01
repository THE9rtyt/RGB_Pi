defmodule RGBPi.Animations.RainbowSolid do
  alias RGBPi.HAL

  require Logger

  use GenServer

  # animation settings
  @update_time_ms 20

  def start_link(strip) do
    GenServer.start_link(__MODULE__, strip)
  end

  def init(strip) do
    state =
      %{
        strip: strip,
        animation_step: 0,
        timer_ref: nil
      }
      |> new_timer()

    {:ok, state}
  end

  # main animation loop
  def handle_info(__MODULE__, %{animation_step: a} = state) when a <= 255 do
    case state.strip do
      2 ->
        HAL.fill_hue(0, a)
        HAL.fill_hue(1, a)

      s ->
        HAL.fill_hue(s, a)
    end

    HAL.render()

    state =
      state
      |> animation_next_step()
      |> new_timer()

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  defp animation_next_step(%{animation_step: a} = state) when a < 255 do
    %{state | animation_step: a + 1}
  end

  defp animation_next_step(state), do: %{state | animation_step: 0}

  defp new_timer(state) do
    timer_ref = Process.send_after(self(), __MODULE__, @update_time_ms)
    %{state | timer_ref: timer_ref}
  end
end
