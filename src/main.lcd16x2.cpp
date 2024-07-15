#include <Arduino.h>
#include <Wire.h> // Library for I2C communication

// LCD commands and flags
#define LCD_CLEARDISPLAY 0x01
#define LCD_RETURNHOME 0x02
#define LCD_ENTRYMODESET 0x04
#define LCD_DISPLAYCONTROL 0x08
#define LCD_FUNCTIONSET 0x20
#define LCD_SETDDRAMADDR 0x80
#define LCD_ENTRYLEFT 0x02
#define LCD_DISPLAYON 0x04
#define LCD_2LINE 0x08
#define LCD_BACKLIGHT 0x08
#define En B00000100  // Enable bit
#define Rs B00000001  // Register select bit

#define UEXT_POWER_PIN 8
#define LCD_ADDRESS 0x27

void sendData(uint8_t data) {
  Wire.beginTransmission(LCD_ADDRESS);
  Wire.write(data | LCD_BACKLIGHT);
  Wire.endTransmission();   

  // Pulse the enable bit
  Wire.beginTransmission(LCD_ADDRESS);
  Wire.write((data | En) | LCD_BACKLIGHT);
  Wire.endTransmission();

  Wire.beginTransmission(LCD_ADDRESS);
  Wire.write((data & ~En) | LCD_BACKLIGHT);
  Wire.endTransmission();
}

void lcdInit() {
  // SendCommand
  sendData((LCD_BACKLIGHT) & 0xf0);
  sendData(((LCD_BACKLIGHT) & 0x0f) << 4);

  sendData(0x03 << 4); // Function set - 8-bit mode
  sendData(0x02 << 4); // Function set - 4-bit mode

  // SendCommand
  sendData((LCD_FUNCTIONSET | LCD_2LINE) & 0xf0);
  sendData(((LCD_FUNCTIONSET | LCD_2LINE) & 0x0f) << 4);
  // SendCommand
  sendData((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0xf0);
  sendData(((LCD_DISPLAYCONTROL | LCD_DISPLAYON) & 0x0f) << 4);
  // SendCommand
  sendData((LCD_CLEARDISPLAY) & 0xf0);
  sendData(((LCD_CLEARDISPLAY) & 0x0f) << 4);

  delayMicroseconds(2000);
  // SendCommand
  sendData((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0xf0);
  sendData(((LCD_ENTRYMODESET | LCD_ENTRYLEFT) & 0x0f) << 4);
  // SendCommand
  sendData((LCD_RETURNHOME) & 0xf0);
  sendData(((LCD_RETURNHOME) & 0x0f) << 4);
  delayMicroseconds(2000);
}

void lcdPrint(const String &s, uint8_t row, uint8_t col) {
  uint8_t addr = col + (row == 1 ? 0x40 : 0x00);
  // SendCommand
  sendData((LCD_SETDDRAMADDR | addr) & 0xf0);
  sendData(((LCD_SETDDRAMADDR | addr) & 0x0f) << 4);

  for (char c : s) {
    // SendCommand
    sendData(((c) & 0xf0) | Rs);
    sendData(((c << 4) & 0xf0) | Rs); 
  }
}

void setup() {
  pinMode(UEXT_POWER_PIN, OUTPUT);
  digitalWrite(UEXT_POWER_PIN, LOW);
  Wire.begin();
  lcdInit();
}

void loop() {
  lcdPrint("Hello World!", 0, 2);  // Print "Hello World!" on the first row, third column
  lcdPrint("LCD tutorial", 1, 2);  // Print "LCD tutorial" on the second row, third column
}
