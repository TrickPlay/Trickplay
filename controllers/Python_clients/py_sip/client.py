import getpass
import sys
import socket
import select
import telnetlib
import hashlib
import uuid
from time import sleep
from collections import deque

udp_sip_client_ip = "10.0.190.153"

udp_sip_server_port = 5060
udp_sip_client_port = 50418
udp_rtp_client_port = 7078

sdp_header = "v=0\r\n\
o=- 0 0 IN IP4 10.0.190.153\r\n\
s=Livu\r\n\
c=IN IP4 tpmini.internal.trickplay.com\r\n\
t=0 0\r\n\
a=tool:Livu RTP\r\n\
m=audio 0 RTP/AVP 96\r\n\
b=AS:64\r\n\
a=rtpmap:96 MPEG4-GENERIC/44100/1\r\n\
a=fmtp:96 profile-level-id=1;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3; config=1208\r\n\
a=control:streamid=0\r\n\
m=video 0 RTP/AVP 97\r\n\
b=AS:1372\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n\
a=control:streamid=1"

rtp_udp_sdp = "v=0\r\n\
o=- 536 3212164818 IN IP4 127.0.0.0\r\n\
s=QuickTime\r\n\
c=IN IP4 10.0.190.5\r\n\
t=0 0\r\n\
a=range:npt=now-\r\n\
a=isma-compliance:2,2.0,2\r\n\
m=audio 6970 RTP/AVP 96\r\n\
b=AS:64\r\n\
a=rtpmap:96 mpeg4-generic/44100/1\r\n\
a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n\
a=mpeg4-esid:101\r\n\
a=control:trackid=1\r\n\
m=video 6970 RTP/AVP 97\r\n\
b=AS:1372\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n\
a=mpeg4-esid:201\r\n\
a=cliprect:0,0,480,640\r\n\
a=framesize:97 640-480\r\n\
a=control:trackid=2\r\n"


sip_udp_sdp = "v=0\r\n\
o=- 536 3212164818 IN IP4 10.0.190.153\r\n\
s=Python\r\n\
t=0 0\r\n\
a=range:npt=now-\r\n\
a=isma-compliance:2,2.0,2\r\n\
m=audio 6970 RTP/AVP 96\r\n\
b=AS:64\r\n\
a=rtpmap:96 mpeg4-generic/44100/1\r\n\
a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n\
a=mpeg4-esid:101\r\n\
a=control:trackid=1\r\n\
m=video 6970 RTP/AVP 97\r\n\
b=AS:1372\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n\
a=mpeg4-esid:201\r\n\
a=cliprect:0,0,480,640\r\n\
a=framesize:97 640-480\r\n\
a=control:trackid=2\r\n"


sip_register = 'REGISTER sip:asterisk-1.asterisk.trickplay.com SIP/2.0\r\n\
Via: SIP/2.0/UDP 10.0.190.153:50418;rport;branch=a_branch\r\n\
Max-Forwards: 70\r\n\
From: <sip:phone@asterisk-1.asterisk.trickplay.com>;tag=gHrSD9H4BFrgg\r\n\
To: <sip:phone@asterisk-1.asterisk.trickplay.com>\r\n\
Call-ID: 2b464c7a-c332-122f-5db0-842b2b9cc652\r\n\
CSeq: 23479747 REGISTER\r\n\
Contact: <sip:phone@10.0.190.153:50418>\r\n\
User-Agent: Python\r\n\
Allow: INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE\r\n\
Supported: timer, 100rel, path\r\n'

sender_uri = "sip:phone@asterisk-1.asterisk.trickplay.com"
remote_uri = "sip:rex_sip@asterisk-1.asterisk.trickplay.com"

dial_600_uri = "sip:600@asterisk-1.asterisk.trickplay.com"

sip_invite = 'INVITE sip:rex@asterisk-1.asterisk.trickplay.com SIP/2.0\r\n\
Via: SIP/2.0/UDP 10.0.190.153:' + str(udp_sip_client_port) + ';rport;branch=a_branch\r\n\
Max-Forwards: 70\r\n\
From: <sip:phone@asterisk-1.asterisk.trickplay.com>;tag=taggoeshere\r\n\
To: <sip:rex@asterisk-1.asterisk.trickplay.com>\r\n\
Call-ID: 83bf049a-cfcd-122f-c1a7-842b2b9cc652\r\n\
CSeq: 24172815 INVITE\r\n\
Contact: <sip:phone@10.0.190.153:39588>\r\n\
User-Agent: Telepathy-SofiaSIP/0.6.3 sofia-sip/1.12.10\r\n\
Allow: INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE\r\n\
Supported: timer, 100rel\r\n\
Min-SE: 120\r\n\
Content-Type: application/sdp\r\n\
Content-Disposition: session\r\n\
Content-Length: 601\r\n'


rtp_header = "80005585000001e07da3dac9"
rtp_header = bytearray(rtp_header.decode("hex"))



#####################################


host = socket.gethostbyname("asterisk-1.asterisk.trickplay.com")

log = open("sip.log", "w")

"""
tn = telnetlib.Telnet(host, udp_sip_server_port)

sock = tn.get_socket()
print "Source: "
print sock.getsockname()
print "Destination: "
print sock.getpeername()
print "\n"
"""

branch_start = 'z9hG4bK'

session = ""
nonce = None
ha3 = ""

# Socket for SIP communication
udp_sip_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_sip_sock.bind(("", udp_sip_client_port))

# Socket for sending media via RTP
udp_rtp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_rtp_sock.bind(("", udp_rtp_client_port))

# Array that holds the sockets
sockets = [udp_sip_sock, udp_rtp_sock]

read_buf = bytearray("")

write_queue = deque([])

current_header = {}

states = ["UnRegistered", "Registered", "Inviting"]

state = "UnRegistered"


def sip_parse(data):
    """Parses incoming data"""

    global read_buf
    read_buf = read_buf + data
    result = read_buf.split('\r\n\r\n', 1)
    if len(result) < 2:
        return False
    header, read_buf = result

    #print "\nheader:\n", header, "\nread_buf\n", read_buf

    elements = header.split('\r\n')

    response = {}
    response['Status-Line'] = str(elements[0])
    
    #print "\n elements: \n", elements, "\n\n"

    for element in elements[1:]:
        #print "\n element: \n", element, "\n\n"
        key, var = element.split(": ", 1)
        response[str(key)] = str(var)

    if 'Content-Length' in response and response['Content-Length'] > 0:
        length = int(response['Content-Length'])
        response['full_body'] = str(read_buf[:length])
        read_buf = read_buf[length:]

    print 'response:\n', response, '\n\n'

    if 'Call-ID' in response:
        return response

    return False 


def get_frames():
    """Store all the frames into a list"""
    frames_fd = open("frames_rex_new.bin", "rb")

    all_frames = frames_fd.read()

    global frames
    frames = all_frames.split("REXFENLEY\x00")

    frames_fd.close()


#########################


import call

active_calls = {}
bye_triggered = False

rtp_dst_addr = None
rtp_dst_port = 0

register_call = call.Register("phone", sender_uri, remote_uri, udp_sip_client_ip,
                     udp_sip_client_port, udp_sip_server_port, write_queue)

invite_call = call.Invite("phone", sender_uri, remote_uri, udp_sip_client_ip,
                     udp_sip_client_port, udp_sip_server_port, write_queue)

active_calls[register_call.Call_ID] = register_call
active_calls[invite_call.Call_ID] = invite_call

def register_callback():
    invite_call.invite()


def invite_callback(media_dst):
    global rtp_dst_addr, rtp_dst_port
    rtp_dst_addr, rtp_dst_port = media_dst
    udp_rtp_sock.connect(media_dst)
    print '\nmedia_dst: ', media_dst, '\n'

def destruction_callback(call):
    global bye_triggered
    bye_triggered = True

register_call.callback = register_callback
invite_call.callback = invite_callback
invite_call.destruction_callback = destruction_callback

register_call.register()


def new_call(data, addr):
    if data['Status-Line'][:7] == "OPTIONS":
        options = call.Options("phone", sender_uri, remote_uri, udp_sip_client_ip,
                        udp_sip_client_port, udp_sip_server_port, write_queue)
        options.incoming_options(data, addr)
    elif data['Status-Line'][:3] == "BYE":
        bye = call.Bye("phone", sender_uri, remote_uri, udp_sip_client_ip,
                    udp_sip_client_port, udp_sip_server_port, write_queue)


def select_loop():
    """
    Continuously checks for data to read and room to write
    and informs call state machines of activity.
    """

    global nonce

    while True:
        readable, writeable, in_error = select.select(sockets, sockets, sockets, 5)

        # this is how we read
        if readable.count(udp_sip_sock):
            data, addr = udp_sip_sock.recvfrom(1024)

            print "received from", addr, ":\n", data
            log.write("\n" + data + "\n\n")

            response = sip_parse(data)
            
            if response and 'Call-ID' in response: 
                if response['Call-ID'] in active_calls:
                    active_calls[response['Call-ID']].interpret(response)
                else:
                    new_call(response, addr)

        if readable.count(udp_rtp_sock) and rtp_dst_addr:
            data, addr = udp_rtp_sock.recvfrom(1024)

            print "\nRTP received from", addr, ":\n", data

        # this is how we write
        if writeable.count(udp_sip_sock) and len(write_queue):
            packet = write_queue.popleft()

            print "\nwriting:\n" + packet + "\n\n"
            log.write('\n' + packet + "\n\n")

            udp_sip_sock.sendto(packet, (host, udp_sip_server_port))

        if writeable.count(udp_rtp_sock) and rtp_dst_addr and rtp_dst_port:
            
            #udp_rtp_sock.sendto("REXFENLEY", (rtp_dst_addr, rtp_dst_port))
            udp_rtp_sock.send(str(rtp_header) + "REXFENLEY")
            sleep(.05)

            # print "\n\nREXFENLEY\n\n"

        # this is why im hot
        if in_error.count(udp_sip_sock):
            print "error: udp_sip_sock", udp_sip_sock.error
            exit()

        if in_error.count(udp_rtp_sock):
            print "error: udp_rtp_sock", udp_rtp_sock.error
            exit()

        if bye_triggered:
            print "\nGood Bye\n"
            udp_rtp_sock.close()
            udp_sip_sock.close()
            log.close()
            del sockets[1]
            exit()


select_loop()

log.close()
#tn.close()
