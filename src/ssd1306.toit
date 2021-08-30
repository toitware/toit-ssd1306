// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

/**
Driver for the SSD1306 i2C OLED display.
This is a 128x64 monochrome
  display. On the Wemos Lolin board the I2C bus is connected to pin5 (SDA) and
  pin4 (SCL), and the SSD1306 display is device 0x3c.  See
  https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf for programming info.
*/

import binary
import bitmap show *
import font show *
import gpio
import pixel_display.two_color show *
import pixel_display show *

SSD1306_SETMEMORYMODE_ ::= 0x20
SSD1306_COLUMNADDR_ ::= 0x21
SSD1306_PAGEADDR_ ::= 0x22
SSD1306_DEACTIVATE_SCROLL_ ::= 0x2e
SSD1306_SETSTARTLINE_0_ ::= 0x40
SSD1306_SETCONTRAST_ ::= 0x81
SSD1306_CHARGEPUMP_ ::= 0x8d
SSD1306_SETREMAPMODE_0_ ::= 0xa0
SSD1306_SETREMAPMODE_1_ ::= 0xa1
SSD1306_SETVERTICALSCROLLAREA_ ::= 0xa3  // Next byte is number of fixed rows.  Next after that is number of scrolling rows.
SSD1306_DISPLAYALLON_RESUME_ ::= 0xa4  // End all pixels on (use RAM for image).
SSD1306_DISPLAYALLON_ ::= 0xa5         // All pixels on.
SSD1306_NORMALDISPLAY_ ::= 0xa6
SSD1306_INVERSEDISPLAY_ ::= 0xa7
SSD1306_SETMULTIPLEX_ ::= 0xa8
SSD1306_DISPLAYOFF_ ::= 0xae
SSD1306_DISPLAYON_ ::= 0xaf
SSD1306_COMSCANINC_ ::= 0xc0
SSD1306_COMSCANDEC_ ::= 0xc8
SSD1306_SETDISPLAYOFFSET_ ::= 0xd3
SSD1306_SETDISPLAYCLOCKDIV_ ::= 0xd5
SSD1306_SETPRECHARGE_ ::= 0xd9
SSD1306_SETCOMPINS_ ::= 0xda
SSD1306_SETVCOMDETECT_ ::= 0xdb
SSD1306_NOP_ ::= 0xe3

/**
Black-and-white driver intended to be used with the Pixel-Display package
  at https://pkg.toit.io/package/pixel_display&url=github.com%2Ftoitware%2Ftoit-pixel-display&index=latest
See https://docs.toit.io/language/sdk/display
*/
class SSD1306 extends AbstractDriver:
  i2c_ := ?
  buffer_ := ByteArray WIDTH_ + 1
  command_buffer_ := ByteArray 2

  constructor .i2c_:
    init_

  static WIDTH_ ::= 128
  static HEIGHT_ ::= 64

  width/int ::= WIDTH_
  height/int ::= HEIGHT_
  flags/int ::= FLAG_2_COLOR | FLAG_PARTIAL_UPDATES

  init_:
    command_ SSD1306_DISPLAYOFF_
    command_ SSD1306_SETDISPLAYCLOCKDIV_
    command_ 0x80
    command_ SSD1306_SETMULTIPLEX_
    command_ 0x3f
    command_ SSD1306_SETDISPLAYOFFSET_
    command_ 0
    command_ SSD1306_SETSTARTLINE_0_
    command_ SSD1306_SETMEMORYMODE_
    command_ 0
    command_ SSD1306_SETREMAPMODE_1_
    command_ SSD1306_COMSCANDEC_
    command_ SSD1306_SETCOMPINS_
    command_ 0x12
    command_ SSD1306_SETCONTRAST_
    command_ 0xcf
    command_ SSD1306_SETPRECHARGE_
    command_ 0xf1
    command_ SSD1306_SETVCOMDETECT_
    command_ 0x30
    command_ SSD1306_CHARGEPUMP_
    command_ 0x14
    command_ SSD1306_DEACTIVATE_SCROLL_
    command_ SSD1306_DISPLAYALLON_RESUME_
    command_ SSD1306_INVERSEDISPLAY_
    command_ SSD1306_DISPLAYON_

  command_ byte:
    command_buffer_[0] = 0
    command_buffer_[1] = byte
    i2c_.write command_buffer_

  draw_two_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    command_ SSD1306_COLUMNADDR_
    command_ left               // Column start.
    command_ right - 1          // Column end.
    command_ SSD1306_PAGEADDR_
    command_ top >> 3           // Page start.
    command_ (bottom >> 3) - 1  // Page end.

    patch_width := right - left

    line_buffer := buffer_[0..patch_width + 1]

    line_buffer[0] = 0x40

    i := 0
    for y := top; y < bottom; y += 8:
      line_buffer.replace 1 pixels i i + patch_width
      i += patch_width
      i2c_.write line_buffer

/// I2C ID of an SSD1306 display.
SSD1306_ID ::= 0x3c
