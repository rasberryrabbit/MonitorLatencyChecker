#include "HID-Project.h"

const int pinLed = LED_BUILTIN;
uint8_t rawhidData[16];

void setup() {
  Serial1.begin(1000000);

  Serial.begin(115200);

  RawHID.begin(rawhidData, sizeof(rawhidData));
}

void loop() {
  if(Serial1.available()) {
    Serial1.readBytes(rawhidData,16);
    RawHID.write(rawhidData,16);
    //Serial.write(rawhidData,16);  
  }
  if(RawHID.available()) {
    RawHID.readBytes(rawhidData,16);
    Serial1.write(rawhidData,16);
  }
}
