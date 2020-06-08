#include <HID-Project.h>
#include <HID-Settings.h>

/* 
 *  firmware for arduino pro micro
 *  8pin = photodiode input.
 *  
 */

const int pinLed = LED_BUILTIN; //
uint8_t rawData[32];
uint8_t obuf[64];

int photo=8;
int flag=0;
unsigned long st,et;
int old=LOW;
int mx=0;
int my=0;

void setup() {
  pinMode(photo, INPUT);
  Serial.begin(115200);
  Mouse.begin();
}

void loop() {
  if(flag==0) {
    if(Serial.available()) {
      Serial.readBytes(rawData,2);
      if(rawData[0]=='M') {
        switch(rawData[1]) {
          case 'X': 
              Serial.readBytes(&rawData[2],5);
              rawData[7]=0;
              mx=atoi(&rawData[2]);
              break;
          case 'Y': 
              Serial.readBytes(&rawData[2],5);
              rawData[7]=0;
              my=atoi(&rawData[2]);
              break;
          case 'T': 
              Mouse.move(mx,my);
              old=digitalRead(photo);
              flag=1;
              Mouse.click();
              st=micros();
              break;
          default:
              Serial.println("OK");
        }
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
        obuf[0]='F';
      } else {
        obuf[0]='T';
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
