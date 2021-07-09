// Copyright (C) 2018 Toitware ApS. All rights reserved.

// Driver for the SSD1306 i2C OLED display.  This is a 128x64 monochrome
// display. On the Wemos Lolin board the I2C bus is connected to pin5 (SDA) and
// pin4 (SCL), and the SSD1306 display is device 0x3c.  See
// https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf for programming info.

import font show *
import bitmap show *
import two_color show *
import gpio
import i2c
import pixel_display show *
import ...drivers.ssd1306
import .esp32
import ..display_driver show *
import peripherals.rpc show *

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

class SSD1306 extends DisplayDriver:
  i2c_ := ?

  constructor .i2c_:
    init_

  width -> int: return 128
  height -> int: return 64
  flags -> int: return RPC_DISPLAY_FLAG_2_COLOR | RPC_DISPLAY_FLAG_PARTIAL_UPDATES

  init_:
    command SSD1306_DISPLAYOFF_
    command SSD1306_SETDISPLAYCLOCKDIV_
    command 0x80
    command SSD1306_SETMULTIPLEX_
    command 0x3f
    command SSD1306_SETDISPLAYOFFSET_
    command 0
    command SSD1306_SETSTARTLINE_0_
    command SSD1306_SETMEMORYMODE_
    command 0
    command SSD1306_SETREMAPMODE_1_
    command SSD1306_COMSCANDEC_
    command SSD1306_SETCOMPINS_
    command 0x12
    command SSD1306_SETCONTRAST_
    command 0xcf
    command SSD1306_SETPRECHARGE_
    command 0xf1
    command SSD1306_SETVCOMDETECT_
    command 0x30
    command SSD1306_CHARGEPUMP_
    command 0x14
    command SSD1306_DEACTIVATE_SCROLL_
    command SSD1306_DISPLAYALLON_RESUME_
    command SSD1306_INVERSEDISPLAY_
    command SSD1306_DISPLAYON_

  command byte:
    bytes := ByteArray 2
    bytes[0] = 0
    bytes[1] = byte
    i2c_.write bytes

  draw_2_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    command SSD1306_COLUMNADDR_
    command left               // Column start.
    command right - 1          // Column end.
    command SSD1306_PAGEADDR_
    command top >> 3           // Page start.
    command (bottom >> 3) - 1  // Page end.

    width := right - left

    buffer := ByteArray width + 1
    buffer[0] = 0x40

    i := 0
    ((bottom - top) >> 3).repeat:
      width.repeat: buffer[it + 1] = pixels[i++]
      i2c_.write buffer: print "error printing data"

SSD1306_ID_ := 0x3c

is_ssd1306:
  i2c_bus := i2c.Bus
    --sda=gpio.Pin 5
    --scl=gpio.Pin 4
    --frequency=800_000
  devices := i2c_bus.scan
  return devices.contains SSD1306_ID_

class SSD1306Logger:
  fb_ := ?
  oled_ := ?
  lines_ := List 4
  font_ := ?

  constructor fontname:
    i2c_bus := i2c.Bus
      --sda=gpio.Pin 5
      --scl=gpio.Pin 4
      --frequency=800_000
    devices := i2c_bus.scan
    lines_.size.repeat: lines_[it] = ""
    assert: devices.contains SSD1306_ID_
    i2c := i2c_bus.device SSD1306_ID_
    oled_ = SSD1306 i2c
    fb_ = ByteArray (128 * 64) >> 3
    bitmap_zap fb_ 0
    font_ = Font.get fontname

  log gid time x:
    if x == "": x = " "
    while x != "":
      len := 0
      while len <= x.size and (font_.pixel_width (x.copy 0 len)) < 118:
        len++
      len--
      if len < 1: len = 1
      rest := x.copy len
      x = x.copy 0 len
      wrap_log_ x
      x = rest.trim --left
    bitmap_zap fb_ 0
    lines_.size.repeat:
      ssd1306_draw_text 5 15 * (it + 1) 1 0 lines_[it] font_ fb_
    oled_.putjunk fb_

  wrap_log_ x:
    (lines_.size - 1).repeat: lines_[it] = lines_[it + 1]
    lines_[lines_.size - 1] = x
