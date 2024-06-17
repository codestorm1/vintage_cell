defmodule NervesCell.LEDServer do
  use GenServer

  # Arrangement looks like this:
  # Y  X: 0  1  2  3  4  5  6  7
  # 0  [  0  1  2  3  4  5  6  7 ] <- Adafruit NeoPixel Stick on Channel 1 (pin 13)
  #    |-------------------------|
  # 1  |  0  1  2  3  4  5  6  7 |
  # 2  |  8  9 10 11 12 13 14 15 | <- Pimoroni Unicorn pHat on Channel 0 (pin 18)
  # 3  | 16 17 18 19 20 21 22 23 |
  # 4  | 24 25 26 27 28 29 30 31 |
  #    |-------------------------|

  require Logger

  alias Blinkchain.Point
  # alias NervesCell.Colors

  @red Blinkchain.Color.parse("#2200FF")
  @blue Blinkchain.Color.parse("#FF0022")
  @green Blinkchain.Color.parse("#22FF22")
  @black Blinkchain.Color.parse("#000000")

  defmodule State do
    defstruct [:timer, :led_colors]
  end

  def set_color(led_num, color) do
    GenServer.cast(__MODULE__, {:set_color, led_num, color})
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    Logger.info("LED Server starting")
    # Send ourselves a message to draw each frame every 33 ms,
    # which will end up being approximately 15 fps.
    {:ok, ref} = :timer.send_interval(200, :draw_frame)

    state = %State{
      timer: ref,
      led_colors: [@green, @black, @black, @black, @black, @black, @black]
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_cast(
        {:set_color, led_num, %Blinkchain.Color{} = color},
        %State{led_colors: led_colors} = state
      )
      when led_num >= 0 and led_num <= 7 and is_list(led_colors) and is_integer(led_num) do
    new_colors = List.replace_at(led_colors, led_num, color)

    state =
      state
      |> Map.put(:led_colors, new_colors)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{led_colors: led_colors} = state) when is_list(led_colors) do
    # [c1, c2, c3, c4, c5] = Enum.slice(state.colors, 0..4)
    # tail = Enum.slice(state.colors, 1..-1)

    # # Shift all pixels to the right
    # Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 7, 5)

    # # Populate the five leftmost pixels with new colors
    # Blinkchain.set_pixel(%Point{x: 0, y: 0}, c1)
    # Blinkchain.set_pixel(%Point{x: 0, y: 1}, c2)
    # Blinkchain.set_pixel(%Point{x: 0, y: 2}, c3)
    # Blinkchain.set_pixel(%Point{x: 0, y: 3}, c4)

    Enum.with_index(led_colors, fn color, index ->
      Blinkchain.set_pixel(%Point{x: index, y: 0}, color)
    end)

    Blinkchain.render()
    {:noreply, state}
  end
end
