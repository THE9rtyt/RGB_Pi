defmodule RGBPi.BLE.RGBService do
  alias BlueHeron.GATT.{Characteristic, Service}
  alias RGBPi.Status

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
          id: {__MODULE__, :solid_hsv},
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
    Status.off()
  end

  def write(:solid, color) do
    Status.solid(color)
  end

  def write(:solid_hsv, color) do
    Status.solid_hsv(color)
  end

  def write(:rainbow_a, _) do
    Status.rainbow_a()
  end

  def write(:rainbow_s, _) do
    Status.rainbow_s()
  end
end
