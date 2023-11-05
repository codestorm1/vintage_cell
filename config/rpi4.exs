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
  uart_name: "ttyAMA0",
  hook_gpio_pin: gpio_pins[25],
  dial_gpio_pin: gpio_pins[1],
  digit_detected_pin: gpio_pins[24],
  click_detected_pin: gpio_pins[16],
  noise_detected_pin: gpio_pins[20],
  key_pin: gpio_pins[26],
  dtr_pin: gpio_pins[27]
