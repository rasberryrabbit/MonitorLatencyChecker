#include <HID-Project.h>
#include <HID-Settings.h>

/* 
 *  firmware for arduino pro micro
 *  pin 8 = photodiode input.
 *  pin 9 = toggle trigger
 *  
 */

const int pinLed = LED_BUILTIN; //
uint8_t rawData[64];
uint8_t obuf[16];

int photo=8;
int trig=9;
int flag=0;
unsigned long st,et;
unsigned long re;
int old=LOW;
int tr_enable=1;
int trigger_delay=200;
unsigned long lt,ct;

void setup() {
  pinMode(photo, INPUT);
  pinMode(trig, INPUT_PULLUP);
  Serial.begin(115200);
  Mouse.begin();
  tr_enable=digitalRead(trig);
  lt=millis();
}

void loop() {
  tr_enable=digitalRead(trig);
  if(!flag) {
    // start trigger
    if(!tr_enable) {
      ct=millis();
      if(ct-lt>=trigger_delay) {
        lt=ct;
        flag=1;
        old=digitalRead(photo);
        Mouse.click();
        st=micros();
      }
    }
    // read serial
    if(Serial.available()) {
      while(Serial.available()) {
        Serial.read();
      }
      Serial.println("OK");
    }
  } else {
    // wait changes
    if(digitalRead(photo)!=old) {
      et=micros();
      flag=0;
      old=digitalRead(photo);
      if(old) {
        obuf[0]='T';
      } else {
        obuf[0]='F';
      }
      re=et-st;
      snprintf(&obuf[1],16,"%012ld",re);
      // serial print
      Serial.write(obuf,16);
    }
  }
}
