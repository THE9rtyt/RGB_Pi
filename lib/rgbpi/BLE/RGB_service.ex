defmodule RGBPi.BLE.RGBService do
  alias BlueHeron.GATT.{Characteristic, Service}

  require Logger

  def service() do
    Service.new(%{
      id: __MODULE__,
      type: 0x99999999999999999999999999910000,
      characteristics: [
        Characteristic.new(%{
          id: {__MODULE__, :color},
          type: 0x99999999999999999999999999910001,
          properties: 0b0001000
        })
      ]
    })
  end

  def read(_, _), do: "error"

  def write(:color, color) do
    Logger.debug(color)
    RGBPi.HAL.fill_strip(0,color)
    RGBPi.HAL.fill_strip(1,color)
    RGBPi.HAL.render()
  end
end