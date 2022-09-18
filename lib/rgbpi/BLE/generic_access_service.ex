defmodule RGBPi.BLE.GenericAccessService do
  alias BlueHeron.GATT.{Characteristic, Service}

  def service() do
    Service.new(%{
      id: __MODULE__,
      type: 0x1800,
      characteristics: [
        Characteristic.new(%{
          id: {__MODULE__, :device_name},
          type: 0x2A00,
          properties: 0b0000010
        }),
        Characteristic.new(%{
          id: {__MODULE__, :appearance},
          type: 0x2A01,
          properties: 0b0000010
        })
      ]
    })
  end

  def read(:device_name), do: "RGBPi"

  def read(:appearance) do
    # The GAP service must have an appearance attribute,
    # whose value must be picked from this document: https://specificationrefs.bluetooth.com/assigned-values/Appearance%20Values.pdf
    # This is the standard apperance value for "IoT Gateway"
    <<0x0595::little-16>>
  end

  def write(_, _), do: "error"
end