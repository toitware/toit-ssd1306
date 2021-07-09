// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Demo of 128x64 monochrome display.

import bitmap show *
import font.matthew_welch.tiny as tiny_4
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
  boef_x := 50
  loeg_x := 20
  boef := oled.text sans_context boef_x boef_x "Beef"

  tiny_context := oled.context --landscape --font=tiny --color=WHITE
  symbols := oled.text tiny_context 15 34 "!\"#\$%&/(){}=?+`,;.:-_^~01234567890"

  lc := TextTexture 15 20 in_window TEXT_TEXTURE_ALIGN_LEFT "abcdefghijklmnopqrstuvwxyz" tiny BLACK
  uc := TextTexture 15 27 in_window TEXT_TEXTURE_ALIGN_LEFT "ABCDEFGHIJKLMNOPQRSTUVWXYZ" tiny BLACK
  count_transform := (transform.translate 20 30).rotate_right
  boef_dir := 1
  loeg_dir := -1
  window.add lc
  window.add uc
  last := Time.monotonic_us
  oled.add window
  while true:
    sleep --ms=50
    time_now := Time.monotonic_us
    last = time_now

    boef_x += boef_dir
    loeg_x += loeg_dir
    if boef_x < 0 or loeg_x < 0:
      boef_dir = -boef_dir
      loeg_dir = -loeg_dir
    boef.move_to boef_x boef_x
    lc.move_to loeg_x 20
    uc.move_to loeg_x 27
    oled.draw
