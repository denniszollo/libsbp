# Copyright (C) 2015 Swift Navigation Inc.
# Contact: Mark Fine <mark@swiftnav.com>
#
# This source is subject to the license found in the file 'LICENSE' which must
# be be distributed together with this source. All other rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

from .base_driver import BaseDriver
import serial
import serial.tools.list_ports
try:
  import termios
  SerialError = termios.error  
except ImportError:
  SerialError = None
  

class PySerialDriver(BaseDriver):
  """
  PySerialDriver

  The :class:`PySerialDriver` class reads SBP messages from a serial port
  using the pyserial driver.  This is mostly redundant, is the Serial object's
  read and write methods can be used directly.

  Parameters
  ----------
  port : string
    URI to port to read SBP messages from. Accepts the following types
    of URLs:
    - rfc2217://<host>:<port>[/<option>[/<option>]]
    - socket://<host>:<port>[/<option>[/<option>]]
    - loop://[<option>[/<option>]]
    and device names, such as /dev/ttyUSB0 (Linux) and COM3 (Windows). See
    http://pyserial.sourceforge.net/pyserial_api.html#urls for more details.
  baud : int
    Baud rate of serial port (defaults to 115200)

  """
  def __init__(self,
               port,
               baud=115200,
               rtscts=False,
               timeout=0.03,
               blocksize=16*1024):
    import serial
    try:
      handle = serial.serial_for_url(port)
      handle.baudrate = baud
      handle.timeout = timeout
      handle.rtscts = rtscts
      super(PySerialDriver, self).__init__(handle)
      self.buf = bytes()
    except (OSError, serial.SerialException) as e:
      print
      print "Error opening serial device '%s':" % port
      print e
      print
      print "The following serial devices were detected:"
      print
      for (name, desc, _) in serial.tools.list_ports.comports():
        if desc[0:4] == "ttyS":
          continue
        if name == desc:
          print "\t%s" % name
        else:
          print "\t%s (%s)" % (name, desc)
      print
      raise SystemExit

  def read(self, size):
    """
    Read wrapper.

    Parameters
    ----------
    size : int
      Number of bytes to read.
    """
    try:
      while len(self.buf) < size:
        self.buf += self.handle.read(16*1024)
      ret = self.buf[:size]
      self.buf = self.buf[size:]
      return ret
    except (OSError, serial.SerialException):
      print
      print "Piksi disconnected"
      print
      raise IOError

  def write(self, s):
    """
    Write wrapper.

    Parameters
    ----------
    s : bytes
      Bytes to write
    """
    try:
      return self.handle.write(s)
    except (OSError, serial.SerialException, serial.writeTimeoutError) as e:
      if e == serial.writeTimeoutError:
        print "sbp pyserial_driver: writeTimeoutError"
        return 0
      else:
        print
        print "Piksi disconnected"
        print
        raise IOError

  def __enter__(self):
    self.flush()
    return self

  def __exit__(self, *args):
    try:
      self.flush()
      self.close()
    except (OSError, SerialError, serial.SerialException) as e:
      pass

