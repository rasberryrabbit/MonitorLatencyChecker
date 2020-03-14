import serial
from time import sleep
from threading import Thread
import re


def receiving(ser):
  while 1:
    buf=''
    ser.write(b'IOBG')
    while ser.inWaiting()>0:
      buf+=ser.read()
    if buf!='':
      res=re.findall('IOED(\d+)',buf)
      for it in res:
        print(it)
    sleep(0.05)
    
 
if __name__ == '__main__':
  Com1 = serial.Serial(port='COM7',baudrate=57600);
 
  if Com1.isOpen():
   print Com1
  else:
   print Com1.port + ' Can not open'

  Thread(target=receiving, args=(Com1,)).start()

  
