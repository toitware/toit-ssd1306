// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

// Demo of 128x64 monochrome display.

import font_tiny.tiny as tiny_4
import font show Font
import pixel_display show *
import pixel_display.two_color show WHITE BLACK

import .get_display

main:
  oled/PixelDisplay := get_display

  animate oled

animate oled/PixelDisplay -> none:
  window-style := Style
      --background=WHITE
      --border = RoundedCornerBorder --radius=10
  sans := Style --color=WHITE --font=(Font.get "sans10") {
      "alignment": ALIGN_CENTER
  }
  tiny := Style --color=BLACK --font=(Font [tiny_4.ASCII])

  beef_x := 50
  onion_x := 20
  beef_dir := 1
  onion_dir := -1

  oled.add
      Div --x=0 --y=0 --w=128 --h=64 --background=BLACK [
          Label --x=beef-x --y=beef-x --label="Beef" --id="beef" --style=sans,
          Label --x=15 --y=34 --label="!\"#\$%&/(){}=?+`,;.:-_^~01234567890",
          Div --x=20 --y=10 --w=100 --h=35 --style=window-style [
              Label --x=15 --y=20 --label="abcdefghijklmnopqrstuvwxyz" --style=tiny --id="lc",
              Label --x=15 --y=27 --label="ABCDEFGHIJKLMNOPQRSTUVWXYZ" --style=tiny --id="uc",
          ],
      ]

  lc/Element := oled.get-element-by-id "lc"
  uc/Element := oled.get-element-by-id "uc"
  beef/Element := oled.get-element-by-id "beef"

  last := Time.monotonic_us
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
