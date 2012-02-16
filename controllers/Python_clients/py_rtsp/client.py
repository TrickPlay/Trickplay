import getpass
import sys
import socket
import select
import telnetlib

describe_rtsp = "DESCRIBE rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
CSeq: 1\r\n\r\n"

options_rtsp = "OPTIONS rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
CSeq: 1\r\n\r\n"
#User-Agent: QuickTime/7.6.6 (qtver=7.6.6;cpu=IA32;os=Mac 10.6.8)\r\n\
#Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\r\n"

announce_rtsp = "ANNOUNCE rtsp://tpmini.internal.trickplay.com:554/sample.rtp RTSP/1.0\r\n\
Cseq: 2\r\n\
Content-Length: 444\r\n\
Content-Type: application/sdp\r\n\
\r\n"

sdp_header = "v=0\r\n\
o=- 0 0 IN IP4 127.0.0.1\r\n\
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
b=AS:64\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n\
a=control:streamid=1"

udp_sdp2 = "v=0\r\n\
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

udp_announce2 = "ANNOUNCE rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
Cseq: 1\r\n\
Content-Length: 601\r\n\
Content-Type: application/sdp\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
\r\n"

announce_rtsp_auth = "ANNOUNCE rtsp://tpmini.internal.trickplay.com:554/sample.rtp RTSP/1.0\r\n\
Cseq: 3\r\n\
Content-Length: 444\r\n\
Content-Type: application/sdp\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
\r\n"

setup_rtsp = "SETUP rtsp://tpmini.internal.trickplay.com:554/sample.rtp/streamid=0 RTSP/1.0\r\n\
Transport: RTP/AVP/TCP;unicast;interleaved=0-1;mode=receive\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 4\r\n\
\r\n"



quicktime_announce = "ANNOUNCE rtsp://tpmini.internal.trickplay.com:554/sample.sdp RTSP/1.0\r\n\
Cseq: 1\r\n\
Content-Length: 595\r\n\
Content-Type: application/sdp\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
\r\n"

quicktime_options = "OPTIONS rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
CSeq: 2\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\r\n"
#User-Agent: QuickTime/7.6.6 (qtver=7.6.6;cpu=IA32;os=Mac 10.6.8)\r\n\

quicktime_sdp = "v=0\r\n\
o=- 192 2411882437 IN IP4 127.0.0.0\r\n\
s=QuickTime\r\n\
c=IN IP4 10.0.190.5\r\n\
t=0 0\r\n\
a=range:npt=now-\r\n\
a=isma-compliance:2,2.0,2\r\n\
m=audio 0 RTP/AVP 96\r\n\
b=AS:16\r\n\
a=rtpmap:96 mpeg4-generic/22050/1\r\n\
a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n\
a=mpeg4-esid:101\r\n\
a=control:trackid=1\r\n\
m=video 0 RTP/AVP 97\r\n\
b=AS:1372\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;profile-level-id=4D401E;sprop-parameter-sets=J01AHqkYFAe2ANQYBBrbCte98BA=,KN4JF6A=\r\n\
a=mpeg4-esid:201\r\n\
a=cliprect:0,0,480,640\r\n\
a=framesize:97 640-480\r\n\
a=control:trackid=2\r\n"


quicktime_setup = "SETUP rtsp://tpmini.internal.trickplay.com:554/sample.sdp/trackid=2 RTSP/1.0\r\n\
Transport: RTP/AVP/TCP;unicast;mode=record;interleaved=2-3\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 3\r\n\
\r\n"


quicktime_record = "RECORD rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 4\r\n"



new_announce = "ANNOUNCE rtsp://tpmini.internal.trickplay.com:554/sample.sdp RTSP/1.0\r\n\
Cseq: 1\r\n\
Content-Length: 461\r\n\
Content-Type: application/sdp\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
\r\n"

new_sdp = "v=0\r\n\
o=- 0 0 IN IP4 127.0.0.1\r\n\
s=Livu\r\n\
c=IN IP4 tpmini.internal.trickplay.com\r\n\
t=0 0\r\n\
a=tool:Livu RTP\r\n\
a=range:npt=now-\r\n\
m=audio 0 RTP/AVP 96\r\n\
b=AS:64\r\n\
a=rtpmap:96 MPEG4-GENERIC/44100/1\r\n\
a=fmtp:96 profile-level-id=1;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1208\r\n\
a=control:streamid=0\r\n\
m=video 0 RTP/AVP 97\r\n\
b=AS:64\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n\
a=control:streamid=1"

#a=range:npt=now-\r\n\
#a=isma-compliance:2,2.0,2\r\n\
#m=audio 0 RTP/AVP 96\r\n\
#b=AS:16\r\n\
#a=rtpmap:96 mpeg4-generic/22050/1\r\n\
#a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n\
#a=mpeg4-esid:101\r\n\
#a=control:trackid=1\r\n\
#m=video 0 RTP/AVP 97\r\n\
#b=AS:1372\r\n\
#a=rtpmap:97 H264/90000\r\n\
#a=fmtp:97 packetization-mode=1;profile-level-id=4D401E;sprop-parameter-sets=J01AHqkYFAe2ANQYBBrbCte98BA=,KN4JF6A=\r\n\
#a=mpeg4-esid:201\r\n\
#a=cliprect:0,0,480,640\r\n\
#a=framesize:97 640-480\r\n\
#a=control:trackid=2\r\n"

new_options = "OPTIONS rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
CSeq: 2\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\r\n"

new_setup = "SETUP rtsp://tpmini.internal.trickplay.com:554/sample.rtp/streamid=0 RTSP/1.0\r\n\
Transport: RTP/AVP/TCP;unicast;mode=record;interleaved=2-3\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 3\r\n\
\r\n"

new_record = "RECORD rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 4\r\n"




udp_announce = "ANNOUNCE rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
Cseq: 1\r\n\
Content-Length: 601\r\n\
Content-Type: application/sdp\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
\r\n"

udp_options = "OPTIONS rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
CSeq: 2\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\r\n"
#User-Agent: QuickTime/7.6.6 (qtver=7.6.6;cpu=IA32;os=Mac 10.6.8)\r\n\

udp_sdp = "v=0\r\n\
o=- 536 3212164818 IN IP4 127.0.0.0\r\n\
s=QuickTime\r\n\
c=IN IP4 10.0.190.5\r\n\
t=0 0\r\n\
a=range:npt=now-\r\n\
a=isma-compliance:2,2.0,2\r\n\
m=audio 6970 RTP/AVP 96\r\n\
b=AS:16\r\n\
a=rtpmap:96 mpeg4-generic/22050/1\r\n\
a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n\
a=mpeg4-esid:101\r\n\
a=control:trackid=1\r\n\
m=video 6790 RTP/AVP 97\r\n\
b=AS:1372\r\n\
a=rtpmap:97 H264/90000\r\n\
a=fmtp:97 packetization-mode=1;profile-level-id=4D401E;sprop-parameter-sets=J01AHqkYFAe2ANQYBBrbCte98BA=,KN4JF6A=\r\n\
a=mpeg4-esid:201\r\n\
a=cliprect:0,0,480,640\r\n\
a=framesize:97 640-480\r\n\
a=control:trackid=2\r\n"


udp_setup = "SETUP rtsp://tpmini.internal.trickplay.com/sample.sdp/trackid=2 RTSP/1.0\r\n\
Transport: RTP/AVP;unicast;client_port=6970-6971;mode=record\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 3\r\n\
\r\n"


udp_record = "RECORD rtsp://tpmini.internal.trickplay.com/sample.sdp RTSP/1.0\r\n\
Authorization: Basic YnJvYWRjYXN0OnNheXdoYXQ=\r\n\
CSeq: 4\r\n"


#####################################


host = socket.gethostbyname("tpmini.internal.trickplay.com")
rtsp_port = 554
udp_rtp_server_port = 0
udp_rtp_client_port = 6970
udp_rtcp_client_port = 6971

fd = open("rtsp.log", "w")
tn = telnetlib.Telnet(host, rtsp_port)

sock = tn.get_socket()
print "Source: "
print sock.getsockname()
print "Destination: "
print sock.getpeername()
print "\n"

udp_rtp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_rtp_sock.bind(("", udp_rtp_client_port))

frames = []

session = ""

def rtsp_send(packet):
    """Send rtsp request, log request and response"""
    print packet
    print "\n"

    fd.write(packet)
    fd.write("\n\n")
    tn.write(packet)

    response = tn.read_until("\r\n\r\n", 5)

    global session
    global udp_rtp_server_port
    if response.find("Session") >= 0:
        begin = response.find("Session")
        end = response.find("\r", begin)
        session = response[begin:end]

    if response.find("server_port") >= 0:
        begin = response.find("server_port")
        start = response.find("=", begin)
        end = response.find("-", begin)
        server_port = response[start+1:end]
        print "server_port: " + server_port
        udp_rtp_server_port = int(server_port)

    fd.write(response)
    fd.write("\n\n")

    print response
    print "\n"


def get_frames():
    """Store all the frames into a list"""
    frames_fd = open("frames_rex_new.bin", "rb")

    all_frames = frames_fd.read()

    global frames
    frames = all_frames.split("REXFENLEY\x00")

    frames_fd.close()


def rtp_send():
    """Send rtp frames over and over"""
    global frames

    counter = 0
    
    while True:
        for frame in frames[0:]:
            print "writing a frame"
            tn.write(frame)
            #print tn.read_until("\r\n\r\n", 1)
            print counter
            counter = counter + 1
    
    print tn.read_until("\r\n\r\n", 5)


def udp_rtsp_session():
    """This sets up a UDP RTSP session and sends frames via UDP"""

    global udp_rtp_server_port
    global udp_rtp_client_port
    global udp_rtcp_client_port
    global udp_rtp_sock
    global frames

    udp_rtcp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_rtcp_sock.bind(("", udp_rtcp_client_port))

    rtsp_send(udp_announce2 + udp_sdp2)
    ##rtsp_send(udp_announce + udp_sdp)
    rtsp_send(udp_options)
    rtsp_send(udp_setup)
    rtsp_send(udp_record + session + "\r\n\r\n")

    index = 1
    counter = 1

    while True:
        readable, writeable, in_error = select.select([udp_rtcp_sock], [udp_rtp_sock], [], 5)

        if readable.count(udp_rtcp_sock):
            data, addr = udp_rtcp_sock.recvfrom(1024)
            print "received from", addr, ":", data

        if writeable.count(udp_rtp_sock):
            udp_rtp_sock.sendto(frames[index], (host, udp_rtp_server_port))
            index += 1

        if index >= len(frames):
            index = 1
            #print counter
            #counter += 1
            #print "wrote all frames"
    



#rtsp_send(describe_rtsp)
#rtsp_send(options_rtsp)
#rtsp_send(announce_rtsp + sdp_header)
#rtsp_send(announce_rtsp_auth + sdp_header)
#rtsp_send(setup_rtsp)

#rtsp_send(quicktime_announce + quicktime_sdp)
#rtsp_send(quicktime_options)
#rtsp_send(quicktime_setup)
#rtsp_send(quicktime_record + session + "\r\n\r\n")

#rtsp_send(new_announce + new_sdp)
#rtsp_send(new_options)
#rtsp_send(new_setup)
#rtsp_send(new_record + session + "\r\n\r\n")

#rtp_send()

get_frames()
udp_rtsp_session()

fd.close()
tn.close()
