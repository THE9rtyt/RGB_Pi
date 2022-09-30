defmodule RGBPi.Status do
  @moduledoc """
  the main led strip controlling application.

  keeps track of what a strip is doing at any given time
  manages the Animations app for general strip control
  """

  alias RGBPi.{
    HAL,
    Animations
  }

  use GenStateMachine, callback_mode: [:handle_event_function, :state_enter]
  
  require Logger

  @doc false
  def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do

    {:ok, :off, state}
  end
end
