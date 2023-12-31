// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

// Demo of 128x64 monochrome display.

import font-tiny.tiny as tiny-4
import font show Font
import pixel-display show *
import pixel-display.two-color show WHITE BLACK

import .get-display

main:
  oled/PixelDisplay := get-display

  animate oled

animate oled/PixelDisplay -> none:
  window-style := Style
      --background=WHITE
      --border = RoundedCornerBorder --radius=10
  sans := Style --color=WHITE --font=(Font.get "sans10") {
      "alignment": ALIGN-CENTER
  }
  tiny := Style --color=BLACK --font=(Font [tiny-4.ASCII])

  beef-x := 50
  onion-x := 20
  beef-dir := 1
  onion-dir := -1

  oled.add
      Div --x=0 --y=0 --w=128 --h=64 --background=BLACK [
          Label --x=beef-x --y=beef-x --text="Beef" --id="beef" --style=sans,
          Label --x=15 --y=34 --text="!\"#\$%&/(){}=?+`,;.:-_^~01234567890" --style=sans,
          Div --x=20 --y=10 --w=100 --h=35 --style=window-style [
              Label --x=15 --y=20 --text="abcdefghijklmnopqrstuvwxyz" --style=tiny --id="lc",
              Label --x=15 --y=27 --text="ABCDEFGHIJKLMNOPQRSTUVWXYZ" --style=tiny --id="uc",
          ],
      ]

  lc/Element := oled.get-element-by-id "lc"
  uc/Element := oled.get-element-by-id "uc"
  beef/Element := oled.get-element-by-id "beef"

  last := Time.monotonic-us
  while true:
    sleep --ms=50
    time-now := Time.monotonic-us
    last = time-now

    beef-x += beef-dir
    onion-x += onion-dir
    if beef-x < 0 or onion-x < 0:
      beef-dir = -beef-dir
      onion-dir = -onion-dir
    beef.move-to beef-x beef-x
    lc.move-to onion-x 20
    uc.move-to onion-x 27
    oled.draw
