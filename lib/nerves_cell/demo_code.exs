defmodule NervesCell.DemoCode do
  def on_hook({:call, from}, :go_off_hook, data) do
    {:next_state, :off_hook_dialtone, data, [{:reply, from, :ok}]}
  end

  def on_hook({:call, from}, action, _data) do
    Logger.warning("onhook CATCHALL called.  action: #{inspect(action)}")
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def on_hook(:info, {:incoming_ring, true}, data) do
    BellServer.ring_bell()
    {:next_state, :incoming_ring, data}
  end

  def on_hook(:info, {:incoming_ring, false}, _data) do
    :keep_state_and_data
  end

  def active_voice_call({:call, from}, :go_on_hook, data) do
    {:next_state, :on_hook, data, [{:reply, from, data}]}
  end

  def active_voice_call({:call, from}, _action, _data) do
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def active_voice_call(:info, {:incoming_ring, _value}, _data) do
    Logger.warning("phone ringing after call was answered")
    :keep_state_and_data
  end

  def off_hook_get_digit({:call, from}, {:digit_dialed, digit}, data) do
    # if enough digits, make the call
    {:next_state, :active_voice_call, data, [{:reply, from, :ok}]}
    # else
    {:keep_state, data, [{:reply, from, :ok}]}
  end

  def off_hook_get_digit({:call, from}, :go_on_hook, data) do
    {:next_state, :on_hook, data, [{:reply, from, :ok}]}
  end

  def off_hook_get_digit({:call, from}, _action, _data) do
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def off_hook_dialtone({:call, from}, {:digit_dialed, digit}, data) do
    {:next_state, :off_hook_get_digit, data, [{:reply, from, :ok}]}
  end

  def off_hook_dialtone({:call, from}, :go_on_hook, data) do
    {:next_state, :on_hook, data, [{:reply, from, :ok}]}
  end

  def off_hook_dialtone({:call, from}, _action, _data) do
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def incoming_ring(:info, {:incoming_ring, false}, data) do
    BellServer.stop_bell()
    LEDServer.set_color(@state_led, @color_on_hook)
    {:next_state, :on_hook, data}
  end

  def incoming_ring(:info, incoming, _data) do
    Logger.warning("INFO CATCHALL incoming: #{inspect(incoming)}")
    :keep_state_and_data
  end

  def incoming_ring({:call, from}, :go_off_hook, data) do
    # answer the phone
    Logger.info("lifting hook to answer incoming call")
    :ok = WaveshareModem.answer_call()
    {:next_state, :active_voice_call, data, [{:reply, from, :ok}]}
  end

  def incoming_ring({:call, _from}, {:digit_dialed, digit}, _data) do
    Logger.info("ignoring digit dialed #{digit}.  Noise generated by bell ringing")
    :keep_state_and_data
  end
end