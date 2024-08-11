defmodule NervesCell.BellServer do
  alias NervesCell.BellServer
  use GenServer

  require Logger

  @ring_duration 2_000

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(state) do
    Logger.info("start_link Bell Server")
    GenServer.start_link(__MODULE__, state, name: BellServer)
  end

  @impl GenServer
  def init(pin) do
    Logger.debug("Bell server init pin: #{pin}")
    {:ok, bell_gpio} = Circuits.GPIO.open(pin, :output)

    :ok = Circuits.GPIO.write(bell_gpio, 0)

    {:ok, %{bell_gpio: bell_gpio}}
  end

  @spec ring_bell() :: :ok
  def ring_bell() do
    GenStateMachine.cast(__MODULE__, :ring_bell)
  end

  @spec stop_bell() :: :ok
  def stop_bell() do
    GenStateMachine.cast(__MODULE__, :stop_bell)
  end

  @impl GenServer
  def handle_cast(
        :ring_bell,
        %{bell_gpio: bell_gpio} = state
      ) do
    Logger.info("[Bell Server] ring_bell was called")
    :ok = Circuits.GPIO.write(bell_gpio, 1)
    Process.send_after(self(), :stop_bell, @ring_duration)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(
        :stop_bell,
        %{bell_gpio: bell_gpio} = state
      ) do
    Logger.info("[Bell Server] :cast stop_bell was called")
    :ok = Circuits.GPIO.write(bell_gpio, 0)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(message, state) do
    Logger.warning("[BellHook Server] catchall handle_info was called")
    Logger.info("message: #{inspect(message)}  state: #{inspect(state)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        :stop_bell,
        %{bell_gpio: bell_gpio} = state
      ) do
    Logger.info("[Bell Server] :info stop_bell was called")
    :ok = Circuits.GPIO.write(bell_gpio, 0)
    {:noreply, state}
  end
end
