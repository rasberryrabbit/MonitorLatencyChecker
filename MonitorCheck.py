from pywinusb import hid
import time

vendor=0x2341
pid=0x484c

def read_handler(data):
  print("".join(map(chr, data)))

def main():
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
      buffer[3]=0x30 #0 or 1 or any

      out_report[0].set_raw_data(buffer)
      out_report[0].send()

      time.sleep(0.05)

    device.close()


main()
