#include <HID-Project.h>
#include <HID-Settings.h>
#include <PinChangeInterrupt.h>

/* 
 *  firmware for arduino pro micro
 *  16MHz 5V board.
 *  pin 8 = photodiode input.
 *  pin 9 = toggle trigger
 *  0.245V
 */

#define PIN_MOUSE 9
#define PIN_PHOTO 8

#define USE_RAW_TIME

const int pinLed = LED_BUILTIN; //
uint8_t rawData[64];
uint8_t obuf[32];

char flag='F';
int result=0;
unsigned long st,et;
unsigned long re;
int old=LOW;
int tr_enable=0;
unsigned long mouse_st, mouse_et;
unsigned long *rp;
int sendsize=16;


void PinIntMouse(void) {
  tr_enable=1;
}

void PinIntPhoto(void) {
  if(!result) {
    et=st;
    st=micros();
    if(digitalRead(PIN_PHOTO))
      flag='T';
      else flag='F';
    result=1;
  }
}

void setup() {
  pinMode(PIN_PHOTO, INPUT);
  pinMode(PIN_MOUSE, INPUT_PULLUP);
  Serial.begin(115200);
  Mouse.begin();
  tr_enable=0;
  result=0;
  rp=(unsigned long *)&obuf[1];
  st=micros();
  mouse_st=millis();
  attachPCINT(digitalPinToPCINT(PIN_PHOTO), PinIntPhoto, CHANGE);
  attachPCINT(digitalPinToPCINT(PIN_MOUSE), PinIntMouse, RISING);
}

void loop() {
  // wait changes and send
  if(result) {
    re=et-st;
    obuf[0]=flag;
#ifdef USE_RAW_TIME
    *rp=re;
#else
    snprintf(&obuf[1],16,"%012ld",re);
#endif
    // serial print
    Serial.write(obuf,sendsize);
    result=0;
  } else {
    // respond serial
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
    if(tr_enable) {
      mouse_et=millis();
      if(mouse_et-mouse_st>=300) {
        Mouse.click();
        st=micros();
        mouse_st=mouse_et;
      }
      tr_enable=0;
    }
  }
}
