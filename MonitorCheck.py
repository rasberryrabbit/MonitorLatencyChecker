from pywinusb import hid
import time
import threading


vendor=0x2341
pid=0x484c

start=0

def read_handler(data):
  global start
  print((time.time()-start)*1000)
  print("".join(map(chr, data)))

def procmain():
  global start
  filter = hid.HidDeviceFilter(vendor_id=vendor,product_id=pid)
  devices = filter.get_devices()

  if devices:
    device = devices[0]

    device.open()

    device.set_raw_data_handler(read_handler)

    out_report = device.find_output_reports()

    while 1:
      buffer = [0x0]*17
      buffer[0]=0x00
      buffer[1]=0x42 #B
      buffer[2]=0x47 #G
      buffer[3]=0x31 #0 or 1 or any

      out_report[0].set_raw_data(buffer)
      out_report[0].send()
      start=time.time()
      #screen drawing on this position
      
      time.sleep(0.5)

    device.close()
    
t = threading.Thread(target=procmain, args=())
t.start()

