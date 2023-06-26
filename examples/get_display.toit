// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import gpio
import i2c
import ssd1306 show *
import pixel_display show *

get_display -> PixelDisplay:
  scl := gpio.Pin 5
  sda := gpio.Pin 4
  bus := i2c.Bus
    --sda=sda
    --scl=scl
    --frequency=800_000

  devices := bus.scan
  if not devices.contains Ssd1306.I2C_ADDRESS: throw "No SSD1306 display found"

  // See the constructor for more options.
  // For example, smaller displays might need '--height=32'.
  // If the display is mirrored vertically, try '--flip'.
  // If black and white are swapped, try '--inverse'.
  // If the display looks weird, play with the '--layout' option.
  driver := Ssd1306.i2c (bus.device Ssd1306.I2C_ADDRESS)

  return TwoColorPixelDisplay driver
