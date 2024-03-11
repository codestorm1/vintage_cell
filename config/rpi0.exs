import Config

# This maps the GPIO pin numbers to the values that the Mango Pi is expecting.
# On a Raspberry Pi, the value passed in to Circuits.GPIO is always the same as the GPIO number (for GPIO23, pass 23).
# However, on a Mango Pi, the key values in this map are what is needed (pass in 33 to get GPIO23)
# TODO: make gpio_pins into an identity function/accessor or something

gpio_pins = %{
  1 => 1,
  2 => 2,
  3 => 3,
  4 => 4,
  5 => 5,
  6 => 6,
  7 => 7,
  12 => 12,
  13 => 13,
  14 => 14,
  15 => 15,
  16 => 16,
  17 => 17,
  18 => 18,
  19 => 19,
  20 => 20,
  21 => 21,
  22 => 22,
  23 => 23,
  24 => 24,
  25 => 25,
  26 => 26,
  27 => 27
}

config :fona_modem,
  uart_name: "ttyAMA0"

# these are inputs for phone hook and rotary dial clicks

config :fona_modem,
  # hook_gpio_pin: gpio_pins[25],
  # dial_gpio_pin: gpio_pins[23],
  # other_input_pin: gpio_pins[23],
  # these are output pins for LEDs for debugging
  bell_ringer_pin: gpio_pins[18],
  digit_detected_pin: gpio_pins[6],
  click_detected_pin: gpio_pins[16],
  noise_detected_pin: gpio_pins[26],
  # FONA pins
  key_pin: gpio_pins[5],
  ring_indicator_pin: gpio_pins[21],
  power_status_pin: gpio_pins[27],
  network_status_pin: gpio_pins[17],
  # not hooked up yet, for hanging up phone
  dtr_pin: 0
