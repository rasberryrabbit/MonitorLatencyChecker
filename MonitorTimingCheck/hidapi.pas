
unit hidapi;


interface

const
    hidapidll='hidapi.dll';

Type
    phid_device  = Pointer;
    Pwchar_t  = ^wchar_t;
    wchar_t = widechar;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  {******************************************************
   HIDAPI - Multi-Platform library for
   communication with HID devices.
  
   Alan Ott
   Signal 11 Software
  
   8/22/2009
  
   Copyright 2009, All Rights Reserved.
  
   At the discretion of the user of this library,
   this software may be licensed under the terms of the
   GNU General Public License v3, a BSD-Style license, or the
   original HIDAPI license as outlined in the LICENSE.txt,
   LICENSE-gpl3.txt, LICENSE-bsd.txt, and LICENSE-orig.txt
   files located at the root of the source distribution.
   These files may also be found in the public source
   code repository located at:
          http://github.com/signal11/hidapi .
  ******************************************************* }
  {* @file
   * @defgroup API hidapi API
    }

    //  Phid_device :Pointer;
    {*< opaque hidapi structure  }
    {* hidapi info structure  }
    {* Platform-specific device path  }
    {* Device Vendor ID  }
    {* Device Product ID  }
    {* Serial Number  }
    {* Device Release Number in binary-coded decimal,
    			    also known as Device Version Number  }
    {* Manufacturer String  }
    {* Product string  }
    {* Usage Page for this Device/Interface
    			    (Windows/Mac only).  }
    {* Usage for this Device/Interface
    			    (Windows/Mac only). }
    {* The USB interface which this logical device
    			    represents.
    
    				* Valid on both Linux implementations in all cases.
    				* Valid on the Windows implementation only if the device
    				  contains more than one interface.
    				* Valid on the Mac implementation if and only if the device
    				  is a USB HID device.  }
    {* Pointer to the next device  }
      phid_device_info = ^hid_device_info;
      hid_device_info = record
          path : Pchar;
          vendor_id : word;
          product_id : word;
          serial_number : Pwchar_t;
          release_number : word;
          manufacturer_string : Pwchar_t;
          product_string : Pwchar_t;
          usage_page : word;
          usage : word;
          interface_number : longint;
          next : Phid_device_info;
        end;

    {* @brief Initialize the HIDAPI library.
    
    			This function initializes the HIDAPI library. Calling it is not
    			strictly necessary, as it will be called automatically by
    			hid_enumerate() and any of the hid_open_*() functions if it is
    			needed.  This function should be called at the beginning of
    			execution however, if there is a chance of HIDAPI handles
    			being opened by different threads simultaneously.
    			
    			@ingroup API
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_init:Integer; cdecl; external hidapidll name 'hid_init';
    {* @brief Finalize the HIDAPI library.
    
    			This function frees all of the static data associated with
    			HIDAPI. It should be called at the end of execution to avoid
    			memory leaks.
    
    			@ingroup API
    
    		    @returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_exit:Integer; cdecl; external hidapidll name 'hid_exit';
    {* @brief Enumerate the HID Devices.
    
    			This function returns a linked list of all the HID devices
    			attached to the system which match vendor_id and product_id.
    			If @p vendor_id is set to 0 then any vendor matches.
    			If @p product_id is set to 0 then any product matches.
    			If @p vendor_id and @p product_id are both set to 0, then
    			all HID devices will be returned.
    
    			@ingroup API
    			@param vendor_id The Vendor ID (VID) of the types of device
    				to open.
    			@param product_id The Product ID (PID) of the types of
    				device to open.
    
    		    @returns
    		    	This function returns a pointer to a linked list of type
    		    	struct #hid_device_info, containing information about the HID devices
    		    	attached to the system, or NULL in the case of failure. Free
    		    	this linked list by calling hid_free_enumeration().
    		 }
    function hid_enumerate(vendor_id, product_id: Word):Phid_device_info; cdecl; external hidapidll name 'hid_enumerate';
    {* @brief Free an enumeration Linked List
    
    		    This function frees a linked list created by hid_enumerate().
    
    			@ingroup API
    		    @param devs Pointer to a list of struct_device returned from
    		    	      hid_enumerate().
    		 }
    procedure hid_free_enumeration(devs:phid_device_info); cdecl; external hidapidll name 'hid_free_enumeration';
    {* @brief Open a HID device using a Vendor ID (VID), Product ID
    			(PID) and optionally a serial number.
    
    			If @p serial_number is NULL, the first device with the
    			specified VID and PID is opened.
    
    			@ingroup API
    			@param vendor_id The Vendor ID (VID) of the device to open.
    			@param product_id The Product ID (PID) of the device to open.
    			@param serial_number The Serial Number of the device to open
    				               (Optionally NULL).
    
    			@returns
    				This function returns a pointer to a #hid_device object on
    				success or NULL on failure.
    		 }

    function hid_open(vendor_id, product_id:Word; serial_number:pwchar_t):phid_device; cdecl; external hidapidll name 'hid_open';
    {* @brief Open a HID device by its path name.
    
    			The path name be determined by calling hid_enumerate(), or a
    			platform-specific path name can be used (eg: /dev/hidraw0 on
    			Linux).
    
    			@ingroup API
    		    @param path The path name of the device to open
    
    			@returns
    				This function returns a pointer to a #hid_device object on
    				success or NULL on failure.
    		 }
    function hid_open_path(path:pchar):phid_device; cdecl; external hidapidll name 'hid_open_path';
    {* @brief Write an Output report to a HID device.
    
    			The first byte of @p data[] must contain the Report ID. For
    			devices which only support a single report, this must be set
    			to 0x0. The remaining bytes contain the report data. Since
    			the Report ID is mandatory, calls to hid_write() will always
    			contain one more byte than the report contains. For example,
    			if a hid report is 16 bytes long, 17 bytes must be passed to
    			hid_write(), the Report ID (or 0x0, for devices with a
    			single report), followed by the report data (16 bytes). In
    			this example, the length passed in would be 17.
    
    			hid_write() will send the data on the first OUT endpoint, if
    			one exists. If it does not, it will send the data through
    			the Control Endpoint (Endpoint 0).
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param data The data to send, including the report number as
    				the first byte.
    			@param length The length in bytes of the data to send.
    
    			@returns
    				This function returns the actual number of bytes written and
    				-1 on error.
    		 }
    function hid_write(dev:phid_device; data:pbyte; length:size_t):Integer; cdecl; external hidapidll name 'hid_write';
    {* @brief Read an Input report from a HID device with timeout.
    
    			Input reports are returned
    			to the host through the INTERRUPT IN endpoint. The first byte will
    			contain the Report number if the device uses numbered reports.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param data A buffer to put the read data into.
    			@param length The number of bytes to read. For devices with
    				multiple reports, make sure to read an extra byte for
    				the report number.
    			@param milliseconds timeout in milliseconds or -1 for blocking wait.
    
    			@returns
    				This function returns the actual number of bytes read and
    				-1 on error. If no packet was available to be read within
    				the timeout period, this function returns 0.
    		 }
    function hid_read_timeout(dev:phid_device; data:pbyte; length:size_t; milliseconds:Integer):Integer; cdecl; external hidapidll name 'hid_read_timeout';
    {* @brief Read an Input report from a HID device.
    
    			Input reports are returned
    		    to the host through the INTERRUPT IN endpoint. The first byte will
    			contain the Report number if the device uses numbered reports.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param data A buffer to put the read data into.
    			@param length The number of bytes to read. For devices with
    				multiple reports, make sure to read an extra byte for
    				the report number.
    
    			@returns
    				This function returns the actual number of bytes read and
    				-1 on error. If no packet was available to be read and
    				the handle is in non-blocking mode, this function returns 0.
    		 }
    function hid_read(dev:phid_device; data:pbyte; length:size_t):Integer; cdecl; external hidapidll name 'hid_read';
    {* @brief Set the device handle to be non-blocking.
    
    			In non-blocking mode calls to hid_read() will return
    			immediately with a value of 0 if there is no data to be
    			read. In blocking mode, hid_read() will wait (block) until
    			there is data to read before returning.
    
    			Nonblocking can be turned on and off at any time.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param nonblock enable or not the nonblocking reads
    			 - 1 to enable nonblocking
    			 - 0 to disable nonblocking.
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_set_nonblocking(dev:phid_device; nonblock:LongBool):Integer; cdecl; external hidapidll name 'hid_set_nonblocking';
    {* @brief Send a Feature report to the device.
    
    			Feature reports are sent over the Control endpoint as a
    			Set_Report transfer.  The first byte of @p data[] must
    			contain the Report ID. For devices which only support a
    			single report, this must be set to 0x0. The remaining bytes
    			contain the report data. Since the Report ID is mandatory,
    			calls to hid_send_feature_report() will always contain one
    			more byte than the report contains. For example, if a hid
    			report is 16 bytes long, 17 bytes must be passed to
    			hid_send_feature_report(): the Report ID (or 0x0, for
    			devices which do not use numbered reports), followed by the
    			report data (16 bytes). In this example, the length passed
    			in would be 17.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param data The data to send, including the report number as
    				the first byte.
    			@param length The length in bytes of the data to send, including
    				the report number.
    
    			@returns
    				This function returns the actual number of bytes written and
    				-1 on error.
    		 }
    function hid_send_feature_report(dev:phid_device; data:pbyte; length:size_t):Integer; cdecl; external hidapidll name 'hid_send_feature_report';
    {* @brief Get a feature report from a HID device.
    
    			Set the first byte of @p data[] to the Report ID of the
    			report to be read.  Make sure to allow space for this
    			extra byte in @p data[]. Upon return, the first byte will
    			still contain the Report ID, and the report data will
    			start in data[1].
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param data A buffer to put the read data into, including
    				the Report ID. Set the first byte of @p data[] to the
    				Report ID of the report to be read, or set it to zero
    				if your device does not use numbered reports.
    			@param length The number of bytes to read, including an
    				extra byte for the report ID. The buffer can be longer
    				than the actual report.
    
    			@returns
    				This function returns the number of bytes read plus
    				one for the report ID (which is still in the first
    				byte), or -1 on error.
    		 }
    function hid_get_feature_report(dev:phid_device; data:pbyte; length:size_t):Integer; cdecl; external hidapidll name 'hid_get_feature_report';
    {* @brief Close a HID device.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    		 }
    procedure hid_close(dev:phid_device); cdecl; external hidapidll name 'hid_close';
    {* @brief Get The Manufacturer String from a HID device.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param string A wide string buffer to put the data into.
    			@param maxlen The length of the buffer in multiples of wchar_t.
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_get_manufacturer_string(dev:phid_device; str:pwidechar; maxlen:size_t):Integer; cdecl; external hidapidll name 'hid_get_manufacturer_string';
    {* @brief Get The Product String from a HID device.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param string A wide string buffer to put the data into.
    			@param maxlen The length of the buffer in multiples of wchar_t.
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_get_product_string(dev:phid_device; str:pwidechar; maxlen:size_t):Integer; cdecl; external hidapidll name 'hid_get_product_string';
    {* @brief Get The Serial Number String from a HID device.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param string A wide string buffer to put the data into.
    			@param maxlen The length of the buffer in multiples of wchar_t.
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_get_serial_number_string(dev:phid_device; str:pwidechar; maxlen:size_t):Integer; cdecl; external hidapidll name 'hid_get_serial_number_string';
    {* @brief Get a string from a HID device, based on its string index.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    			@param string_index The index of the string to get.
    			@param string A wide string buffer to put the data into.
    			@param maxlen The length of the buffer in multiples of wchar_t.
    
    			@returns
    				This function returns 0 on success and -1 on error.
    		 }
    function hid_get_indexed_string(dev:phid_device; string_index:Integer; str:pwidechar; maxlen:size_t):Integer; cdecl; external hidapidll name 'hid_get_indexed_string';
    {* @brief Get a string describing the last error which occurred.
    
    			@ingroup API
    			@param dev A device handle returned from hid_open().
    
    			@returns
    				This function returns a string containing the last error
    				which occurred or NULL if none has occurred.
    		 }
    function hid_error(dev:phid_device):pwidechar; cdecl; external hidapidll name 'hid_error';

implementation


end.
