#include "Arduino.h"

// OLIMEXINO-32u4 has two general purpose LEDs at ARDUINO pins 7 and 9
int led1 = 7;
int led2 = 9;

// the setup routine runs once when you press reset:
void setup()
{
  // initialize the digital pins as an outputs.
  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop()
{
  digitalWrite(led1, HIGH); // turn the LED on (HIGH is the voltage level)
  delay(200);               // wait for 200 ms
  digitalWrite(led1, LOW);
  delay(200);
  digitalWrite(led2, HIGH); // turn the LED on (HIGH is the voltage level)
  delay(200);               // wait for 200ms
  digitalWrite(led2, LOW);
}
