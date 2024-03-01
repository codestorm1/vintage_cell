defmodule NervesCell.Blinker do
  @moduledoc """
  To blink an LED
  """
  alias VintageCell.Blinker

  use GenServer
  require Logger

  @impl GenServer
  def init(state) do
    Logger.info("[Blinker] init")
    {:ok, state}
  end

  def do_blink(gpio, duration) do
    Logger.info("[Blinker] in do blink")
    Circuits.GPIO.write(gpio, 1)
    Process.send_after(self(), {:turn_off, gpio}, duration)
  end

  @impl GenServer
  def handle_cast({:blink, gpio, duration}, state) do
    Logger.info("[Blinker] in handle cast blink")
    Circuits.GPIO.write(gpio, 1)
    Process.send_after(self(), {:turn_off, gpio}, duration)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:turn_off, gpio}, state) do
    Logger.info("[Blinker] turn off #{inspect(gpio)}")
    Circuits.GPIO.write(gpio, 0)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(message, state) do
    Logger.info("[Blinker] unexpected message #{inspect(message)}")
    {:noreply, state}
  end

  # Client API
  def start_link(state) do
    Logger.info("start_link Blinker Server")
    GenServer.start_link(__MODULE__, state, name: Blinker)
  end

  def blink(gpio, duration) do
    Logger.info("[Blinker] public blink")
    GenServer.cast(__MODULE__, {:blink, gpio, duration})
  end
end
