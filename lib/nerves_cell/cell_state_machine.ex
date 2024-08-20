defmodule NervesCell.CellStateMachine do
  @moduledoc """
  The main flow and state of the cellphone is here
  """
  use GenStateMachine, callback_mode: :state_functions

  require Logger

  alias NervesCell.BellServer
  alias NervesCell.LEDServer
  alias Blinkchain.Color

  alias WaveshareModem
  @phone_number_length 10
  @state_led 5
  @color_on_hook Color.parse("#9400D3")
  @color_off_hook Color.parse("#9400D3")
  @color_incoming_ring Color.parse("#4B0082")
  @color_waiting_for_digit Color.parse("#FFFF00")
  @color_active_call Color.parse("#0000FF")
  # Color.parse("#00FF00"),
  # Color.parse("#FF7F00"),
  # Color.parse("#FF0000")

  def start_link({state, data}) do
    Logger.info("[CellStateMachine Modem] start_link/1")
    GenStateMachine.start_link(__MODULE__, {state, data}, name: __MODULE__)
  end

  @impl GenStateMachine
  def init({state, data}) do
    Logger.info(
      "[CellStateMachine Modem] init.  pid: #{inspect(self())} init_state: #{inspect(state)} data: #{inspect(data)}"
    )

    LEDServer.set_color(@state_led, @color_on_hook)
    WaveshareModem.register_ring_indicator(self())

    {:ok, state, data}
  end

  # Client API
  #
  def go_off_hook() do
    Logger.info("calling #{__MODULE__} :go_off_hook")
    GenStateMachine.call(__MODULE__, :go_off_hook)
  end

  def go_on_hook() do
    Logger.info("calling #{__MODULE__} :go_on_hook")
    GenStateMachine.call(__MODULE__, :go_on_hook)
  end

  @spec digit_dialed(binary()) :: :ok
  def digit_dialed(digit) when is_binary(digit) do
    GenStateMachine.call(__MODULE__, {:digit_dialed, digit})
  end

  # Server Callbacks
  #
  def active_voice_call({:call, from}, :go_on_hook, _data) do
    data = ""
    Logger.info("get digit -> hang up, data is #{data}")
    WaveshareModem.hang_up()
    LEDServer.set_color(@state_led, @color_on_hook)
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
    data = data <> digit
    Logger.info("get digit -> got a digit, data is #{data}")
    result = WaveshareModem.play_tone(digit)
    Logger.info(result)

    if String.length(data) == @phone_number_length do
      Logger.info("Make phone call to #{data}")
      result = WaveshareModem.make_phone_call(data)
      Logger.info(result)
      LEDServer.set_color(@state_led, @color_active_call)

      {:next_state, :active_voice_call, data, [{:reply, from, :ok}]}
    else
      {:keep_state, data, [{:reply, from, :ok}]}
    end
  end

  def off_hook_get_digit({:call, from}, :go_on_hook, _data) do
    data = ""
    Logger.info("get digit -> hang up, data is #{data}")
    LEDServer.set_color(@state_led, @color_on_hook)

    {:next_state, :on_hook, data, [{:reply, from, :ok}]}
  end

  def off_hook_get_digit({:call, from}, _action, _data) do
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def off_hook_dialtone({:call, from}, {:digit_dialed, digit}, data) do
    data = data <> digit
    Logger.info("dialtone -> got a digit, data is #{data}")
    result = WaveshareModem.play_tone(digit)
    Logger.info(result)
    LEDServer.set_color(@state_led, @color_waiting_for_digit)

    {:next_state, :off_hook_get_digit, data, [{:reply, from, :ok}]}
  end

  def off_hook_dialtone({:call, from}, :go_on_hook, data) do
    Logger.info("off hook hanging up")
    LEDServer.set_color(@state_led, @color_on_hook)

    {:next_state, :on_hook, data, [{:reply, from, :ok}]}
  end

  def off_hook_dialtone({:call, from}, _action, _data) do
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def on_hook({:call, from}, :go_off_hook, data) do
    # Would play dialtone here, not supported by SIM7600
    Logger.info("on hook going off hook")
    LEDServer.set_color(@state_led, @color_off_hook)

    {:next_state, :off_hook_dialtone, data, [{:reply, from, :ok}]}
  end

  def on_hook({:call, _from}, {:digit_dialed, "9"}, _data) do
    Logger.info("REBOOT!")
    Nerves.Runtime.reboot()
    {:next_state, :rebooting, ""}
  end

  def on_hook({:call, from}, action, _data) do
    Logger.warning("onhook CATCHALL called.  action: #{inspect(action)}")
    {:keep_state_and_data, [{:reply, from, {:error, :invalid_state_transition}}]}
  end

  def on_hook(:info, {:incoming_ring, true}, data) do
    Logger.info("RING!")
    BellServer.ring_bell()
    LEDServer.set_color(@state_led, @color_incoming_ring)

    {:next_state, :incoming_ring, data}
  end

  def on_hook(:info, {:incoming_ring, false}, _data) do
    :keep_state_and_data
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
    LEDServer.set_color(@state_led, @color_active_call)

    {:next_state, :active_voice_call, data, [{:reply, from, :ok}]}
  end

  def incoming_ring({:call, _from}, {:digit_dialed, digit}, _data) do
    Logger.info("ignoring digit dialed #{digit}.  Noise generated by bell ringing")
    :keep_state_and_data
  end
end
