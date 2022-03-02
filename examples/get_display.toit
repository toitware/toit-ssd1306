// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import gpio
import i2c
import ssd1306 show *
import pixel_display show *

get_display -> PixelDisplay:
  scl := gpio.Pin 4
  sda := gpio.Pin 5
  bus := i2c.Bus
    --sda=sda
    --scl=scl
    --frequency=800_000

  devices := bus.scan
  if not devices.contains SSD1306_ID: throw "No SSD1306 display found"

  driver := SSD1306.i2c (bus.device SSD1306_ID)

  return TwoColorPixelDisplay driver
