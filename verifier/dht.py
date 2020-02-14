import serial
import time
import hmac
import hashlib
import os

if __name__== "__main__":
	dev = '/dev/ttyUSB0'
	baud = 9600
	cmd = '\x03'
	success = '\xee'
	with serial.Serial(dev, baud, timeout=5) as ser:
		# Sending Attestation Command
		ser.write(cmd)
		r = ser.read(6)
		if r[0] != cmd:
			print 'Wrong response command: ', r[0].encode('hex')
		if r[1] != success:
			print 'Fail to sense with error: ', r[1].encode('hex')
		temp = ((float)(ord(r[4]) & 0x7F)*256 + ord(r[5]))/10
		humid = (float)(ord(r[2])*256 + ord(r[3]))/10
		print 'Temperature: ', temp, 'c'
		print 'Humidity: ', humid, '%'

