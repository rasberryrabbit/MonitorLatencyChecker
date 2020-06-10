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
uint8_t obuf[64];

int photo=8;
int trig=9;
int flag=0;
unsigned long st,et;
int old=LOW;
int tr_enable=0;
int trigger_delay=200;
unsigned long lt,ct;

void setup() {
  pinMode(photo, INPUT);
  pinMode(trig, INPUT_PULLUP);
  Serial.begin(115200);
  Mouse.begin();
  lt=millis();
}

void loop() {
  // toggle trigger
  if(digitalRead(trig)==0) {
    tr_enable=!tr_enable;
    // reset wait condition
    if(!tr_enable) {
      flag=0;
    }
  }
  if(!flag) {
    // start trigger
    if(tr_enable) {
      ct=millis();
      if(ct-lt>=trigger_delay) {
        lt=ct;
        flag=1;
        old=digitalRead(photo);
        Mouse.click();
        st=micros();
      }
    } 
    while(Serial.available()) {
      Serial.read();
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
      snprintf(&obuf[1],64,"%012ld",et-st);
      st=et;
      // serial print
      Serial.write(obuf,64);
    }
  }
}
