defmodule NervesCell.RotaryDialServer do
  @moduledoc """
  Keys in the state map:
    client_pid: This module will send dialed_digits to this pid
    dial_gpio: A refernce to the input dial_gpio
    click_count: The number of times the dieler has "clicked" on the gpio wire.
      This results in the dialed number, 3 clicks, dial number 3
    last_click_time: If clicks come very fast after the last click, it's probably line noise that will be discarded
    digit_timeout_timer: digit_timeout_timer
    lowest_time_til_sound: This is temporary (?), if there's noise on the line during a click, it should happen just after the last click, as the GPIO changes state

  Sends to the client:
  {:dialed_digit, character in "0".."9" or "+"}

  """
  use GenServer

  alias NervesCell.CellStateMachine

  require Logger

  # alias NervesCell.Blinker

  # if a sound comes in faster the the value below, assume it is noise and discard it
  # yes, nanoseconds

  # oscilloscope view, last noise happens around 35ms after first click on real dialer
  # bump to 40
  # 50, looks pretty good, getting pretty accurate now
  @noise_time_ns 50_000_000

  # viewed from oscilloscope, actual digit dialing time maxes around 1,200
  @digit_timeout_ms 700

  @log_fn "/data/log.csv"

  # def info(message) do
  #   Logger.info("[Dial Server]" <> inspect(message))
  # end

  def start_link({client_pid, pin}) do
    Logger.info("[Dial Server] start_link pin #{pin}")
    GenServer.start_link(__MODULE__, {client_pid, pin}, name: DialServer)
  end

  @impl GenServer
  def init({client_pid, pin}) do
    Logger.info("[Dial Server] init #{pin}")

    dial_gpio =
      case Circuits.GPIO.open(pin, :input) do
        # do nothing?
        {:ok, dial_gpio} ->
          dial_gpio

        {:error, :export_failed} ->
          Logger.error("Bad dial pin value #{pin}")
          raise "bad pin"
      end

    # digit_detected_led_pin = Application.fetch_env!(:nerves_cell, :digit_detected_led_pin)
    # noise_detected_led_pin = Application.fetch_env!(:nerves_cell, :noise_detected_led_pin)
    # click_detected_led_pin = Application.fetch_env!(:nerves_cell, :click_detected_led_pin)
    # not sure why, but :falling generates way more clicks than :rising
    :ok = Circuits.GPIO.set_interrupts(dial_gpio, :rising)

    # {:ok, digit_gpio} = Circuits.GPIO.open(digit_detected_led_pin, :output)
    # {:ok, noise_gpio} = Circuits.GPIO.open(noise_detected_led_pin, :output)
    # {:ok, click_gpio} = Circuits.GPIO.open(click_detected_led_pin, :output)

    # TODO: do this above in open, using options
    # Circuits.GPIO.write(digit_gpio, 0)
    # Circuits.GPIO.write(noise_gpio, 0)
    # Circuits.GPIO.write(click_gpio, 0)
    # Logger.info("[Dial Server] turning off digit LED")

    {:ok,
     %{
       client_pid: client_pid,
       dial_gpio: dial_gpio,
       #  digit_gpio: digit_gpio,
       #  noise_gpio: noise_gpio,
       #  click_gpio: click_gpio,
       click_count: 0,
       last_click_time: 0,
       digit_timeout_timer: nil,
       lowest_time_til_sound: 1_500_000_000
     }}
  end

  @impl GenServer
  @doc """
  When there haven't been any clicks in a while, interperet the digit to be complete and send it to the client_pid
  Example: When there have been 5 clicks in a row, and then a pause, this is interpereted as dialing a 5
  """
  def handle_info(
        :timeout_digit,
        %{
          # client_pid: client_pid,
          click_count: click_count
          # digit_gpio: digit_gpio,
          # noise_gpio: noise_gpio,
          # click_gpio: click_gpio
        } = state
      ) do
    Logger.info("[Dial Server] click count #{click_count}")
    # click_count = click_count - 1

    # This signals to the gpio that we're done listening for this digit
    # Circuits.GPIO.write(noise_gpio, 0)
    # Circuits.GPIO.write(click_gpio, 0)
    # Circuits.GPIO.write(digit_gpio, 0)

    digit =
      case click_count do
        x when x in 1..9 ->
          to_string(x)

        10 ->
          "0"

        11 ->
          "+"

        _ ->
          Logger.error("[Dial Server] Bad click_count, unable to make a digit #{click_count}")
          nil
      end

    if is_nil(digit) do
      Logger.warning("[Dial Server] invalid digit not sent")
    else
      Logger.info("[Dial Server] casting message that digit #{digit} was dialed")
      # GenServer.cast(client_pid, {:dialed_digit, digit})
      CellStateMachine.digit_dialed(digit)
    end

    state =
      state
      |> Map.put(:click_count, 0)
      |> Map.put(:last_click_time, 0)

    Logger.info("[Dial Server] returning from :timeout_digit state: #{inspect(state)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        {:circuits_gpio, _pin, timestamp, _value},
        %{
          last_click_time: 0
          # click_gpio: click_gpio,
          # noise_gpio: noise_gpio,
          # digit_gpio: digit_gpio
        } = state
      ) do
    # Logger.info("[Dial Server] GPIO handle info was called")
    # Logger.info("[Dial Server] first click of digit")

    # log("first_click", timestamp)
    # Circuits.GPIO.write(noise_gpio, 1)
    # Circuits.GPIO.write(digit_gpio, 1)
    # Circuits.GPIO.write(click_gpio, 1)

    # Blinker.blink(click_gpio, 200)

    # set this output to high, this is the start of listening for a digit

    # dont check how soon click came
    state = process_click(timestamp, state)

    Logger.info(
      "[Dial Server] handle circuits_gpio message, returning :noreply state #{inspect(state)}"
    )

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(
        {:circuits_gpio, _pin, timestamp, _value},
        %{
          last_click_time: last_click_time,
          lowest_time_til_sound: lowest_time_til_sound
          # noise_gpio: noise_gpio,
          # click_gpio: click_gpio
        } = state
      ) do
    Logger.info("[Dial Server] GPIO handle info was called")

    # check how soon click came.  Skip it as noise if too soon
    time_gap = timestamp - last_click_time

    Logger.info(
      "time gap: #{inspect(time_gap)} timestamp: #{inspect(timestamp)} last_click_time: #{inspect(last_click_time)}"
    )

    state =
      if time_gap < lowest_time_til_sound do
        Map.put(state, :lowest_time_til_sound, time_gap)
      else
        state
      end

    state =
      if time_gap > @noise_time_ns do
        log("good click", timestamp)
        # Blinker.blink(click_gpio, 200)

        process_click(timestamp, state)
      else
        log("skip noise click", timestamp)
        # Blinker.blink(noise_gpio, 10)

        Logger.info(
          "[Dial Server] skipping noise click, time since last click: #{time_gap}  lowest: #{state.lowest_time_til_sound}"
        )

        # Process.send_after(self(), :clear_noise_gpio)

        state
      end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(message, state) do
    Logger.error("[Dial Server] catchall handle_info was called")
    Logger.info("message: #{inspect(message)}  state: #{inspect(state)}")

    {:noreply, state}
  end

  # private functions

  # Count the click, reset the timer
  defp process_click(
         timestamp,
         %{
           click_count: click_count,
           digit_timeout_timer: digit_timeout_timer
           #  click_gpio: click_gpio
         } = state
       ) do
    log("got_click", timestamp)
    # Blinker.blink(click_gpio, 20)

    state
    |> Map.put(:digit_timeout_timer, reset_timer(digit_timeout_timer))
    |> Map.put(:last_click_time, timestamp)
    |> Map.put(:click_count, click_count + 1)
  end

  defp reset_timer(nil) do
    Process.send_after(self(), :timeout_digit, @digit_timeout_ms)
  end

  defp reset_timer(digit_timeout_timer) do
    Process.cancel_timer(digit_timeout_timer)
    Process.send_after(self(), :timeout_digit, @digit_timeout_ms)
  end

  defp log(event, _timestamp) do
    time = :os.system_time(:millisecond)
    File.write(@log_fn, "#{event}, #{time}")
  end
end
