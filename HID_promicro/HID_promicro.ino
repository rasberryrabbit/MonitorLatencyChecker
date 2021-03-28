#include <HID-Project.h>
#include <HID-Settings.h>

/* 
 *  firmware for arduino pro micro
 *  16MHz 5V board.
 *  pin 8 = photodiode input.
 *  pin 9 = toggle trigger
 *  
 */

#define USE_RAW_TIME

const int pinLed = LED_BUILTIN; //
uint8_t rawData[64];
uint8_t obuf[32];

int photosen=8;
int trig=9;
int flag=0;
unsigned long st,et;
unsigned long re;
int old=LOW;
int tr_enable=1;
int trigger_delay=200;
unsigned long lt,ct;
unsigned long *rp;
int sendsize=16;

void setup() {
  pinMode(photosen, INPUT);
  pinMode(trig, INPUT_PULLUP);
  Serial.begin(115200);
  Mouse.begin();
  tr_enable=digitalRead(trig);
  rp=(unsigned long *)&obuf[1];
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
        old=digitalRead(photosen);
        Mouse.click();
        st=micros();
      }
    }
    // read serial
    if(Serial.available()) {
      // set send packet size
      if(Serial.readBytes(rawData,3)==3) {
        if(rawData[0]=='P'&&rawData[1]=='S') {
          sendsize=rawData[2];
          if(sendsize>32)
            sendsize=32;
            else if(sendsize<8)
              sendsize=8;
        }
      }
      while(Serial.available()) {
        Serial.read();
      }
      obuf[0]=(char)0x4F;
#ifdef USE_RAW_TIME
      *rp=sendsize;
#else
      snprintf(&obuf[1],16,"%2d",sendsize);
#endif
      Serial.write(obuf,sendsize);
    }
  } else {
    // wait changes
    if(digitalRead(photosen)!=old) {
      et=micros();
      flag=0;
      old=digitalRead(photosen);
      if(old) {
        obuf[0]='T';
      } else {
        obuf[0]='F';
      }
      re=et-st;
#ifdef USE_RAW_TIME
      *rp=re;
#else
      snprintf(&obuf[1],16,"%012ld",re);
#endif
      // serial print
      Serial.write(obuf,sendsize);
    }
  }
}
