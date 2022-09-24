defmodule RGBPi.RGB do
  @moduledoc """
  Animation App for RGBPi. handles all animations and renders through RGBPi.HAL
  """

  alias RGBPi.HAL

  require Logger

  use GenServer

  # animation settings
  @update_time_ms 20

  def rainbow() do
    GenServer.cast(__MODULE__, :rainbow_a)
  end

  def rainbow_solid() do
    GenServer.cast(__MODULE__, :rainbow_s)
  end

  def off() do
    GenServer.cast(__MODULE__, :off)
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    state = %{
      animation_step: 0,
      animation_speed_ms: @update_time_ms,
      timer_ref: nil
    }

    {:ok, state}
  end

  def handle_cast(:rainbow_a, state) do
    _ = clear_timer(state)
    timer_ref = Process.send_after(self(), :rainbow_a, 0)

    {:noreply, %{state | timer_ref: timer_ref}}
  end

  def handle_cast(:rainbow_s, state) do
    _ = clear_timer(state)
    timer_ref = Process.send_after(self(), :rainbow_s, 0)

    {:noreply, %{state | timer_ref: timer_ref}}
  end

  def handle_cast(:off, state) do
    _ = clear_timer(state)
    HAL.strip_off(0)
    HAL.strip_off(1)
    HAL.render()
    {:noreply, state}
  end

  def handle_info(:rainbow_a, %{animation_step: a} = state) when a <= 255 do
    HAL.fill_rainbow(0, a)
    HAL.fill_rainbow(1, a)
    HAL.render()

    timer_ref = Process.send_after(self(), :rainbow_a, state.animation_speed_ms)

    {:noreply, %{state | timer_ref: timer_ref, animation_step: a + 1}}
  end

  def handle_info(:rainbow_a, %{animation_step: a} = state) when a > 255 do
    HAL.fill_rainbow(0, 0)
    HAL.fill_rainbow(1, 0)
    HAL.render()

    timer_ref = Process.send_after(self(), :rainbow_a, state.animation_speed_ms)

    {:noreply, %{state | timer_ref: timer_ref, animation_step: 1}}
  end

  def handle_info(:rainbow_s, %{animation_step: a} = state) when a <= 255 do
    HAL.fill_hue(0, a)
    HAL.fill_hue(1, a)
    HAL.render()

    timer_ref = Process.send_after(self(), :rainbow_s, state.animation_speed_ms)

    {:noreply, %{state | timer_ref: timer_ref, animation_step: a + 1}}
  end

  def handle_info(:rainbow_s, %{animation_step: a} = state) when a > 255 do
    HAL.fill_hue(0, 0)
    HAL.fill_hue(1, 0)
    HAL.render()

    timer_ref = Process.send_after(self(), :rainbow_s, state.animation_speed_ms)

    {:noreply, %{state | timer_ref: timer_ref, animation_step: 1}}
  end

  defp clear_timer(%{timer_ref: ref} = state) when is_reference(ref) do
    Process.cancel_timer(state.timer_ref)
  end

  defp clear_timer(_), do: ""
end
