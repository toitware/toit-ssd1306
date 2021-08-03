// Copyright (C) 2018 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

// Demo of 128x64 monochrome display.

import bitmap show *
import font show *
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display.histogram show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import .get_display

main:
  oled := get_display

  oled.background = BLACK

  histo := TwoColorHistogram 7 7 45 50 oled.landscape 0.5 WHITE
  oled.add histo

  animate oled histo oled.landscape

animate oled histogram transform:
  sans := Font.get "sans10"
  sans24b := Font [sans_24_bold.ASCII]

  lvl := 50

  beef_x := 50
  onion_x := 50

  sans_context := oled.context --landscape --font=sans --color=WHITE
  beef := oled.text sans_context beef_x 16 "Beef"
  onion := oled.text sans_context onion_x 32 "Onion"

  sans24b_context := sans_context.with --font=sans24b --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  fps := oled.text sans24b_context 126 62 "30.0"

  beef_dir := 3
  onion_dir := -3
  last := Time.monotonic_us
  previous := Time.monotonic_us
  while true:
    lvl += (random 0 5) - 2
    if lvl > 95: lvl--
    if lvl < 5: lvl++
    histogram.add lvl

    time_now := Time.monotonic_us
    fps.text = "$(%.1f 1000000.0 / (time_now - last)) "
    last = time_now

    beef_x += beef_dir
    onion_x += onion_dir
    if beef_x < 0 or onion_x < 0:
      beef_dir = -beef_dir
      onion_dir = -onion_dir
    beef.move_to beef_x 16
    onion.move_to onion_x 32
    oled.draw

    next := Time.monotonic_us
    sleep --ms=19
    previous = next
