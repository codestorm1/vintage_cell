defmodule NervesCell do
  @moduledoc """
  Documentation for NervesCell.
  """

  require Logger
  use Keypad, row_pins: [25, 1, 12, 20], col_pins: [18, 23, 24], size: "4x3"

  @impl Keypad
  def handle_keypress(key, %{input: ""} = state) do
    Logger.info("First Keypress: #{key}")
    # Reset input after 5 seconds
    Process.send_after(self(), :reset, 5000)
    %{state | input: key}
  end

  @impl Keypad
  def handle_keypress(key, %{input: input} = state) do
    Logger.info("Keypress: #{key}")
    %{state | input: input <> key}
  end

  def handle_info(:reset, state) do
    dbg("resetting")
    # {:noreply, %{state | input: ""}}
    {:noreply, state}
  end

  @doc """
  Hello world.

  ## Examples

      iex> NervesCell.hello
      :world

  """
  def hello do
    :world
  end
end
