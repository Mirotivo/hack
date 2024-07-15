/***************************************************
  This is our GFX example for the Adafruit ILI9341 Breakout and Shield
  ----> http://www.adafruit.com/products/1651

  Check out the links above for our tutorials and wiring diagrams
  These displays use SPI to communicate, 4 or 5 pins are required to
  interface (RST is optional)
  Adafruit invests time and resources providing this open source code,
  please support Adafruit and open-source hardware by purchasing
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.
  MIT license, all text above must be included in any redistribution
 ****************************************************/

#include "SPI.h"

// Pin definitions
#define UEXT_POWER_PIN 8
#define TFT_DC 1  // SPI_SDO
#define TFT_CS 13 // SPI_CSX

// Default SPI frequency
#define DEFAULT_SPI_FREQ 8000000L

// ILI9341 command definitions
#define ILI9341_CASET 0x2A
#define ILI9341_PASET 0x2B
#define ILI9341_RAMWR 0x2C

#define ILI9341_PWCTR1 0xC0
#define ILI9341_PWCTR2 0xC1
#define ILI9341_PWCTR3 0xC2
#define ILI9341_PWCTR4 0xC3
#define ILI9341_PWCTR5 0xC4
#define ILI9341_VMCTR1 0xC5
#define ILI9341_VMCTR2 0xC7

#define ILI9341_TFTWIDTH 240
#define ILI9341_TFTHEIGHT 320

#define ILI9341_NOP 0x00
#define ILI9341_SWRESET 0x01
#define ILI9341_RDDID 0x04
#define ILI9341_RDDST 0x09

#define ILI9341_PTLAR 0x30
#define ILI9341_VSCRDEF 0x33
#define ILI9341_MADCTL 0x36
#define ILI9341_VSCRSADD 0x37
#define ILI9341_PIXFMT 0x3A

// Color definitions
#define ILI9341_BLACK 0x0000
#define ILI9341_NAVY 0x000F
#define ILI9341_DARKGREEN 0x03E0
#define ILI9341_DARKCYAN 0x03EF
#define ILI9341_MAROON 0x7800
#define ILI9341_PURPLE 0x780F
#define ILI9341_OLIVE 0x7BE0
#define ILI9341_LIGHTGREY 0xC618
#define ILI9341_DARKGREY 0x7BEF
#define ILI9341_BLUE 0x001F
#define ILI9341_GREEN 0x07E0
#define ILI9341_CYAN 0x07FF
#define ILI9341_RED 0xF800
#define ILI9341_MAGENTA 0xF81F
#define ILI9341_YELLOW 0xFFE0
#define ILI9341_WHITE 0xFFFF
#define ILI9341_ORANGE 0xFD20
#define ILI9341_GREENYELLOW 0xAFE5
#define ILI9341_PINK 0xFC18

#define ILI9341_FRMCTR1 0xB1
#define ILI9341_FRMCTR2 0xB2
#define ILI9341_FRMCTR3 0xB3
#define ILI9341_INVCTR 0xB4
#define ILI9341_DFUNCTR 0xB6

#define ILI9341_INVOFF 0x20
#define ILI9341_INVON 0x21
#define ILI9341_GAMMASET 0x26
#define ILI9341_DISPOFF 0x28
#define ILI9341_DISPON 0x29

#define ILI9341_GMCTRP1 0xE0
#define ILI9341_GMCTRN1 0xE1

#define ILI9341_SLPIN 0x10
#define ILI9341_SLPOUT 0x11
#define ILI9341_PTLON 0x12
#define ILI9341_NORON 0x13

#define AVR_WRITESPI(x) do { SPDR = (x); while (!(SPSR & _BV(SPIF))); } while (0)
#define AVR_WRITESPI16(x) do { AVR_WRITESPI((x) >> 8); AVR_WRITESPI(x); } while (0)


void sendCommand(uint8_t commandByte) {
  // Send command
  digitalWrite(TFT_DC, LOW);
  AVR_WRITESPI(commandByte);
  digitalWrite(TFT_DC, HIGH);
}


void initializeDisplay() {
  sendCommand(0xEF);
  AVR_WRITESPI(0x03);
  AVR_WRITESPI(0x80);
  AVR_WRITESPI(0x02);

  sendCommand(0xCF);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0xC1);
  AVR_WRITESPI(0x30);

  sendCommand(0xED);
  AVR_WRITESPI(0x64);
  AVR_WRITESPI(0x03);
  AVR_WRITESPI(0x12);
  AVR_WRITESPI(0x81);

  sendCommand(0xE8);
  AVR_WRITESPI(0x85);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0x78);

  sendCommand(0xCB);
  AVR_WRITESPI(0x39);
  AVR_WRITESPI(0x2C);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0x34);
  AVR_WRITESPI(0x02);

  sendCommand(0xF7);
  AVR_WRITESPI(0x20);

  sendCommand(0xEA);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0x00);

  sendCommand(ILI9341_PWCTR1);
  AVR_WRITESPI(0x23);

  sendCommand(ILI9341_PWCTR2);
  AVR_WRITESPI(0x10);

  sendCommand(ILI9341_VMCTR1);
  AVR_WRITESPI(0x3e);
  AVR_WRITESPI(0x28);

  sendCommand(ILI9341_VMCTR2);
  AVR_WRITESPI(0x86);

  sendCommand(ILI9341_MADCTL);
  AVR_WRITESPI(0x48);

  sendCommand(ILI9341_VSCRSADD);
  AVR_WRITESPI(0x00);

  sendCommand(ILI9341_PIXFMT);
  AVR_WRITESPI(0x55);

  sendCommand(ILI9341_FRMCTR1);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0x18);

  sendCommand(ILI9341_DFUNCTR);
  AVR_WRITESPI(0x08);
  AVR_WRITESPI(0x82);
  AVR_WRITESPI(0x27);

  sendCommand(0xF2);
  AVR_WRITESPI(0x00);

  sendCommand(ILI9341_GAMMASET);
  AVR_WRITESPI(0x01);

  sendCommand(ILI9341_GMCTRP1);
  AVR_WRITESPI(0x0F);
  AVR_WRITESPI(0x31);
  AVR_WRITESPI(0x2B);
  AVR_WRITESPI(0x0C);
  AVR_WRITESPI(0x0E);
  AVR_WRITESPI(0x08);
  AVR_WRITESPI(0x4E);
  AVR_WRITESPI(0xF1);
  AVR_WRITESPI(0x37);
  AVR_WRITESPI(0x07);
  AVR_WRITESPI(0x10);
  AVR_WRITESPI(0x03);
  AVR_WRITESPI(0x0E);
  AVR_WRITESPI(0x09);
  AVR_WRITESPI(0x00);

  sendCommand(ILI9341_GMCTRN1);
  AVR_WRITESPI(0x00);
  AVR_WRITESPI(0x0E);
  AVR_WRITESPI(0x14);
  AVR_WRITESPI(0x03);
  AVR_WRITESPI(0x11);
  AVR_WRITESPI(0x07);
  AVR_WRITESPI(0x31);
  AVR_WRITESPI(0xC1);
  AVR_WRITESPI(0x48);
  AVR_WRITESPI(0x08);
  AVR_WRITESPI(0x0F);
  AVR_WRITESPI(0x0C);
  AVR_WRITESPI(0x31);
  AVR_WRITESPI(0x36);
  AVR_WRITESPI(0x0F);

  sendCommand(ILI9341_SLPOUT);
  delay(150);

  sendCommand(ILI9341_DISPON);
  delay(150);
}

void fillScreen(uint16_t color) {
  uint16_t x1 = 0, y1 = 0;
  uint16_t x2 = ILI9341_TFTWIDTH - 1, y2 = ILI9341_TFTHEIGHT - 1;
  sendCommand(ILI9341_CASET); // Column address set
  AVR_WRITESPI16(x1);
  AVR_WRITESPI16(x2);
  sendCommand(ILI9341_PASET); // Row address set
  AVR_WRITESPI16(y1);
  AVR_WRITESPI16(y2);
  sendCommand(ILI9341_RAMWR); // Write to RAM

  uint32_t len = (uint32_t)ILI9341_TFTWIDTH * ILI9341_TFTHEIGHT;
  while (len--) {
    AVR_WRITESPI16(color);
  }
}

void setup() {
  // Initialize pins
  pinMode(TFT_CS, OUTPUT);
  pinMode(TFT_DC, OUTPUT);
  pinMode(UEXT_POWER_PIN, OUTPUT);
  digitalWrite(UEXT_POWER_PIN, LOW);
  delay(1000);
  // Initialize SPI
  SPI.begin();

  // Initialize display
  initializeDisplay();
}

void loop(void) {
  // Clear screen to black
  fillScreen(ILI9341_BLACK);
  delay(1000);

  // Clear screen to blue
  fillScreen(ILI9341_BLUE);
  delay(1000);
}
