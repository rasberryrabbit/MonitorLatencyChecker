#include <HID-Project.h>
#include <HID-Settings.h>

/* 
 *  firmware for arduino pro micro
 *  8pin = photodiode input.
 *  
 */

const int pinLed = LED_BUILTIN; //
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
    if(Serial.available()) {
      Serial.readBytes(rawhidData,3);
      st=micros();
      if(rawhidData[0]=='B' && rawhidData[1]=='G') {
        if(rawhidData[2]=='0') {
          old=0;
        } else if(rawhidData[2]=='1') {
          old=1;
        } else {
          old=digitalRead(photo);
        }
        flag=1;
      } else {
        // serial print
        Serial.write("OK\n");
        RawHID.write("OK");
      }
      // remove unused chars
      while(Serial.available())
        Serial.read();
    } else
    if(RawHID.available()) {
      RawHID.readBytes(rawhidData,64);
      st=micros();
      if(rawhidData[0]=='B' && rawhidData[1]=='G') {
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
        Serial.write("OK\n");
      }
      // remove unused chars
      while(RawHID.available())
        RawHID.read();
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
      snprintf(&obuf[1],64,"%012ld",et-st);      
      RawHID.write(obuf,64);
      // serial print
      Serial.write(obuf,64);
      Serial.println("");
    }
    // skip input chars on waiting
    while(Serial.available())
      Serial.read();
    while(RawHID.available())
      RawHID.read();
  }
}
