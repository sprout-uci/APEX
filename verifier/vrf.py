import serial
import time
import hmac
import hashlib
import os

dev = '/dev/ttyUSB0'
baud = 9600
stimeout = 1
ATTEST_COMMAND = b'\x01'
EXECUTE_COMMAND = b'\x02'

def swap_endianess(barray):

	for i in range(0, len(barray), 2):
		tmp = barray[i]
		barray[i] = barray[i+1]
		barray[i+1] = tmp
	return barray

def read_mem(filepath):
	out = []
	with open(filepath, 'r') as fp:
		lines = fp.readlines()
		for line in lines:
			if '@' not in line:
				continue
			mem = line.split()
			for i in range(1, len(mem)):
				out.extend(mem[i].decode('hex'))
	out = swap_endianess(out)
	out = bytearray(out)
	return out


def gen_challenge(random=True):
	if not random:
		chal = ''
		start = 0 #'\x00'
		for i in range(0, 32):
			chal += str(start+i%10)
	else:
		chal = os.urandom(32)
	chal = bytearray(chal)
	print 'Challenge:', ''.join(format(x, '02x') for x in chal)
	return chal

def get_key():	
	key = ''
	for i in range(0, 64):
		key += '\x00'
	key = bytearray(key)
	key[0] = '\x01'
	key[1] = '\x23'
	key[2] = '\x45'
	key[3] = '\x67'
	key[4] = '\x89'
	key[5] = '\xab'
	key[6] = '\xcd'
	key[7] = '\xef'
	key = swap_endianess(key)
	print 'Keys:', ''.join(format(x, '02x') for x in key)
	return key

def expected_response(mems, start_addr, att_size, chal, key):
	dkey = hmac.new(key, msg=chal, digestmod=hashlib.sha256).digest()
	hex_resp = hmac.new(dkey, msg=mems[:start_addr+att_size], digestmod=hashlib.sha256).hexdigest()
	#print 'Attested Mems:', ''.join(format(x, '02x') for x in mems[:start_addr+att_size])
	return hex_resp

def attest(mems, size, masterkey, challenge):
	exp_resp = expected_response(mems, 0, size, challenge, masterkey)
	with serial.Serial(dev, baud, timeout=stimeout) as ser:
		# Sending Attestation Command
		ser.write(ATTEST_COMMAND)
		r = ser.read()
		print 'Command:', r.encode('hex')

		challenge = bytes(challenge)
		# Sending challenge
		for i in range(0, 32):
			#ser.write(b'\x00')
			ser.write(str(challenge[i]))
			r = ser.read()
			print 'Challenge[', i, ']:', r.encode("hex")

		resp = ser.read(32).encode("hex")

	print 'Response from Prover: ', resp
	print 'Expected response: ', exp_resp
	print 'Correct?: ', resp==exp_resp

def execute(mems, baseaddr, size):
	# Parameters
	ER_MAX_addr   =  0xFF00-baseaddr;
	OR_MAX_addr   =  ER_MAX_addr + 1*2;
	CHAL_addr   =  ER_MAX_addr + 2*2;
	EXEC_addr   =  ER_MAX_addr + 4*2;
	
	# Write mems[ER_MAX] = 0xE3AE - endianess??
	mems[ER_MAX_addr] = 0xAE;
	mems[ER_MAX_addr+1] = 0xE3;

	# Write mems[OR_MAX] = 0xF004 - TODO: endianess??
	mems[OR_MAX_addr] = 0x04;
	mems[OR_MAX_addr+1] = 0xF0;

	# Write exec_flag to 0xFFFF
	mems[EXEC_addr] = 0xFF;
	mems[EXEC_addr+1] = 0xFF;

	challenge = gen_challenge()
	
	# Write challenge - TODO: endianess??
	for i in range(0, 32):
		mems[CHAL_addr+i] = challenge[i]

	attest(mems, size, get_key(), challenge)


if __name__== "__main__":
	baseaddr = 0xe000
	attsize = 0x10
	pmem = read_mem('../msp_bin/pmem.mem')
	#execute(pmem, baseaddr, attsize)
	attest(pmem, attsize, get_key(), gen_challenge())

