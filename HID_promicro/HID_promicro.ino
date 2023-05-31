#include <HID-Project.h>
#include <HID-Settings.h>
#include <PinChangeInterrupt.h>

/* 
 *  firmware for arduino pro micro
 *  16MHz 5V board.
 *  pin 8 = photodiode input.
 *  pin 9 = toggle trigger
 *  pin 10 = Edge trigger
 */

#define PIN_MOUSE 9
#define PIN_PHOTO 8
#define PIN_EDGE 10
#define PIN_PWM 3
#define PWM_DEF 12

#define USE_RAW_TIME
#define USE_EDGE
#define USE_MOUSE_INT

const int PIN_LED = LED_BUILTIN; //
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
int i, pwm0, pwm1;

#ifdef USE_MOUSE_INT
void PinIntMouse(void) {
  tr_enable=1;
}
#endif

#ifndef USE_EDGE
void PinIntPhoto(void) {
  if(!result) {
    st=et;
    et=micros();
    if(digitalRead(PIN_PHOTO)==HIGH)
      flag='T';
      else flag='F';
    result=1;
  }
}
#else
void PinIntEDGE(void) {
  // falling edge
  if(result==0)
    st=et;
  et=micros();
  result=1;
}
#endif

void setup() {
  pinMode(PIN_PHOTO, INPUT);
  pinMode(PIN_EDGE, INPUT);
  pinMode(PIN_MOUSE, INPUT_PULLUP);
  pinMode(PIN_PWM, OUTPUT);
  pinMode(PIN_LED, OUTPUT);
  
  Serial.begin(115200);
  Mouse.begin();
  tr_enable=0;
  result=0;
  rp=(unsigned long *)&obuf[1];
  et=micros();
  mouse_st=millis();
  // Pin 3, 976Hz
  TCCR3A = _BV(COM3B1) | _BV(WGM31) | _BV(WGM30);
  TCCR3B = _BV(CS32);
  analogWrite(PIN_PWM,PWM_DEF); // 0.233mV
#ifndef USE_EDGE
  attachPCINT(digitalPinToPCINT(PIN_PHOTO), PinIntPhoto, CHANGE);
#else  
  attachPCINT(digitalPinToPCINT(PIN_EDGE), PinIntEDGE, CHANGE);
#endif

#ifdef USE_MOUSE_INT
  attachPCINT(digitalPinToPCINT(PIN_MOUSE), PinIntMouse, RISING);
#endif
}

void loop() {
  // wait changes and send
  if(result) {
    cli();
    re=et-st;
    obuf[0]=flag;
#ifdef USE_RAW_TIME
    *rp=re;
#else
    snprintf(&obuf[1],16,"%012ld",re);
#endif
    result=0;
    sei();
    // serial print
    Serial.write(obuf,sendsize);
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
        } else if(rawData[0]=='C'&&rawData[1]=='A') {
          cli();
          pwm1=analogRead(A1);
          for(i=0;i<50;i++) {
            analogWrite(PIN_PWM,i);
            delay(100);
            pwm0=analogRead(A0);
            if(pwm0>pwm1) {
              i-=2;
              i/=2;
              break;
            }
          }
          if(i<0) i=PWM_DEF;
          analogWrite(PIN_PWM,i);
          sei();
#ifdef USE_RAW_TIME
          *rp=i;
#else
          snprintf(&obuf[1],16,"%2d",i);
#endif
          obuf[0]=(char)0x43;
          Serial.write(obuf,sendsize);
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
#ifndef USE_MOUSE_INT
    if(digitalRead(PIN_MOUSE)==LOW) {
#else
    if(tr_enable) {
#endif
      mouse_et=millis();
      if(mouse_et-mouse_st>=300) {
        Mouse.click();
        et=micros();
        mouse_st=mouse_et;
      }
#ifdef USE_MOUSE_INT
      tr_enable=0;
#endif
    }
  }
}
