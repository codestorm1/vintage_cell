defmodule CellStateMachine do
  # Here is a better implementation of our Switch module:

  use GenStateMachine

  # Client

  def start_link() do
    GenStateMachine.start_link(CellStateMachine, {:on_hook_idle, ""})
  end

  def go_off_hook(pid) do
    GenStateMachine.cast(pid, :go_off_hook)
  end

  def get_count(pid) do
    GenStateMachine.call(pid, :get_count)
  end

  # Server (callbacks)

  def handle_event(:cast, :flip, :off, data) do
    {:next_state, :on, data + 1}
  end

  def handle_event(:cast, :flip, :on, data) do
    {:next_state, :off, data}
  end

  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, data}]}
  end

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end
end
