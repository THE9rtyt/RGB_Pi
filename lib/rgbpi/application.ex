defmodule RGBPi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RGBPi.Supervisor]

    children =
      [
        {RGBPi.HAL, 1},
        {RGBPi.BLESupervisor, 2}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target) do
    []
  end

  def target() do
    Application.get_env(:rgbpi, :target)
  end
end
