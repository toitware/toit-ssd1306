// Copyright (C) 2018 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

// Demo of 128x64 monochrome display.

import bitmap show *
import font_tiny.tiny as tiny_4
import font show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import .get_display

main:
  oled := get_display

  oled.background = BLACK

  animate oled oled.landscape

animate oled transform:
  sans := Font.get "sans10"
  tiny := Font [tiny_4.ASCII]

  window := RoundedCornerWindow 20 10 100 35 transform 10 WHITE

  in_window := window.transform

  sans_context := oled.context --landscape --font=sans --color=WHITE --alignment=TEXT_TEXTURE_ALIGN_CENTER
  beef_x := 50
  onion_x := 20
  beef := oled.text sans_context beef_x beef_x "Beef"

  tiny_context := oled.context --landscape --font=tiny --color=WHITE
  symbols := oled.text tiny_context 15 34 "!\"#\$%&/(){}=?+`,;.:-_^~01234567890"

  lc := TextTexture 15 20 in_window TEXT_TEXTURE_ALIGN_LEFT "abcdefghijklmnopqrstuvwxyz" tiny BLACK
  uc := TextTexture 15 27 in_window TEXT_TEXTURE_ALIGN_LEFT "ABCDEFGHIJKLMNOPQRSTUVWXYZ" tiny BLACK
  count_transform := (transform.translate 20 30).rotate_right
  beef_dir := 1
  onion_dir := -1
  window.add lc
  window.add uc
  last := Time.monotonic_us
  oled.add window
  while true:
    sleep --ms=50
    time_now := Time.monotonic_us
    last = time_now

    beef_x += beef_dir
    onion_x += onion_dir
    if beef_x < 0 or onion_x < 0:
      beef_dir = -beef_dir
      onion_dir = -onion_dir
    beef.move_to beef_x beef_x
    lc.move_to onion_x 20
    uc.move_to onion_x 27
    oled.draw
