//
//  net_tcp.h
//  sRTP
//
//  Created by Steve McFarlin on 8/5/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#ifndef _NET_TCP
#define _NET_TCP

typedef struct _socket_tcp socket_tcp;

socket_tcp *tcp_init(int socket_fd, int ttl, int mode);
void		tcp_exit(socket_tcp *s);

/*!
 @abstract Read a RTP packet over a RTSP TCP channel.
 @discusson
 
 This reads a packet over a RTSP TCP channel. If the first character in the 
 read is not '$' then the RTSP reply is removed from the stream. Future 
 implementation may call a user provided callback in order to give client 
 code access to the reply.
 
 If the supplied buffer is smaller then the RTP packet then this method will
 return -1. The header will be in the first 4 bytes of the buffer. You need 
 to read out the packet using another function, as any subsequent call to the 
 without doing so will cause this function to fail.
 
 On success this function fills the buffer with the RTSP interleave header
 plus the RTP packet. The first 4 bytes are the RTSP interleave header. The
 returned size does not include the header.
 
 @param s The socket structure.
 @param buffer
 @param buflen
 @result int The size of the RTP packet.
 
 */

int tcp_recv(socket_tcp *s, char *buffer, int buflen, uint8_t *channel);
int tcp_send(socket_tcp *s, int channel, char *buffer, int buflen);

const char *tcp_host_addr(socket_tcp *s);
int         tcp_fd(socket_tcp *s);

int         tcp_select_read(socket_tcp *s, struct timeval *timeout);
int         tcp_select_write(socket_tcp *s, struct timeval *timeout);
void		tcp_fd_zero(socket_tcp *s);
void        tcp_fd_set(socket_tcp *s);
int         tcp_fd_isset(socket_tcp *s);

#endif