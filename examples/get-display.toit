// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import gpio
import i2c
import ssd1306 show *
import pixel-display show *

get-display -> PixelDisplay:
  sda := gpio.Pin 17
  scl := gpio.Pin 18
  reset := null  // or for example gpio.Pin 21 --output
  bus := i2c.Bus
    --sda=sda
    --scl=scl
    --frequency=800_000

  if reset:
    // If the reset line is floating we have to reset now before we scan.
    reset.set 0
    sleep --ms=50
    reset.set 1
    sleep --ms=50

  devices := bus.scan
  if not devices.contains Ssd1306.I2C-ADDRESS: throw "No SSD1306 display found"

  // See the constructor for more options.
  // For example, smaller displays might need '--height=32'.
  // If the display is mirrored vertically, try '--flip'.
  // If black and white are swapped, try '--inverse'.
  // If the display looks weird, play with the '--layout' option.
  driver := Ssd1306.i2c (bus.device Ssd1306.I2C-ADDRESS)

  return PixelDisplay.two-color --inverted driver
