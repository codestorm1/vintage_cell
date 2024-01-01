defmodule NervesCell.KeypadDialer do
  @moduledoc """
  Documentation for NervesCell.
  """
  alias NervesCell.CellStateMachine

  require Logger
  use Keypad, row_pins: [25, 6, 12, 20], col_pins: [18, 23, 24], size: "4x3"

  @impl Keypad
  def handle_keypress("#", state) do
    Logger.info("Keypress: #")
    CellStateMachine.go_on_hook()
    state
  end

  def handle_keypress("*", state) do
    Logger.info("Keypress: *")
    CellStateMachine.go_off_hook()
    state
  end

  def handle_keypress(key, state) do
    Logger.info("Keypress: #{key}")
    CellStateMachine.digit_dialed(key)
    state
  end
end
