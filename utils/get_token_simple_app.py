import hmac
import hashlib 
import binascii

def hmac_sha256(key, message):
    byte_key = binascii.unhexlify(key)
    message = message.decode("hex")
    return hmac.new(byte_key, message, hashlib.sha256).hexdigest().upper()

def reverse_endian(orig):
    return ''.join(sum([(c,d,a,b) for a,b,c,d in zip(*[iter(orig)]*4)], ()))

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

key = "0123456789abcdef"
chal = "0000000000000000000000000000000000000000000000000000000000000000"
metadata = chal + "e0da" + "e0ee" + "0200" + "0210" + "0001"

pmem = read_mem('../msp_bin/pmem.mem')
att_size = 0x1000
att_data = binascii.hexlify(pmem[:att_size])

dkey = hmac_sha256(reverse_endian(key), reverse_endian(chal))
dkey = hmac_sha256(dkey, reverse_endian(metadata))
token = hmac_sha256(dkey, att_data)
#print 'Metadata: '+metadata
#print 'Att Data: '+att_data
print 'Token: '+token
