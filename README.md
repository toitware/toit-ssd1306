# SSD1306
Driver for the small black-white OLED display.

Driver for the SSD1306 OLED display.  This is a 128x64 monochrome
display.

On the Wemos Lolin board the I2C bus is connected to pin5 (SDA) and
pin4 (SCL), and the SSD1306 display is device 0x3c.  See
https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf for programming info.

This package also contains an experimental driver for the SSD1306
in SPI mode.
