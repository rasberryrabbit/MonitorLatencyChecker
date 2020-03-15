/*
 Serial Monitor latency checker HID IO
 Pin 2 = Photo Diode
 Pin 4 = Indicator LED
 Board: HoodLoader2 UNO
*/

int flag=0;
int PinRead=2;
int PinWrite=4;
char buf[6];
char obuf[6];
int PinState=0;

void setup() {
  // Serial Baud for USB <-> IO
  Serial.begin(2000000);
  // Pin setup
  pinMode(PinRead, INPUT);
  pinMode(PinWrite, OUTPUT);
  digitalWrite(PinWrite, LOW);
  obuf[0]='I';
  obuf[1]='O';
  obuf[2]='E';
  obuf[3]='D';
}

void loop() {
  // start signal from USB, "IOBG"n
  if(Serial.available()>=5) {
    if((Serial.readBytes(buf,5)==5) && (memcmp(buf,"IOBG",4)==0)) {
      while(Serial.available()) {
        Serial.read();
      }
      if(buf[4]=='0') {
        PinState=LOW;
      } else if(buf[4]=='1') {
        PinState=HIGH;
      } else {
        PinState=digitalRead(PinRead);
      }
      flag=1;
      digitalWrite(PinWrite, LOW);
    }
  }
  // check photo diode and send signal to USB
  if(flag) {
    char c;
    if(digitalRead(PinRead)!=PinState) {
      if(PinState==LOW) {
        obuf[4]='T';
      } else {
        obuf[4]='F';
      }
      Serial.write(obuf,5);
      flag=0;
      digitalWrite(PinWrite, HIGH);
    }
  }
}
