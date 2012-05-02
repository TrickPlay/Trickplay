import socket
import select
import random

# Packet assembly
message_type = 0x0001
message_length = 0x0000
magic_cookie = 0x2112A442
# uses Mersenne Twister, not cryptographically secure
transaction_id = random.getrandbits(96)

print "request message type", hex(message_type)
print "request message length", hex(message_length)
print "request magic cookie", hex(magic_cookie)
print "request transaction id", hex(transaction_id)

stun_request = bytearray(20)

stun_request[1] = 0x01
stun_request[4] = magic_cookie >> 24
stun_request[5] = (magic_cookie & 0xFF0000) >> 16
stun_request[6] = (magic_cookie & 0xFF00) >> 8
stun_request[7] = magic_cookie & 0xFF

# this looks ridiculous but I tested it in python's console and it works
for i in range(8, 20):
    stun_request[i] = (transaction_id & (0xFF << 8*(20 - i - 1))) >> 8*(20 - i - 1)

# create a socket to the stun server
stun_port = 3478
stun_host = socket.gethostbyname("stun.xten.com")
udp_stun_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# wait for a writeable socket
readable, writeable, in_error = select.select([], [udp_stun_socket], [], 5)
# write stun request
if writeable.count(udp_stun_socket):
    udp_stun_socket.sendto(stun_request, (stun_host, stun_port))

# wait for a readable socket
readable, writeable, in_error = select.select([udp_stun_socket], [], [], 5)
data = 0
# read stun response
if readable.count(udp_stun_socket):
    data, addr = udp_stun_socket.recvfrom(1024)
    print "Received stun response from", addr, "with data length:", len(data)


def make_value(start, size):
    value = 0
    for i in range(0, size):
        value += ord(data[start+i]) << 8*(size - i - 1)

    return value


resp_message = make_value(0, 2)
resp_length = make_value(2, 2)
resp_cookie = make_value(4, 4)
resp_id = make_value(8, 12)

# grab the STUN attributes
attributes = []
pos = 20
while pos < resp_length + 20:
    attribute = {}
    typ = make_value(pos, 2)
    length = make_value(pos+2, 2)
    attribute['type'] = typ
    attribute['length'] = length
    attribute['val'] = make_value(pos+4, length)
    attributes.append(attribute)
    # skip ahead to the right position
    padding = 4 - length % 4
    if padding == 4:
        padding = 0
    pos += 4 + length + padding

print "response message type", hex(resp_message)
print "response message length", hex(resp_length)
print "response cookie", hex(resp_cookie)
print "response transaction id", hex(resp_id)

for attribute in attributes:
    print "attribute: ", attribute


