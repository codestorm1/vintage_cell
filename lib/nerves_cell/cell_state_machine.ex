defmodule NervesCell.CellStateMachine do
  @moduledoc """
  The main flow and state of the cellphone is here
  """
  use GenStateMachine, callback_mode: :state_functions

  require Logger
  alias FonaModem
  @phone_number_length 10

  def start_link({state, data}) do
    Logger.info("[CellStateMachine Modem] start_link/1")
    GenStateMachine.start_link(__MODULE__, {state, data}, name: __MODULE__)
  end

  @impl GenStateMachine
  def init({state, data}) do
    Logger.info(
      "[CellStateMachine Modem] init.  pid: #{inspect(self())} init_state: #{inspect(state)} data: #{inspect(data)}"
    )

    {:ok, state, data}
  end

  # Client API
  #
  def go_off_hook() do
    Logger.info("casting to #{__MODULE__} :go_off_hook")
    GenStateMachine.cast(__MODULE__, :go_off_hook)
  end

  def go_on_hook() do
    Logger.info("casting to #{__MODULE__} :go_on_hook")
    GenStateMachine.cast(__MODULE__, :go_on_hook)
  end

  @spec digit_dialed(binary()) :: :ok
  def digit_dialed(digit) when is_binary(digit) do
    GenStateMachine.cast(__MODULE__, {:digit_dialed, digit})
  end

  # Server Callbacks
  #

  # making_phone_call state
  #
  def making_phone_call(:cast, :go_on_hook, _data) do
    data = ""
    Logger.info("get digit -> hang up, data is #{data}")
    {:next_state, :on_hook, data}
  end

  # def making_phone_call(:cast, _action, _data) do
  #   :keep_state_and_data
  # end

  # off_hook_get_digit state
  #
  def off_hook_get_digit(:cast, {:digit_dialed, digit}, data) do
    data = data <> digit
    Logger.info("get digit -> got a digit, data is #{data}")

    if String.length(data) == @phone_number_length do
      Logger.info("Make phone call to #{data}")
      result = FonaModem.play_tone("2")
      Logger.info(result)
      {:next_state, :making_phone_call, data}
    else
      {:keep_state, data}
    end
  end

  def off_hook_get_digit(:cast, :go_on_hook, _data) do
    data = ""
    Logger.info("get digit -> hang up, data is #{data}")
    {:next_state, :on_hook, data}
  end

  # def off_hook_get_digit(:cast, _action, _data) do
  #   :keep_state_and_data
  # end

  # off_hook_dialtone state
  #
  def off_hook_dialtone(:cast, {:digit_dialed, digit}, data) do
    data = data <> digit
    Logger.info("dialtone -> got a digit, data is #{data}")
    {:next_state, :off_hook_get_digit, data}
  end

  def off_hook_dialtone(:cast, :go_on_hook, data) do
    Logger.info("off hook hanging up")
    {:next_state, :on_hook, data}
  end

  # def off_hook_dialtone(:cast, _action, _data) do
  #   :keep_state_and_data
  # end

  # on_hook state
  #
  def on_hook(:cast, :go_off_hook, data) do
    Logger.info("on hook going off hook")
    {:next_state, :off_hook_dialtone, data}
  end

  # def on_hook(:cast, _action, _data) do
  #   :keep_state_and_data
  # end
end
