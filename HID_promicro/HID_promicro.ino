/* 
 *  firmware for arduino pro micro
 *  8pin = photodiode input.
 *  
 */

#include <HID-Project.h>
#include <HID-Settings.h>

const int pinLed = LED_BUILTIN;
uint8_t rawhidData[64];
uint8_t obuf[64];

int photo=8;
int flag=0;
unsigned long st,et;
int old=LOW;

void setup() {
  pinMode(photo, INPUT);
  Serial.begin(115200);
  RawHID.begin(rawhidData, sizeof(rawhidData));
}

void loop() {
  if(flag==0) {
    if(RawHID.available()) {
      st=micros();
      RawHID.readBytes(rawhidData,64);
      if(memcmp(rawhidData,"BG",2)==0) {
        if(rawhidData[2]=='0') {
          old=0;
        } else if(rawhidData[2]=='1') {
          old=1;
        } else {
          old=digitalRead(photo);
        }
        flag=1;
      } else {
        RawHID.write("OK");
        // serial print
        Serial.write("OK\n");
      }
    }
  } else {
    if(digitalRead(photo)!=old) {
      et=micros();
      flag=0;
      if(old) {
        obuf[0]='F';
      } else {
        obuf[0]='T';
      }
      snprintf(&obuf[1],64,"%012d",et-st);      
      RawHID.write(obuf,64);
      // serial print
      Serial.write(obuf,64);
      Serial.println("");
    }
  }
}
