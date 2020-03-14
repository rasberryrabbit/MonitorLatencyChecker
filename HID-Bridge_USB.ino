/*
  Serial Monitor latency checker USB
  Board: HoodLoader2 16u2
*/
#include "HID.h"
//#include "Keyboard.h"

// IO Reset pin
const uint8_t resetPin = IO_MCU_RESET_PIN;

void setup() {
  // Set main MCU by default active
  digitalWrite(resetPin, HIGH);
  pinMode(resetPin, OUTPUT);

  // Keyboard Action, not used
  //Keyboard.begin();

  // Start USB Serial
  Serial.begin(0);
  // Start IO Serial
  Serial1.begin(2000000);
}

void loop() {
  static unsigned long et,st;
  char tmp[14];
  // reset the main mcu if DTR goes HIGH
  if (Serial.dtr())
    digitalWrite(resetPin, LOW);
  else
    digitalWrite(resetPin, HIGH);  
  /* 
     IO -> USB
     Read Serial signal & timing from IO.
     Do not using short length data, it make corrupt USB serial data.
  */
  int readAvailable = Serial1.available();
  // "IOED", 4Bytes+
  if (readAvailable >= 4) {
    et=micros();

    int writeAvailable = Serial.availableForWrite();

    // "IOED"+nnnnnn, 4Bytes+Micro Second Timing
    int i=snprintf(tmp,sizeof(tmp),"%.12d",et-st);
    
    if (writeAvailable >= 4+i) {

      // Write maximum one EP_SIZE to not block with Zero Length packets
      uint8_t buff[USB_EP_SIZE - 1];
      if (readAvailable > sizeof(buff))
        readAvailable = sizeof(buff);

      // Dont write more than USB can take to not block
      if (readAvailable > writeAvailable)
        readAvailable = writeAvailable;

      // Read Serial signal from IO
      int n = Serial1.readBytes((char *)buff, readAvailable);
      // Write it to Keyboard
      //Keyboard.write(buff, n);
      // Write Serial signal to USB
      Serial.write(buff,n);
      Serial.print(tmp);
      Serial.flush();
    }
  }


  /* 
   USB -> IO
   Send serial signal to IO
  */
  readAvailable = Serial.available();
  // "IOBG", 4Bytes+
  if (readAvailable >= 4) {
    st=micros();

    int writeAvailable = Serial1.availableForWrite();
    // "IOBG"
    if (writeAvailable >= 4) {

      // Write maximum one EP_SIZE to not block with Zero Length packets
      if (readAvailable > (USB_EP_SIZE - 1))
        readAvailable = (USB_EP_SIZE - 1);

      // Dont write more than USART buffer is free to not block
      if (readAvailable > writeAvailable)
        readAvailable = writeAvailable;

      // Write Serial signal to IO
      uint8_t buff[SERIAL_TX_BUFFER_SIZE];
      int n = Serial.readBytes((char *)buff, readAvailable);
      Serial1.write(buff, n);
    }
  }

}
