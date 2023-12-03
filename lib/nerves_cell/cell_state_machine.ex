defmodule CellStateMachine do
  use GenStateMachine, callback_mode: :state_functions

  def off(:cast, :flip, data) do
    {:next_state, :on, data + 1}
  end

  def off({:call, from}, :get_count, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

  def on(:cast, :flip, data) do
    {:next_state, :off, data}
  end

  def on({:call, from}, :get_count, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end
end

# Start the server
{:ok, pid} = GenStateMachine.start_link(CellStateMachine, {:off, 0})

# This is the client
GenStateMachine.cast(pid, :flip)
# => :ok

GenStateMachine.call(pid, :get_count)
# => 1
