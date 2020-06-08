#include <HID-Project.h>
#include <HID-Settings.h>

/* 
 *  firmware for arduino pro micro
 *  8pin = photodiode input.
 *  
 */

const int pinLed = LED_BUILTIN; //
uint8_t rawData[64];
uint8_t obuf[64];

int photo=8;
int trig=9;
int flag=0;
unsigned long st,et;
int old=LOW;

void setup() {
  pinMode(photo, INPUT);
  pinMode(trig, INPUT_PULLUP);
  Serial.begin(115200);
  Mouse.begin();
}

void loop() {
  if(flag==0) {
    // pin 9 manual trigger
    if(digitalRead(trig)==0) {
      old=digitalRead(photo);
      flag=1;
      Mouse.click();
      st=micros();
      Serial.println("Trigger");
    } else
    // serial trigger
    if(Serial.available()) {
      Serial.readBytes(rawData,2);
      if(rawData[0]=='M' && rawData[1]=='T') {
        old=digitalRead(photo);
        flag=1;
        Mouse.click();
        st=micros();
      } else {
        Serial.println("OK");
      }
      // remove unused chars
      while(Serial.available())
        Serial.read();
    }
  } else {
    if(digitalRead(photo)!=old) {
      et=micros();
      flag=0;
      old=digitalRead(photo);
      if(old) {
        obuf[0]='T';
      } else {
        obuf[0]='F';
      }
      snprintf(&obuf[1],64,"%012ld",et-st);
      st=et;
      // serial print
      Serial.write(obuf,64);
    }
    // skip input chars on waiting
    while(Serial.available())
      Serial.read();
  }
}
