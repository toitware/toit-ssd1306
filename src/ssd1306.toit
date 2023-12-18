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
import pixel-display.two-color show *
import pixel-display show *
import spi

SSD1306-SETMEMORYMODE_ ::= 0x20
SSD1306-COLUMNADDR_ ::= 0x21
SSD1306-PAGEADDR_ ::= 0x22
SSD1306-DEACTIVATE-SCROLL_ ::= 0x2e
SSD1306-SETSTARTLINE-0_ ::= 0x40
SSD1306-SETCONTRAST_ ::= 0x81
SSD1306-CHARGEPUMP_ ::= 0x8d
SSD1306-SETREMAPMODE-0_ ::= 0xa0
SSD1306-SETREMAPMODE-1_ ::= 0xa1
SSD1306-SETVERTICALSCROLLAREA_ ::= 0xa3  // Next byte is number of fixed rows.  Next after that is number of scrolling rows.
SSD1306-DISPLAYALLON-RESUME_ ::= 0xa4  // End all pixels on (use RAM for image).
SSD1306-DISPLAYALLON_ ::= 0xa5         // All pixels on.
SSD1306-NORMALDISPLAY_ ::= 0xa6
SSD1306-INVERSEDISPLAY_ ::= 0xa7
SSD1306-SETMULTIPLEX_ ::= 0xa8
SSD1306-DISPLAYOFF_ ::= 0xae
SSD1306-DISPLAYON_ ::= 0xaf
SSD1306-COMSCANINC_ ::= 0xc0
SSD1306-COMSCANDEC_ ::= 0xc8
SSD1306-SETDISPLAYOFFSET_ ::= 0xd3
SSD1306-SETDISPLAYCLOCKDIV_ ::= 0xd5
SSD1306-SETPRECHARGE_ ::= 0xd9
SSD1306-SETCOMPINS_ ::= 0xda
SSD1306-SETVCOMDETECT_ ::= 0xdb
SSD1306-NOP_ ::= 0xe3

/**
Deprecated. Use the $Ssd1306.i2c constructor.
*/
class I2cSSD1306 extends I2cSsd1306_:
  constructor i2c/i2c.Device:
    super i2c --height=64 --no-flip --inverse --layout=Ssd1306.LAYOUT-ALTERNATED

/**
Deprecated. Use the $Ssd1306.spi constructor.
*/
class SpiSSD1306 extends SpiSsd1306_:
  constructor device/spi.Device --reset/gpio.Pin?=null:
    super device --reset=reset --height=64 --no-flip --inverse --layout=Ssd1306.LAYOUT-ALTERNATED

/**
Black-and-white driver for an SSD1306 or SSD1309 connected I2C.
*/
class I2cSsd1306_ extends SSD1306:
  i2c_ / i2c.Device

  constructor .i2c_ --reset/gpio.Pin?=null --height/int --flip/bool --inverse/bool --layout/int:
    super.from-subclass_ --reset=reset --height=height --flip=flip --inverse=inverse --layout=layout

  buffer-header-size_: return 1

  send-command-buffer_ buffer:
    buffer[0] = 0x00
    i2c_.write buffer

  send-data-buffer_ buffer:
    buffer[0] = 0x40
    i2c_.write buffer

/**
Black-and-white driver for an SSD1306 or SSD1309 connected over SPI.
*/
class SpiSsd1306_ extends SSD1306:
  device_ / spi.Device

  constructor .device_ --reset/gpio.Pin?=null --height/int --flip/bool --inverse/bool --layout/int:
    super.from-subclass_ --reset=reset --height=height --flip=flip --inverse=inverse --layout=layout

  buffer-header-size_: return 0

  send-command-buffer_ buffer:
    device_.transfer buffer --dc=0

  send-data-buffer_ buffer:
    device_.transfer buffer --dc=1

/**
Deprecated. Use $Ssd1306 instead.
*/
abstract class SSD1306 extends Ssd1306:
  /** Deprecated. Use $Ssd1306.I2C-ADDRESS instead. */
  static I2C-ADDRESS ::= Ssd1306.I2C-ADDRESS
  /** Deprecated. Use $Ssd1306.I2C-ADDRESS-ALT instead. */
  static I2C-ADDRESS-ALT ::= Ssd1306.I2C-ADDRESS-ALT

  /**
  Deprecated. Use the $Ssd1306.i2c constructor instead.
  */
  constructor device/i2c.Device:
    return I2cSsd1306_ device --reset=null --height=64 --no-flip --inverse --layout=Ssd1306.LAYOUT-ALTERNATED

  /**
  Deprecated. Use $Ssd1306.i2c instead.
  */
  constructor.i2c device/i2c.Device --reset/gpio.Pin?=null:
    return I2cSsd1306_ device --reset=reset --height=64 --no-flip --inverse --layout=Ssd1306.LAYOUT-ALTERNATED

  /**
  Deprecated. Use $Ssd1306.spi instead.
  */
  constructor.spi device/spi.Device --reset/gpio.Pin?=null:
    return SpiSsd1306_ device --reset=reset --height=64 --no-flip --inverse --layout=Ssd1306.LAYOUT-ALTERNATED

  constructor.from-subclass_ --reset/gpio.Pin? --height/int --flip/bool --inverse/bool --layout/int:
    super.from-subclass_ --reset=reset --height=height --flip=flip --inverse=inverse --layout=layout

  abstract buffer-header-size_ -> int
  abstract send-command-buffer_ buffer -> none
  abstract send-data-buffer_ buffer -> none

/**
Black-and-white driver for an SSD1306 or SSD1309 connected over I2C or SPI.
Intended to be used with the Pixel-Display package
  at https://pkg.toit.io/package/pixel_display&url=github.com%2Ftoitware%2Ftoit-pixel-display&index=latest
See https://docs.toit.io/language/sdk/display
*/
abstract class Ssd1306 extends AbstractDriver:
  static I2C-ADDRESS ::= 0x3c
  static I2C-ADDRESS-ALT ::= 0x3d

  /**
  Sequential layout.

  The lines of the display are laid out sequentially.
  Hardware line "COM0" is connected to row 0 of the display.
  Hardware line "COM32" is connected to row 32 of the display.
  */
  static LAYOUT-SEQUENTIAL ::= 0
  /**
  Sequential switched layout.

  A common layout for 32-line displays.

  The lines of the display are laid out sequentially.
  Hardware line "COM0" is connected to row 32 of the display.
  Hardware line "COM32" is connected to row 0 of the display.

  Compared to $LAYOUT-SEQUENTIAL, lines 0-31 and 32-63 are swapped.
  */
  static LAYOUT-SEQUENTIAL-SWITCHED ::= 2

  /**
  Alternated layout.

  A common layout for 64-line displays.

  The lines of the display are laid out interleaved.
  Hardware line "COM0" is connected to row 0 of the display, "COM1" to row 2, ...
  Hardware line "COM32" is connected to row 1 of the display, "COM33" to row 3, ...
  */
  static LAYOUT-ALTERNATED ::= 1

  /**
  Alternated switched layout.

  The lines of the display are laid out interleaved.
  Hardware line "COM0" is connected to row 1 of the display, "COM1" to row 3, ...
  Hardware line "COM32" is connected to row 0 of the display, "COM33" to row 2, ...
  */
  static LAYOUT-ALTERNATED-SWITCHED ::= 3

  /**
  Deprecated. Use the $Ssd1306.i2c constructor instead.
  */
  constructor device/i2c.Device:
    return Ssd1306.i2c device

  /**
  Constructs a driver for an SSD1306 or SSD1309 connected over I2C.

  The $reset pin is optional. If provided, it is used to reset the display.
  The $height parameter is the height of the display in pixels, and must be
    either 32 or 64.
  The $flip parameter controls whether the display is flipped vertically.
  The $inverse parameter controls whether the display is inverted. That is,
    whether a pixel value of 0 means "on" or "off".
  The $layout parameter controls how the SSD1360 chip is physically connected
    to the rows of the display. Must be one of
    $LAYOUT-SEQUENTIAL, $LAYOUT-SEQUENTIAL-SWITCHED, $LAYOUT-ALTERNATED, or
    $LAYOUT-ALTERNATED-SWITCHED.

  It is safe to use the wrong $flip, $inverse and $layout parameters. The
    display will still work, but the image will be upside-down, inverted, or
    scrambled. If the display doesn't show the correct image, try changing
    these parameters. Note that rotations can be fixed by picking a different
    initial transform on the PixelDisplay.
  */
  constructor.i2c device/i2c.Device
      --reset/gpio.Pin?=null
      --height/int=64
      --flip/bool=false
      --inverse/bool=false
      --layout/int=(height == 32 ? LAYOUT-SEQUENTIAL-SWITCHED : LAYOUT-ALTERNATED):
    return I2cSsd1306_ device --reset=reset --height=height --flip=flip --inverse=inverse --layout=layout

  /**
  Variant of $Ssd1306.i2c that takes an SPI device instead of an I2C device.
  */
  constructor.spi device/spi.Device
      --reset/gpio.Pin?=null
      --height/int=64
      --flip/bool=false
      --inverse/bool=false
      --layout/int=(height == 32 ? LAYOUT-SEQUENTIAL-SWITCHED : LAYOUT-ALTERNATED):
    return SpiSsd1306_ device --reset=reset --height=height --flip=flip --inverse=inverse --layout=layout

  constructor.from-subclass_
      --reset/gpio.Pin?
      --height/int
      --flip/bool
      --inverse/bool
      --layout = (height == 32 ? LAYOUT-SEQUENTIAL-SWITCHED : LAYOUT-ALTERNATED):
    if reset:
      reset.set 0
      sleep --ms=50
      reset.set 1
    if height != 32 and height != 64:
      throw "height must be 32 or 64"
    if layout != LAYOUT-SEQUENTIAL and layout != LAYOUT-SEQUENTIAL-SWITCHED
        and layout != LAYOUT-ALTERNATED and layout != LAYOUT-ALTERNATED-SWITCHED:
      throw "layout must be one of LAYOUT_SEQUENTIAL, LAYOUT_SEQUENTIAL_SWITCHED, LAYOUT_ALTERNATED, LAYOUT_ALTERNATED_SWITCHED"
    this.height = height
    init_ --flip=flip --inverse=inverse --layout=layout

  buffer_ := ByteArray WIDTH_ + 1
  command-buffers_ := [ByteArray 1, ByteArray 2, ByteArray 3, ByteArray 4]

  static WIDTH_ ::= 128
  static HEIGHT_ ::= 64

  width/int ::= WIDTH_
  height/int ::= ?
  flags/int ::= FLAG-2-COLOR | FLAG-PARTIAL-UPDATES

  abstract buffer-header-size_ -> int
  abstract send-command-buffer_ buffer -> none
  abstract send-data-buffer_ buffer -> none

  init_ --flip/bool --inverse/bool --layout/int:
    command_ SSD1306-DISPLAYOFF_
    command_ SSD1306-SETDISPLAYCLOCKDIV_ 0x80
    command_ SSD1306-SETMULTIPLEX_ 0x3f
    command_ SSD1306-SETDISPLAYOFFSET_ 0
    command_ SSD1306-SETSTARTLINE-0_
    command_ SSD1306-SETMEMORYMODE_ 0
    command_ SSD1306-SETREMAPMODE-1_
    if flip:
      command_ SSD1306-COMSCANINC_
    else:
      command_ SSD1306-COMSCANDEC_
    command_ SSD1306-SETCOMPINS_ ((layout << 4) | 0x02)
    command_ SSD1306-SETCONTRAST_ 0xcf
    command_ SSD1306-SETPRECHARGE_ 0xf1
    command_ SSD1306-SETVCOMDETECT_ 0x30
    command_ SSD1306-CHARGEPUMP_ 0x14
    command_ SSD1306-DEACTIVATE-SCROLL_
    command_ SSD1306-DISPLAYALLON-RESUME_
    if inverse:
      // This driver inverts the meaning of "inverse".
      // Typically displays are oled where the inverse mode is
      // more common.
      command_ SSD1306-NORMALDISPLAY_
    else:
      command_ SSD1306-INVERSEDISPLAY_
    command_ SSD1306-DISPLAYON_

  command_ byte:
    i := buffer-header-size_
    buffer := command-buffers_[i]
    buffer[i] = byte
    send-command-buffer_ buffer

  command_ byte1 byte2:
    i := buffer-header-size_
    buffer := command-buffers_[i + 1]
    buffer[i] = byte1
    buffer[i + 1] = byte2
    send-command-buffer_ buffer

  command_ byte1 byte2 byte3:
    i := buffer-header-size_
    buffer := command-buffers_[i + 2]
    buffer[i] = byte1
    buffer[i + 1] = byte2
    buffer[i + 2] = byte3
    send-command-buffer_ buffer

  draw-two-color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    command_ SSD1306-COLUMNADDR_
        left               // Column start.
        right - 1          // Column end.
    command_ SSD1306-PAGEADDR_
        top >> 3           // Page start.
        (bottom >> 3) - 1  // Page end.

    patch-width := right - left

    line-buffer := buffer_[0..patch-width + buffer-header-size_]

    i := 0
    for y := top; y < bottom; y += 8:
      line-buffer.replace buffer-header-size_ pixels i i + patch-width
      i += patch-width
      send-data-buffer_ line-buffer

/// I2C ID of an SSD1306 display.
/// Deprecated. Use $Ssd1306.I2C-ADDRESS instead.
SSD1306-ID ::= Ssd1306.I2C-ADDRESS
