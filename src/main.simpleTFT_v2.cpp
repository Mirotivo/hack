/**
 * ILI9341 SOFTWARE SPI - Matching main.simpleTFT.cpp behavior
 * Same output, same result, but using software SPI instead of Adafruit library
 */

#include <Arduino.h>

#define TFT_CS      8
#define TFT_RST     9
#define TFT_DC      10
#define TFT_MOSI    11
#define TFT_SCK     13

#define ILI9341_BLUE  0x001F

// Software SPI write
void spiWrite(uint8_t data) {
    for (uint8_t bit = 0; bit < 8; bit++) {
        digitalWrite(TFT_MOSI, (data & 0x80) ? HIGH : LOW);
        digitalWrite(TFT_SCK, HIGH);
        digitalWrite(TFT_SCK, LOW);
        data <<= 1;
    }
}

void writeCommand(uint8_t cmd) {
    digitalWrite(TFT_DC, LOW);
    digitalWrite(TFT_CS, LOW);
    spiWrite(cmd);
    digitalWrite(TFT_CS, HIGH);
}

void writeData(uint8_t data) {
    digitalWrite(TFT_DC, HIGH);
    digitalWrite(TFT_CS, LOW);
    spiWrite(data);
    digitalWrite(TFT_CS, HIGH);
}

void tftBegin() {
    // Hardware Reset
    digitalWrite(TFT_RST, HIGH);
    delay(5);
    digitalWrite(TFT_RST, LOW);
    delay(20);
    digitalWrite(TFT_RST, HIGH);
    delay(150);
    
    // ILI9341 Initialization
    writeCommand(0x01); delay(150);
    writeCommand(0x28);
    writeCommand(0xCB); writeData(0x39); writeData(0x2C); writeData(0x00); writeData(0x34); writeData(0x02);
    writeCommand(0xCF); writeData(0x00); writeData(0xC1); writeData(0x30);
    writeCommand(0xE8); writeData(0x85); writeData(0x00); writeData(0x78);
    writeCommand(0xEA); writeData(0x00); writeData(0x00);
    writeCommand(0xED); writeData(0x64); writeData(0x03); writeData(0x12); writeData(0x81);
    writeCommand(0xF7); writeData(0x20);
    writeCommand(0xC0); writeData(0x23);
    writeCommand(0xC1); writeData(0x10);
    writeCommand(0xC5); writeData(0x3E); writeData(0x28);
    writeCommand(0xC7); writeData(0x86);
    writeCommand(0x36); writeData(0x48);
    writeCommand(0x3A); writeData(0x55);
    writeCommand(0xB1); writeData(0x00); writeData(0x18);
    writeCommand(0xB6); writeData(0x08); writeData(0x82); writeData(0x27);
    writeCommand(0xF2); writeData(0x00);
    writeCommand(0x26); writeData(0x01);
    writeCommand(0xE0); writeData(0x0F); writeData(0x31); writeData(0x2B); writeData(0x0C); writeData(0x0E); writeData(0x08); writeData(0x4E); writeData(0xF1); writeData(0x37); writeData(0x07); writeData(0x10); writeData(0x03); writeData(0x0E); writeData(0x09); writeData(0x00);
    writeCommand(0xE1); writeData(0x00); writeData(0x0E); writeData(0x14); writeData(0x03); writeData(0x11); writeData(0x07); writeData(0x31); writeData(0xC1); writeData(0x48); writeData(0x08); writeData(0x0F); writeData(0x0C); writeData(0x31); writeData(0x36); writeData(0x0F);
    writeCommand(0x11); delay(120);
    writeCommand(0x29); delay(100);
}

void fillScreen(uint16_t color) {
    writeCommand(0x2A); writeData(0); writeData(0); writeData(0); writeData(239);
    writeCommand(0x2B); writeData(0); writeData(0); writeData(1); writeData(63);
    writeCommand(0x2C);
    
    digitalWrite(TFT_DC, HIGH);
    digitalWrite(TFT_CS, LOW);
    uint8_t hi = color >> 8, lo = color & 0xFF;
    for (uint32_t i = 0; i < 76800UL; i++) {
        spiWrite(hi);
        spiWrite(lo);
    }
    digitalWrite(TFT_CS, HIGH);
}

void setup() {
    Serial.begin(9600);
    Serial.println("=== TFT Test with Slow SPI Clock ===");
    
    pinMode(TFT_CS, OUTPUT);
    pinMode(TFT_RST, OUTPUT);
    pinMode(TFT_DC, OUTPUT);
    pinMode(TFT_MOSI, OUTPUT);
    pinMode(TFT_SCK, OUTPUT);
    
    digitalWrite(TFT_CS, HIGH);
    digitalWrite(TFT_RST, HIGH);
    digitalWrite(TFT_DC, HIGH);
    digitalWrite(TFT_SCK, LOW);
    digitalWrite(TFT_MOSI, LOW);
    
    Serial.println("SPI initialized with extremely slow clock (125 kHz)");
    
    tftBegin();
    Serial.println("TFT initialized");
    Serial.println("Filling screen with BLUE...");
    
    fillScreen(ILI9341_BLUE);
    Serial.println("Done! Screen should be blue.");
}

void loop() {
  // Nothing to do
}
