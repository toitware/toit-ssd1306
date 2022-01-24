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
import i2c
import pixel_display.two_color show *
import pixel_display show *
import spi

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
Black-and-white driver for an SSD1306 or SSD1309 connected over I2C.
Intended to be used with the Pixel-Display package
  at https://pkg.toit.io/package/pixel_display&url=github.com%2Ftoitware%2Ftoit-pixel-display&index=latest
See https://docs.toit.io/language/sdk/display
*/
class I2cSSD1306 extends SSD1306:
  constructor i2c/i2c.Device:
    super i2c

/**
Deprecated.
See $I2cSSD1306.
*/
class SSD1306 extends AbstractSSD1306_:
  i2c_ / i2c.Device

  constructor .i2c_:
    init_

  buffer_header_size_: return 1

  send_command_buffer_ buffer:
    buffer[0] = 0x00
    i2c_.write buffer

  send_data_buffer_ buffer:
    buffer[0] = 0x40
    i2c_.write buffer

/**
Black-and-white driver for an SSD1306 or SSD1309 connected over SPI.
Intended to be used with the Pixel-Display package
  at https://pkg.toit.io/package/pixel_display&url=github.com%2Ftoitware%2Ftoit-pixel-display&index=latest
See https://docs.toit.io/language/sdk/display
*/
class SpiSSD1306 extends AbstractSSD1306_:
  device_ / spi.Device

  constructor .device_ --reset/gpio.Pin?=null:
    if reset:
      reset.set 0
      sleep --ms=50
      reset.set 1
    init_

  buffer_header_size_: return 0

  send_command_buffer_ buffer:
    device_.transfer buffer --dc=0

  send_data_buffer_ buffer:
    device_.transfer buffer --dc=1

abstract class AbstractSSD1306_ extends AbstractDriver:
  buffer_ := ByteArray WIDTH_ + 1
  command_buffers_ := [ByteArray 1, ByteArray 2, ByteArray 3, ByteArray 4]

  static WIDTH_ ::= 128
  static HEIGHT_ ::= 64

  width/int ::= WIDTH_
  height/int ::= HEIGHT_
  flags/int ::= FLAG_2_COLOR | FLAG_PARTIAL_UPDATES

  abstract buffer_header_size_ -> int
  abstract send_command_buffer_ buffer -> none
  abstract send_data_buffer_ buffer -> none

  init_:
    command_ SSD1306_DISPLAYOFF_
    command_ SSD1306_SETDISPLAYCLOCKDIV_ 0x80
    command_ SSD1306_SETMULTIPLEX_ 0x3f
    command_ SSD1306_SETDISPLAYOFFSET_ 0
    command_ SSD1306_SETSTARTLINE_0_
    command_ SSD1306_SETMEMORYMODE_ 0
    command_ SSD1306_SETREMAPMODE_1_
    command_ SSD1306_COMSCANDEC_
    command_ SSD1306_SETCOMPINS_ 0x12
    command_ SSD1306_SETCONTRAST_ 0xcf
    command_ SSD1306_SETPRECHARGE_ 0xf1
    command_ SSD1306_SETVCOMDETECT_ 0x30
    command_ SSD1306_CHARGEPUMP_ 0x14
    command_ SSD1306_DEACTIVATE_SCROLL_
    command_ SSD1306_DISPLAYALLON_RESUME_
    command_ SSD1306_INVERSEDISPLAY_
    command_ SSD1306_DISPLAYON_

  command_ byte:
    i := buffer_header_size_
    buffer := command_buffers_[i]
    buffer[i] = byte
    send_command_buffer_ buffer

  command_ byte1 byte2:
    i := buffer_header_size_
    buffer := command_buffers_[i + 1]
    buffer[i] = byte1
    buffer[i + 1] = byte2
    send_command_buffer_ buffer

  command_ byte1 byte2 byte3:
    i := buffer_header_size_
    buffer := command_buffers_[i + 2]
    buffer[i] = byte1
    buffer[i + 1] = byte2
    buffer[i + 2] = byte3
    send_command_buffer_ buffer

  draw_two_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    command_ SSD1306_COLUMNADDR_
        left               // Column start.
        right - 1          // Column end.
    command_ SSD1306_PAGEADDR_
        top >> 3           // Page start.
        (bottom >> 3) - 1  // Page end.

    patch_width := right - left

    line_buffer := buffer_[0..patch_width + buffer_header_size_]

    i := 0
    for y := top; y < bottom; y += 8:
      line_buffer.replace buffer_header_size_ pixels i i + patch_width
      i += patch_width
      send_data_buffer_ line_buffer

/// I2C ID of an SSD1306 display.
SSD1306_ID ::= 0x3c
