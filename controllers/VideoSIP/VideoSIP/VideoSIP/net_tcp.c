//
//  net_tcp.c
//  sRTP
//
//  Created by Steve McFarlin on 8/5/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//
//  Modified: Rex Fenley

#include "config_unix.h"
#include "net_tcp.h"
#include "debug.h"
#include "memory.h"
#include "inet_pton.h"
#include "net_common.h"

#ifdef NEED_ADDRINFO_H
#include "addrinfo.h"
#endif


//TCP socket support
struct _socket_tcp {
	int			mode;	/* IPv4 or IPv6 */
	ttl_t	 	ttl;
	fd_t	 	fd;	
	fd_set		rfd, wfd;
	fd_t		max_fd;
};



socket_tcp *tcp_init(int socket_fd, int ttl, int mode) {
	
	socket_tcp *s = (socket_tcp *)malloc(sizeof(socket_tcp));
	
	s->fd = socket_fd;
	s->ttl = ttl;
	s->mode = mode;
	
	return s;
}

void tcp_exit(socket_tcp *s) {
	free(s);
}

int tcp_recv(socket_tcp *s, char *buffer, int buflen, uint8_t *channel) {
	ssize_t	len, len1, cr_count, pktsize;
	uint16_t *pi16;
	char *pbuff;
	char cb[4];
	
	assert(buffer != NULL);
	assert(buflen > 0);
	
	//We much check the first character. It is possible there
	//will be RTSP reply data in this stream
		
	len = recv(s->fd, &cb, 4, 0);
	if(len < 4)
		return 0; //we will be screwed at this point if we did read 3 bytes of the header.
	
	if(cb[0] != '$') {
		cr_count = 0;
		#warning This could go on forever.
		while(cr_count < 4) {
			len = recv(s->fd, &cb, 1, 0);
			
			if(len == 0) continue; //XXX: Should be do this?
#warning This is some idiotic code and unfortunately I have no idea what McFarlin was attempting
			if(cb == '\r' || cb == '\n') { cr_count++ ; }
			else { cr_count = 0; }
			printf("INFINITE LOOPING");
		}
		//TODO: WE should read out the RTSP reply message and send to a callback.
		printf("TCP Dumped RTP \n");
		return 0; 
	}
	
	*channel = cb[1];
	
	pi16 = (uint16_t*) &cb[2];
	pktsize = ntohs(*pi16);
	
	if(pktsize > buflen) {
		return -1;
	}
	
	pbuff = buffer;
	
	len1 = pktsize;
	while(len1 > 0) {
		len = recv(s->fd, pbuff, len1, 0);
		len1 -= len;
		pbuff += len;
	}
		
	return (int) pktsize;
}

static int tcp_send6(socket_tcp *s, char *buffer, int buflen)
{
#warning TCP send over IPv6 not implemented
    return -1;
}


static inline int 
tcp_send4(socket_tcp *s, char *buffer, size_t buflen)
{
	assert(s != NULL);
	assert(s->mode == IPv4);
	assert(buffer != NULL);
	assert(buflen > 0);
	
	return send(s->fd, buffer, buflen, 0);
}


int tcp_send(socket_tcp *s, int channel, char *buffer, int buflen) {
	/*switch (s->mode) {
		case IPv4 : return tcp_send4(s, buffer, buflen);
		case IPv6 : return tcp_send6(s, buffer, buflen);
		default   : abort(); // Yuk! 
	}
	return -1;
	 */
	
	//I tried using a stack buffer but it made no difference.
	
	assert(s != NULL);
	assert(s->mode == IPv4);
	assert(buffer != NULL);
	assert(buflen > 0);
	int ret = 0;
	char pb8[4];
	
	pb8[0] = '$';
	pb8[1] = channel;
	uint16_t *pb16 = (uint16_t*) &pb8[2];
	//printf("bufffer_len - tcp_hder_len = %u", buffer_len - tcp_hdr_len);
	*pb16 = htons(buflen);
	
	if( send(s->fd, pb8, 4, 0) == -1) return -1;
	ret = send(s->fd, buffer, buflen, 0);
	return ret;
}


//static fd_set	rfd, wfd;
static fd_t	max_fd;

/**
 * tcp_fd_zero:
 * 
 * Clears file descriptor from set associated with tcp sessions (see select(2)).
 * 
 **/
void tcp_fd_zero(socket_tcp *s)
{
	FD_ZERO(&s->rfd);
	FD_ZERO(&s->wfd);
	max_fd = 0;
}

/**
 * tcp_fd_set:
 * @s: tcp session.
 * 
 * Adds file descriptor associated of @s to set associated with tcp sessions.
 **/
void tcp_fd_set(socket_tcp *s)
{
	FD_SET(s->fd, &s->rfd);
	FD_SET(s->fd, &s->wfd);
	if (s->fd > (fd_t)max_fd) {
		max_fd = s->fd;
	}
}

/**
 * tcp_fd_isset:
 * @s: tcp session.
 * 
 * Checks if file descriptor associated with tcp session is ready for
 * reading.  This function should be called after tcp_select().
 *
 * Returns: non-zero if set, zero otherwise.
 **/
int tcp_fd_isset(socket_tcp *s)
{
	return FD_ISSET(s->fd, &s->rfd);
}

/**
 * tcp_select:
 * @timeout: maximum period to wait for data to arrive.
 * 
 * Waits for data to arrive for tcp sessions.
 * 
 * Return value: number of tcp sessions ready for reading.
 **/
int tcp_select_read(socket_tcp *s, struct timeval *timeout)
{
	return select(s->fd + 1, &s->rfd, NULL, NULL, timeout);
}

int tcp_select_write(socket_tcp *s, struct timeval *timeout)
{
	return select(s->fd + 1, NULL, &s->wfd, NULL, timeout);
}



/**
 * tcp_fd:
 * @s: tcp session.
 * 
 * This function allows applications to apply their own socketopt()'s
 * and ioctl()'s to the tcp session.
 * 
 * Return value: file descriptor of socket used by session @s.
 **/
int tcp_fd(socket_tcp *s)
{
	if (s && s->fd > 0) {
		return s->fd;
	} 
	return 0;
}


/**
 * udp_host_addr:
 * @s: UDP session.
 * 
 * Return value: character string containing network address
 * associated with session @s.
 **/
const char *tcp_host_addr(socket_tcp *s)
{
	switch (s->mode) {
		case IPv4 : return host_addr4();
		case IPv6 : return host_addr6();
		default   : abort();
	}
	return NULL;
}
