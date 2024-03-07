defmodule NervesCell.PhoneHookServer do
  use GenServer

  # shape of the state is?
  # a Map
  # client_pid: pid to send messages to, sent in to init
  # hook_state: do we even need to save this?
  # last_click_time: (remove noise)

  # Callbacks
  require Logger

  # if a click comes in faster the the value below, assume it is noise and discard it
  # yes, nanoseconds

  @noise_time_ns 50_000_000

  def start_link({client_pid, pin}) do
    Logger.info("start_link Hook Server")
    GenServer.start_link(__MODULE__, {client_pid, pin}, name: HookServer)
  end

  # a process must listen to this one
  # outgoing messasges are :onhook :offhook
  # caller just needs to handle those messages in its on genserver

  # need to start a process that sets up the interrupts on the pins

  @impl true
  @spec init({any, non_neg_integer}) ::
          {:ok, %{client_pid: any, hook_gpio: reference, last_click_time: 0}}
  def init({client_pid, pin}) do
    Logger.info("Hook server init on pin #{pin}")
    {:ok, hook_gpio} = Circuits.GPIO.open(pin, :input)

    # Circuits.GPIO.set_interrupts(hook_gpio, :both) # which mode to use? :falling?
    :ok = Circuits.GPIO.set_interrupts(hook_gpio, :both)

    {:ok, %{client_pid: client_pid, hook_gpio: hook_gpio, last_click_time: 0}}
  end

  defp gpio_value_to_hook_state(1), do: :onhook
  defp gpio_value_to_hook_state(0), do: :offhook

  # handle_info(msg, state)
  @impl true
  def handle_info(
        {:circuits_gpio, _pin, timestamp, value},
        %{last_click_time: last_click_time, client_pid: client_pid} = state
      ) do
    # Logger.info("[Hook Server] GPIO handle info was called with #{value}")

    # check how soon click came.  Skip it as noise if too soon (debounce)
    time_gap = timestamp - last_click_time

    # Logger.info(
    #   "time gap: #{inspect(time_gap)} timestamp: #{inspect(timestamp)} last_click_time: #{inspect(last_click_time)}"
    # )

    state =
      if time_gap > @noise_time_ns do
        hook_state = gpio_value_to_hook_state(value)

        # Logger.info(
        #   "[Hook Server] not noise, time since last click: #{time_gap} incoming value: #{value} Hook state: #{hook_state}"
        # )
        Logger.info("[Hook Server] value: #{value} Hook state: #{hook_state}")

        GenServer.cast(client_pid, hook_state)

        state
        |> Map.put(:hook_state, hook_state)
        |> Map.put(:last_click_time, timestamp)
      else
        # Logger.info("[Hook Server] Skipping hook noise click, time since last click: #{time_gap}")

        state
      end

    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.error("[Hook Server] catchall handle_info was called")
    Logger.info("message: #{inspect(message)}  state: #{inspect(state)}")

    {:noreply, state}
  end
end
