/*
 Serial Monitor latency checker HID IO
 Pin 2 = Photo Diode
 Pin 4 = Indicator LED
 Board: HoodLoader2 UNO
*/

int flag=0;
int PinRead=2;
int PinWrite=4;
char buf[5];

void setup() {
  // Serial Baud for USB <-> IO
  Serial.begin(2000000);
  // Pin setup
  pinMode(PinRead, INPUT);
  pinMode(PinWrite, OUTPUT);
  digitalWrite(PinWrite, LOW);
}

void loop() {
  // start signal from USB
  if(Serial.available()) {
    if((Serial.readBytes(buf,4)==4) && (memcmp(buf,"IOBG",4)==0)) {
      while(Serial.available()) {
        Serial.read();
      }
      flag=1;
      digitalWrite(PinWrite, LOW);
    }
  }
  // check photo diode and send signal to USB
  if(flag) {
    if(digitalRead(PinRead)==1) {
      Serial.write("IOED");
      flag=0;
      digitalWrite(PinWrite, HIGH);
    }
  }
}
