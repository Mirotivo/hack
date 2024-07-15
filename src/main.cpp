/*
 *  iceprog -- firmware sketch for Arduino-based Lattice iCE programmers
 *
 *  Chris B. <chris@protonic.co.uk> @ Olimex Ltd. <c> 2017
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  Relevant Documents:
 *  -------------------
 *  http://www.latticesemi.com/~/media/Documents/UserManuals/EI/icestickusermanual.pdf
 *  http://www.micron.com/~/media/documents/products/data-sheet/nor-flash/serial-nor/n25q/n25q_32mb_3v_65nm.pdf
 *  http://www.ftdichip.com/Support/Documents/AppNotes/AN_108_Command_Processor_for_MPSSE_and_MCU_Host_Bus_Emulation_Modes.pdf
 *  https://www.olimex.com/Products/FPGA/iCE40/iCE40HX1K-EVB/
 *  https://github.com/Marzogh/SPIFlash
 */

#include <SPI.h>
#include "SPIFlash.h"

// Pin definitions
#define LED_PIN 17
#define CDONE_PIN 3
#define RESET_PIN 2
#define UEXT_POWER_PIN 8
#define CS_PIN 13
#define HWB_INPUT DDRE &= B11111011
#define HWB (PINE & B00000100) == 0
#define LED_GREEN_PIN 7
#define LED_YELLOW_PIN 9

// Commands
#define CMD_READ_ID 0x9F
#define CMD_POWER_UP 0xAB
#define CMD_POWER_DOWN 0xB9
#define CMD_WRITE_ENABLE 0x06
#define CMD_BULK_ERASE 0xC7
#define CMD_SECTOR_ERASE 0xD8
#define CMD_PROGRAM 0x02
#define CMD_READ 0x03
#define CMD_READ_ALL 0x83
#define CMD_READY 0x44
#define CMD_EMPTY 0x45

// Frame control bytes
#define FRAME_END 0xC0
#define FRAME_ESCAPE 0xDB
#define TRANS_FRAME_END 0xDC
#define TRANS_FRAME_ESCAPE 0xDD

// SPI Flash object
SPIFlash flash(CS_PIN);

// Function prototypes
// Setup and loop functions
void setup();
void loop();
void loopProgramMode();
void loopBridgeMode();
// Frame handling functions
bool readSerialFrame();
void decodeFrame();
void startFrame(uint8_t command);
void addByte(uint8_t newByte);
void sendFrame();
// Flash operations
void sendID();
void eraseFlashBulk();
void eraseSector(uint32_t sector);
void writePage(int pageNumber);
void readPage(uint16_t address);
void readAllPages();

// Global variables
uint8_t rxFrame[512], txFrame[512], frameChecksum, receivedChecksum;
uint8_t memoryBuffer[256];
uint8_t dataBuffer[256];
uint16_t txPointer;
uint32_t maxPage;
bool escaped;
bool isProgramMode;

void setup() {
  // Initialize pins
  pinMode(CDONE_PIN, INPUT);
  pinMode(RESET_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(CS_PIN, OUTPUT);
  pinMode(UEXT_POWER_PIN, OUTPUT);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_YELLOW_PIN, OUTPUT);

  // Power up UEXT and set default states
  digitalWrite(LED_PIN, LOW);
  digitalWrite(CS_PIN, HIGH);
  digitalWrite(UEXT_POWER_PIN, HIGH);
  delay(1000);
  digitalWrite(UEXT_POWER_PIN, LOW);
  delay(500);
  digitalWrite(RESET_PIN, HIGH);

  // Initialize serial communication
  Serial.begin(230400);
  while (!Serial);
  Serial1.begin(115200);

  // Set initial mode and LEDs
  isProgramMode = true;
  HWB_INPUT;
  digitalWrite(LED_YELLOW_PIN, isProgramMode);
  digitalWrite(LED_GREEN_PIN, !isProgramMode);
}

void loop() {
  if (isProgramMode)
    loopProgramMode();
  else
    loopBridgeMode();

  // Switch modes if hardware button is pressed
  if (HWB) {
    isProgramMode = !isProgramMode;
    digitalWrite(LED_YELLOW_PIN, isProgramMode);
    digitalWrite(LED_GREEN_PIN, !isProgramMode);
    delay(1000);
  }
}

void loopProgramMode() {
  if (readSerialFrame()) {
    decodeFrame();
    if (receivedChecksum == 0xFF) {
      digitalWrite(RESET_PIN, LOW);

      switch (rxFrame[0]) {
        case CMD_READ_ID:
          sendID();
          break;
        case CMD_BULK_ERASE:
          eraseFlashBulk();
          break;
        case CMD_SECTOR_ERASE:
          flash.powerUp();
          eraseSector((rxFrame[1] << 8) | rxFrame[2]);
          flash.powerDown();
          break;
        case CMD_READ:
          flash.powerUp();
          readPage((rxFrame[1] << 8) | rxFrame[2]);
          flash.powerDown();
          break;
        case CMD_READ_ALL:
          readAllPages();
          break;
        case CMD_PROGRAM:
          writePage((rxFrame[1] << 8) | rxFrame[2]);
          break;
        default:
          break;
      }
      digitalWrite(RESET_PIN, HIGH);
    }
  }
}

void loopBridgeMode() {
  // Serial bridge mode
  if (Serial1.available()) {
    int inByte = Serial1.read();
    Serial.write(inByte);
  }
  if (Serial.available()) {
    int inByte = Serial.read();
    Serial1.write(inByte);
  }
}

bool readSerialFrame() {
  Serial.setTimeout(50);
  if (!Serial)
    Serial.begin(230400);
  while (Serial.available()) {
    Serial.readBytesUntil(FRAME_END, rxFrame, 512);
    return true;
  }
  return false;
}

void decodeFrame() {
  int x, y = 1;
  escaped = false;
  receivedChecksum = rxFrame[1];
  rxFrame[0] = rxFrame[1];
  for (x = 2; x < 512; x++) {
    switch (rxFrame[x]) {
      case FRAME_END:
        x = 513;
        break;
      case FRAME_ESCAPE:
        escaped = true;
        break;
      case TRANS_FRAME_END:
        if (escaped) {
          rxFrame[y++] = FRAME_END;
          receivedChecksum += FRAME_END;
          escaped = false;
        } else {
          rxFrame[y++] = TRANS_FRAME_END;
          receivedChecksum += TRANS_FRAME_END;
        }
        break;
      case TRANS_FRAME_ESCAPE:
        if (escaped) {
          rxFrame[y++] = FRAME_ESCAPE;
          receivedChecksum += FRAME_ESCAPE;
          escaped = false;
        } else {
          rxFrame[y++] = TRANS_FRAME_ESCAPE;
          receivedChecksum += TRANS_FRAME_ESCAPE;
        }
        break;
      default:
        escaped = false;
        rxFrame[y++] = rxFrame[x];
        receivedChecksum += rxFrame[x];
        break;
    }
  }
}

void startFrame(uint8_t command) {
  txFrame[0] = FRAME_END;
  txFrame[1] = command;
  txPointer = 2;
  frameChecksum = command;
}

void addByte(uint8_t newByte) {
  frameChecksum += newByte;
  if (newByte == FRAME_END) {
    txFrame[txPointer++] = FRAME_ESCAPE;
    txFrame[txPointer++] = TRANS_FRAME_END;
  } else if (newByte == FRAME_ESCAPE) {
    txFrame[txPointer++] = FRAME_ESCAPE;
    txFrame[txPointer++] = TRANS_FRAME_ESCAPE;
  } else {
    txFrame[txPointer++] = newByte;
  }
}

void sendFrame() {
  frameChecksum = 0xFF - frameChecksum;
  addByte(frameChecksum);
  txFrame[txPointer++] = FRAME_END;
  Serial.write(txFrame, txPointer);
}

void sendID() {
  flash.powerUp();
  uint32_t JEDEC = flash.getJEDECID();
  flash.powerDown();
  startFrame(CMD_READ_ID);
  addByte(JEDEC >> 16);
  addByte(JEDEC >> 8);
  addByte(JEDEC);
  sendFrame();
}

void eraseFlashBulk() {
  flash.powerUp();
  flash.eraseChip();
  flash.powerDown();
  startFrame(CMD_READY);
  addByte(CMD_BULK_ERASE);
  sendFrame();
}

void eraseSector(uint32_t sector) {
  flash.eraseBlock64K(sector << 8);
  startFrame(CMD_READY);
  sendFrame();
}

void writePage(int pageNumber) {
  flash.powerUp();
  for (int x = 0; x < 256; x++)
    memoryBuffer[x] = rxFrame[x + 3];
  flash.writePage(pageNumber, memoryBuffer);
  flash.readPage(pageNumber, dataBuffer);
  flash.powerDown();
  for (int a = 0; a < 256; a++) {
    if (dataBuffer[a] != memoryBuffer[a])
      return;
  }
  startFrame(CMD_READY);
  sendFrame();
}

void readPage(uint16_t address) {
  bool sendEmpty = true;
  flash.readPage(address, dataBuffer);
  for (int a = 0; a < 256; a++) {
    if (dataBuffer[a] != 0xFF) {
      startFrame(CMD_READ);
      addByte(address >> 8);
      addByte(address);
      for (int b = 0; b < 256; b++)
        addByte(dataBuffer[b]);
      sendFrame();
      sendEmpty = false;
      break;
    }
  }
  if (sendEmpty) {
    startFrame(CMD_EMPTY);
    addByte(address >> 8);
    addByte(address);
    sendFrame();
  }
}

void readAllPages() {
  flash.powerUp();
  maxPage = 0x2000;
  delay(10);
  for (uint32_t p = 0; p < maxPage; p++)
    readPage(p);
  startFrame(CMD_READY);
  sendFrame();
  flash.powerDown();
}






















