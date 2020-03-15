/*
 Serial Monitor latency checker HID IO
 Pin 2 = Photo Diode
 Pin 4 = Indicator LED
 Pin 8 = Key start
 Board: HoodLoader2 UNO
*/

int photo=2;
int flag=0;
int sertrig=0;
unsigned long st,et;
int old=LOW;
char buf[16];

void setup() {
  Serial.begin(1000000);

  pinMode(photo, INPUT);
}

void loop() {
  if(flag) {
    if(digitalRead(photo)!=old) {
      et=micros();
      flag=0;
      if(old) {
        buf[0]='F';
      } else {
        buf[0]='T';
      }
      snprintf(&buf[1],15,"%012d",et-st);
      Serial.write(buf,16);
    }
  } else {
    if(sertrig) {
      sertrig=0;
      serialEvent();
    }
  }
}

void serialEvent() {
  if(flag) {
    sertrig=1;
  } else
  if(Serial.available()) {
    st=micros();
    Serial.readBytes(buf,16);
    if(memcmp(buf,"BG",2)==0) {
      if(buf[2]=='0') {
        old=0;
      } else if(buf[2]=='1') {
        old=1;
      } else {
        old=digitalRead(photo);
      }
      flag=1;
    } else {
      Serial.write("OK");
    }
  }
}
