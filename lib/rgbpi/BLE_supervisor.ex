defmodule RGBPi.BLESupervisor do
  @moduledoc false
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {RGBPi.BLE, 1}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
