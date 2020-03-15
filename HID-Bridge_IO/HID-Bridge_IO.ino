/*
 Serial Monitor latency checker HID IO
 Pin 2 = Photo Diode
 Pin 4 = Indicator LED
 Pin 8 = Key start
 Board: HoodLoader2 UNO
*/

int keystart=8;
int photo=2;
unsigned long st,et;
int flag=0;
int old=LOW;
char buf[16];

void setup() {
  Serial.begin(115200);

  pinMode(keystart, INPUT);
  pinMode(photo, INPUT);
}

void loop() {
  if((!flag)&&Serial.available()) {
    Serial.readBytes(buf,16);
    if(memcmp(buf,"BG",2)==0) {
      st=millis();
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
  if(flag) {
    if(digitalRead(photo)!=old) {
      et=millis();
      flag=0;
      snprintf(buf,16,"%012d",et-st);
      Serial.write(buf,16);
    }
  }
}
