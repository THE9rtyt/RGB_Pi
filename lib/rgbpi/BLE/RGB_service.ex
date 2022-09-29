defmodule RGBPi.BLE.RGBService do
  alias BlueHeron.GATT.{Characteristic, Service}
  alias RGBPi.{
    HAL,
    Animations
  }

  require Logger

  def service() do
    Service.new(%{
      id: __MODULE__,
      type: 0x99999999999999999999999999910000,
      characteristics: [
        Characteristic.new(%{
          id: {__MODULE__, :off},
          type: 0x99999999999999999999999999910001,
          properties: 0b0001000
        }),
        Characteristic.new(%{
          id: {__MODULE__, :solid},
          type: 0x99999999999999999999999999910002,
          properties: 0b0001000
        }),
        Characteristic.new(%{
          id: {__MODULE__, :hsv},
          type: 0x99999999999999999999999999910003,
          properties: 0b0001000
        }),
        Characteristic.new(%{
          id: {__MODULE__, :rainbow_a},
          type: 0x99999999999999999999999999910004,
          properties: 0b0001000
        }),
        Characteristic.new(%{
          id: {__MODULE__, :rainbow_s},
          type: 0x99999999999999999999999999910005,
          properties: 0b0001000
        })
      ]
    })
  end

  def read(_, _), do: "error"

  def write(:off, _) do
    Animations.off()
  end

  def write(:solid, color) do
    HAL.fill_strip(0, color)
    HAL.fill_strip(1, color)
    HAL.render()
  end

  def write(:hsv, color) do
    HAL.fill_hue(0, color)
    HAL.fill_hue(1, color)
    HAL.render()
  end

  def write(:rainbow_a, _) do
    Animations.rainbow()
    HAL.render()
  end

  def write(:rainbow_s, _) do
    Animations.rainbow_solid()
    HAL.render()
  end
end
