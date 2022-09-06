defmodule Pi.RGB do

use GenStateMachine, callback_mode: [:handle_event_function]

require Logger

def hello() do
    GenStateMachine.call(__MODULE__, :hello)
end

def start_link(args) do
    GenStateMachine.start_link(__MODULE__, args, name: __MODULE__)
end

def init(_args) do

    data = %{
        reply: :rgb
    }
    
    {:ok, :off, data}
end

def handle_event({:call, from}, :hello, _state, data) do
    {:keep_state_and_data, [{:reply, from, data.reply}]}
end
    
end