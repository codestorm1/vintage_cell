defmodule NervesCell.CellStateMachine do
  use GenStateMachine, callback_mode: :state_functions

  @phone_number_length 10

  # making_phone_call state
  #
  def making_phone_call(:cast, :go_on_hook, _data) do
    data = ""
    dbg("get digit -> hang up, data is #{data}")
    {:next_state, :on_hook, data}
  end

  def making_phone_call(:cast, _action, _data) do
    :keep_state_and_data
  end

  # off_hook_get_digit state
  #
  def off_hook_get_digit(:cast, {:digit_dialed, digit}, data) do
    data = data <> digit
    dbg("get digit -> got a digit, data is #{data}")

    if String.length(data) == @phone_number_length do
      dbg("Make phone call to #{data}")
      {:next_state, :making_phone_call, data}
    else
      {:keep_state, data}
    end
  end

  def off_hook_get_digit(:cast, :go_on_hook, _data) do
    data = ""
    dbg("get digit -> hang up, data is #{data}")
    {:next_state, :on_hook, data}
  end

  def off_hook_get_digit(:cast, _action, _data) do
    :keep_state_and_data
  end

  # off_hook_dialtone state
  #
  def off_hook_dialtone(:cast, {:digit_dialed, digit}, data) do
    data = data <> digit
    dbg("dialtone -> got a digit, data is #{data}")
    {:next_state, :off_hook_get_digit, data}
  end

  def off_hook_dialtone(:cast, :go_on_hook, data) do
    dbg("off hook hanging up")
    {:next_state, :on_hook, data}
  end

  def off_hook_dialtone(:cast, _action, _data) do
    :keep_state_and_data
  end

  # on_hook state
  #
  def on_hook(:cast, :go_off_hook, data) do
    dbg("on hook going off hook")
    {:next_state, :off_hook_dialtone, data}
  end

  def on_hook(:cast, _action, _data) do
    :keep_state_and_data
  end
end
