#include <Adafruit_GFX.h>
#include <Adafruit_ILI9341.h>
#include <SPI.h>

#define TFT_CS    8
#define TFT_RST   9
#define TFT_DC    10

Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC, TFT_RST);

void setup() {
  Serial.begin(9600);
  Serial.println("=== TFT Test with Slow SPI Clock ===");
  
  // Initialize SPI with slow clock
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV128); // Extremely slow: 16MHz / 128 = 125 kHz
  Serial.println("SPI initialized with extremely slow clock (125 kHz)");
  
  // Initialize TFT (ONLY ONCE in setup, not in loop!)
  tft.begin();
  Serial.println("TFT initialized");
}

void loop() {
  // Fill screen with blue color
  Serial.println("Filling screen with BLUE...");
  tft.fillScreen(ILI9341_BLUE);
  Serial.println("Done! Screen should be blue.");
  delay(1000);
}
