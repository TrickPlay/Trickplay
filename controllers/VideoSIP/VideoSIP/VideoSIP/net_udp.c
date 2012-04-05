/*
 * FILE:     net_udp.c
 * AUTHOR:   Colin Perkins 
 * MODIFIED: Orion Hodson, Piers O'Hanlon, Kristian Hasler
 * 
 * Copyright (c) 1998-2000 University College London
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, is permitted provided that the following conditions 
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the Computer Science
 *      Department at University College London
 * 4. Neither the name of the University nor of the Department may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* If this machine supports IPv6 the symbol HAVE_IPv6 should */
/* be defined in either config_unix.h or config_win32.h. The */
/* appropriate system header files should also be included   */
/* by those files.                                           */

#include "config_unix.h"
#include "debug.h"
#include "memory.h"
#include "inet_pton.h"
#include "net_udp.h"
#include "net_common.h"

#ifdef NEED_ADDRINFO_H
#include "addrinfo.h"
#endif


struct _socket_udp {
	int			mode;	/* IPv4 or IPv6 */
	char		*addr;
	uint16_t	rx_port;
	uint16_t	tx_port;
	ttl_t	 	ttl;
	fd_t	 	fd;
	struct in_addr	 addr4;
#ifdef HAVE_IPv6
	struct in6_addr	 addr6;
#endif /* HAVE_IPv6 */
};


#define SETSOCKOPT setsockopt


/*****************************************************************************/
/* Support functions...                                                      */
/*****************************************************************************/


#ifdef NEED_IN6_IS_ADDR_MULTICAST
#define IN6_IS_ADDR_MULTICAST(addr) ((addr)->s6_addr[0] == 0xffU)
#endif

#if defined(NEED_IN6_IS_ADDR_UNSPECIFIED) && defined(MUSICA_IPV6)
#define IN6_IS_ADDR_UNSPECIFIED(addr) IS_UNSPEC_IN6_ADDR(*addr)
#endif



/*****************************************************************************/
/* IPv4 specific functions...                                                */
/*****************************************************************************/


static socket_udp *udp_init4(const char *addr, const char *iface, uint16_t rx_port, uint16_t tx_port, int ttl)
{
	int                 	 reuse = 1, udpbufsize=131072;
	struct sockaddr_in  	 s_in;
	struct in_addr		 iface_addr;

	socket_udp         	*s = (socket_udp *)malloc(sizeof(socket_udp));
	s->mode    = IPv4;
	s->addr    = NULL;
	s->rx_port = rx_port;
	s->tx_port = tx_port;
	s->ttl     = ttl;
	if (inet_pton(AF_INET, addr, &s->addr4) != 1) {
		struct hostent *h = gethostbyname(addr);
		if (h == NULL) {
			socket_error("UDP: Can't resolve IP address for %s", addr);
                        free(s);
			return NULL;
		}
		memcpy(&(s->addr4), h->h_addr_list[0], sizeof(s->addr4));
	}
	if (iface != NULL) {
		if (inet_pton(AF_INET, iface, &iface_addr) != 1) {
			debug_msg("Illegal interface specification\n");
                        free(s);
			return NULL;
		}
	} else {
		iface_addr.s_addr = 0;
	}
	s->fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (s->fd < 0) {
		socket_error("socket");
		return NULL;
	}
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_SNDBUF, (char *) &udpbufsize, sizeof(udpbufsize)) != 0) {
		socket_error("setsockopt SO_SNDBUF");
		return NULL;
	}
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_RCVBUF, (char *) &udpbufsize, sizeof(udpbufsize)) != 0) {
		socket_error("setsockopt SO_RCVBUF");
		return NULL;
	}
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_REUSEADDR, (char *) &reuse, sizeof(reuse)) != 0) {
		socket_error("setsockopt SO_REUSEADDR");
		return NULL;
	}
#ifdef SO_REUSEPORT
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_REUSEPORT, (char *) &reuse, sizeof(reuse)) != 0) {
		socket_error("setsockopt SO_REUSEPORT");
		return NULL;
	}
#endif
	s_in.sin_family      = AF_INET;
	s_in.sin_addr.s_addr = INADDR_ANY;
	s_in.sin_port        = htons(rx_port);
	if (bind(s->fd, (struct sockaddr *) &s_in, sizeof(s_in)) != 0) {
		socket_error("bind");
		return NULL;
	}
	if (IN_MULTICAST(ntohl(s->addr4.s_addr))) {
		char            loop = 1;
		struct ip_mreq  imr;
		
		imr.imr_multiaddr.s_addr = s->addr4.s_addr;
		imr.imr_interface.s_addr = iface_addr.s_addr;
		
		if (SETSOCKOPT(s->fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *) &imr, sizeof(struct ip_mreq)) != 0) {
			socket_error("setsockopt IP_ADD_MEMBERSHIP");
			return NULL;
		}

		if (SETSOCKOPT(s->fd, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)) != 0) {
			socket_error("setsockopt IP_MULTICAST_LOOP");
			return NULL;
		}

		if (SETSOCKOPT(s->fd, IPPROTO_IP, IP_MULTICAST_TTL, (char *) &s->ttl, sizeof(s->ttl)) != 0) {
			socket_error("setsockopt IP_MULTICAST_TTL");
			return NULL;
		}
		if (iface_addr.s_addr != 0) {
			if (SETSOCKOPT(s->fd, IPPROTO_IP, IP_MULTICAST_IF, (char *) &iface_addr, sizeof(iface_addr)) != 0) {
				socket_error("setsockopt IP_MULTICAST_IF");
				return NULL;
			}
		}
	}
        s->addr = strdup(addr);
	return s;
}

static void udp_exit4(socket_udp *s)
{
	if (IN_MULTICAST(ntohl(s->addr4.s_addr))) {
		struct ip_mreq  imr;
		imr.imr_multiaddr.s_addr = s->addr4.s_addr;
		imr.imr_interface.s_addr = INADDR_ANY;
		if (SETSOCKOPT(s->fd, IPPROTO_IP, IP_DROP_MEMBERSHIP, (char *) &imr, sizeof(struct ip_mreq)) != 0) {
			socket_error("setsockopt IP_DROP_MEMBERSHIP");
			abort();
		}
		debug_msg("Dropped membership of multicast group\n");
	}
	close(s->fd);
        free(s->addr);
	free(s);
}

static inline int 
udp_send4(socket_udp *s, char *buffer, int buflen)
{
	struct sockaddr_in	s_in;
	
	assert(s != NULL);
	assert(s->mode == IPv4);
	assert(buffer != NULL);
	assert(buflen > 0);
	
	s_in.sin_family      = AF_INET;
	s_in.sin_addr.s_addr = s->addr4.s_addr;
	s_in.sin_port        = htons(s->tx_port);
    
    //sendto(s->fd, "REXFENLEY", 10, 0, (struct sockaddr *) &s_in, sizeof(s_in));
    //char str[INET_ADDRSTRLEN];
    //fprintf(stderr, "Address: %s\n", inet_ntop(AF_INET, &(s_in.sin_addr), str, INET_ADDRSTRLEN));
    //fprintf(stderr, "Port: %d\nNetwork Port: %d\n", s->tx_port, s_in.sin_port);
	
	return sendto(s->fd, buffer, buflen, 0, (struct sockaddr *) &s_in, sizeof(s_in));
}


static inline int 
udp_sendv4(socket_udp *s, struct iovec *vector, int count)
{
	struct msghdr		msg;
	struct sockaddr_in	s_in;
	
	assert(s != NULL);
	assert(s->mode == IPv4);
	
	s_in.sin_family      = AF_INET;
	s_in.sin_addr.s_addr = s->addr4.s_addr;
	s_in.sin_port        = htons(s->tx_port);

	msg.msg_name       = (caddr_t) &s_in;
	msg.msg_namelen    = sizeof(s_in);
	msg.msg_iov        = vector;
	msg.msg_iovlen     = count;
#ifdef NDEF	/* Solaris does something different here... can we just ignore these fields? [csp] */
	msg.msg_control    = 0;
	msg.msg_controllen = 0;
	msg.msg_flags      = 0;
#endif
	return sendmsg(s->fd, &msg, 0);
}

/*
static const char *udp_host_addr4(void)
{
	static char    		 hname[MAXHOSTNAMELEN];
	struct hostent 		*hent;
	struct in_addr  	 iaddr;
	
	if (gethostname(hname, MAXHOSTNAMELEN) != 0) {
		debug_msg("Cannot get hostname!");
		abort();
	}
	hent = gethostbyname(hname);
	if (hent == NULL) {
		socket_error("Can't resolve IP address for %s", hname);
		return NULL;
	}
	assert(hent->h_addrtype == AF_INET);
	memcpy(&iaddr.s_addr, hent->h_addr, sizeof(iaddr.s_addr));
	strncpy(hname, inet_ntoa(iaddr), MAXHOSTNAMELEN);
	return (const char*)hname;
}
*/

/*****************************************************************************/
/* IPv6 specific functions...                                                */
/*****************************************************************************/

 
static socket_udp *udp_init6(const char *addr, const char *iface, uint16_t rx_port, uint16_t tx_port, int ttl)
{
#ifdef HAVE_IPv6
	int                 reuse = 1;
	struct sockaddr_in6 s_in;
	socket_udp         *s = (socket_udp *) malloc(sizeof(socket_udp));
	s->mode    = IPv6;
	s->addr    = NULL;
	s->rx_port = rx_port;
	s->tx_port = tx_port;
	s->ttl     = ttl;
	
	if (iface != NULL) {
		debug_msg("Not yet implemented\n");
		abort();
	}

	if (inet_pton(AF_INET6, addr, &s->addr6) != 1) {
		/* We should probably try to do a DNS lookup on the name */
		/* here, but I'm trying to get the basics going first... */
		debug_msg("IPv6 address conversion failed\n");
                free(s);
		return NULL;	
	}
	s->fd = socket(AF_INET6, SOCK_DGRAM, 0);
	if (s->fd < 0) {
		socket_error("socket");
		return NULL;
	}
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_REUSEADDR, (char *) &reuse, sizeof(reuse)) != 0) {
		socket_error("setsockopt SO_REUSEADDR");
		return NULL;
	}
#ifdef SO_REUSEPORT
	if (SETSOCKOPT(s->fd, SOL_SOCKET, SO_REUSEPORT, (char *) &reuse, sizeof(reuse)) != 0) {
		socket_error("setsockopt SO_REUSEPORT");
		return NULL;
	}
#endif
	
	memset((char *)&s_in, 0, sizeof(s_in));
	s_in.sin6_family = AF_INET6;
	s_in.sin6_port   = htons(rx_port);
#ifdef HAVE_SIN6_LEN
	s_in.sin6_len    = sizeof(s_in);
#endif
	s_in.sin6_addr = in6addr_any;
	if (bind(s->fd, (struct sockaddr *) &s_in, sizeof(s_in)) != 0) {
		socket_error("bind");
		return NULL;
	}
	
	if (IN6_IS_ADDR_MULTICAST(&(s->addr6))) {
		unsigned int      loop = 1;
		struct ipv6_mreq  imr;
#ifdef MUSICA_IPV6
		imr.i6mr_interface = 1;
		imr.i6mr_multiaddr = s->addr6;
#else
		imr.ipv6mr_multiaddr = s->addr6;
		imr.ipv6mr_interface = 0;
#endif
		
		if (SETSOCKOPT(s->fd, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, (char *) &imr, sizeof(imr)) != 0) {
			socket_error("setsockopt IPV6_ADD_MEMBERSHIP");
			return NULL;
		}
		
		if (SETSOCKOPT(s->fd, IPPROTO_IPV6, IPV6_MULTICAST_LOOP, (char *) &loop, sizeof(loop)) != 0) {
			socket_error("setsockopt IPV6_MULTICAST_LOOP");
			return NULL;
		}
		if (SETSOCKOPT(s->fd, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, (char *) &ttl, sizeof(ttl)) != 0) {
			socket_error("setsockopt IPV6_MULTICAST_HOPS");
			return NULL;
		}
	}

	assert(s != NULL);

        s->addr = strdup(addr);
	return s;
#else
	UNUSED(addr);
	UNUSED(iface);
	UNUSED(rx_port);
	UNUSED(tx_port);
	UNUSED(ttl);
	return NULL;
#endif
}

static void udp_exit6(socket_udp *s)
{
#ifdef HAVE_IPv6
	if (IN6_IS_ADDR_MULTICAST(&(s->addr6))) {
		struct ipv6_mreq  imr;
#ifdef MUSICA_IPV6
		imr.i6mr_interface = 1;
		imr.i6mr_multiaddr = s->addr6;
#else
		imr.ipv6mr_multiaddr = s->addr6;
		imr.ipv6mr_interface = 0;
#endif
		
		if (SETSOCKOPT(s->fd, IPPROTO_IPV6, IPV6_DROP_MEMBERSHIP, (char *) &imr, sizeof(struct ipv6_mreq)) != 0) {
			socket_error("setsockopt IPV6_DROP_MEMBERSHIP");
			abort();
		}
	}
	close(s->fd);
        free(s->addr);
	free(s);
#else
	UNUSED(s);
#endif  /* HAVE_IPv6 */
}

static int udp_send6(socket_udp *s, char *buffer, int buflen)
{
#ifdef HAVE_IPv6
	struct sockaddr_in6	s_in;
	
	assert(s != NULL);
	assert(s->mode == IPv6);
	assert(buffer != NULL);
	assert(buflen > 0);
	
	memset((char *)&s_in, 0, sizeof(s_in));
	s_in.sin6_family = AF_INET6;
	s_in.sin6_addr   = s->addr6;
	s_in.sin6_port   = htons(s->tx_port);
#ifdef HAVE_SIN6_LEN
	s_in.sin6_len    = sizeof(s_in);
#endif
	return sendto(s->fd, buffer, buflen, 0, (struct sockaddr *) &s_in, sizeof(s_in));
#else
	UNUSED(s);
	UNUSED(buffer);
	UNUSED(buflen);
	return -1;
#endif
}


static int 
udp_sendv6(socket_udp *s, struct iovec *vector, int count)
{
#ifdef HAVE_IPv6
	struct msghdr		msg;
	struct sockaddr_in6	s_in;
	
	assert(s != NULL);
	assert(s->mode == IPv6);
	
	memset((char *)&s_in, 0, sizeof(s_in));
	s_in.sin6_family = AF_INET6;
	s_in.sin6_addr   = s->addr6;
	s_in.sin6_port   = htons(s->tx_port);
#ifdef HAVE_SIN6_LEN
	s_in.sin6_len    = sizeof(s_in);
#endif
	msg.msg_name       = &s_in;
	msg.msg_namelen    = sizeof(s_in);
	msg.msg_iov        = vector;
	msg.msg_iovlen     = count;
#ifdef HAVE_MSGHDR_MSGCTRL  
	msg.msg_control    = 0;
	msg.msg_controllen = 0;
	msg.msg_flags      = 0;
#endif
	return sendmsg(s->fd, &msg, 0);
#else
	UNUSED(s);
	UNUSED(vector);
	UNUSED(count);
	return -1;
#endif
}

/*
static const char *udp_host_addr6(socket_udp *s)
{
#ifdef HAVE_IPv6
	static char		 hname[MAXHOSTNAMELEN];
	int 			 gai_err, newsock;
	struct addrinfo 	 hints, *ai;
	struct sockaddr_in6 	 local, addr6;
	int len = sizeof(local), result = 0;

	newsock=socket(AF_INET6, SOCK_DGRAM,0);
    memset ((char *)&addr6, 0, len);
    addr6.sin6_family = AF_INET6;
#ifdef HAVE_SIN6_LEN
    addr6.sin6_len    = len;
#endif
    bind (newsock, (struct sockaddr *) &addr6, len);
    addr6.sin6_addr = s->addr6;
    addr6.sin6_port = htons (s->rx_port);
    connect (newsock, (struct sockaddr *) &addr6, len);

    memset ((char *)&local, 0, len);
	if ((result = getsockname(newsock,(struct sockaddr *)&local, &len)) < 0){
		local.sin6_addr = in6addr_any;
		local.sin6_port = 0;
		debug_msg("getsockname failed\n");
	}

	close (newsock);

	if (IN6_IS_ADDR_UNSPECIFIED(&local.sin6_addr) || IN6_IS_ADDR_MULTICAST(&local.sin6_addr)) {
		if (gethostname(hname, MAXHOSTNAMELEN) != 0) {
			debug_msg("gethostname failed\n");
			abort();
		}
		
		hints.ai_protocol  = 0;
		hints.ai_flags     = 0;
		hints.ai_family    = AF_INET6;
		hints.ai_socktype  = SOCK_DGRAM;
		hints.ai_addrlen   = 0;
		hints.ai_canonname = NULL;
		hints.ai_addr      = NULL;
		hints.ai_next      = NULL;

		if ((gai_err = getaddrinfo(hname, NULL, &hints, &ai))) {
			debug_msg("getaddrinfo: %s: %s\n", hname, gai_strerror(gai_err));
			abort();
		}
		
		if (inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)(ai->ai_addr))->sin6_addr), hname, MAXHOSTNAMELEN) == NULL) {
			debug_msg("inet_ntop: %s: \n", hname);
			abort();
		}
		freeaddrinfo(ai);
		return (const char*)hname;
	}
	if (inet_ntop(AF_INET6, &local.sin6_addr, hname, MAXHOSTNAMELEN) == NULL) {
		debug_msg("inet_ntop: %s: \n", hname);
		abort();
	}
	return (const char*)hname;
#else  // HAVE_IPv6
	UNUSED(s);
	return "::";	// The unspecified address... 
#endif // HAVE_IPv6 
}
 */
	
/*****************************************************************************/
/* Generic functions, which call the appropriate protocol specific routines. */
/*****************************************************************************/

/**
 * udp_init:
 * @addr: character string containing an IPv4 or IPv6 network address.
 * @rx_port: receive port.
 * @tx_port: transmit port.
 * @ttl: time-to-live value for transmitted packets.
 *
 * Creates a session for sending and receiving UDP datagrams over IP
 * networks. 
 *
 * Returns: a pointer to a valid socket_udp structure on success, NULL otherwise.
 **/
socket_udp *udp_init(const char *addr, uint16_t rx_port, uint16_t tx_port, int ttl)
{
	return udp_init_if(addr, NULL, rx_port, tx_port, ttl);
}

/**
 * udp_init_if:
 * @addr: character string containing an IPv4 or IPv6 network address.
 * @iface: character string containing an interface name.
 * @rx_port: receive port.
 * @tx_port: transmit port.
 * @ttl: time-to-live value for transmitted packets.
 *
 * Creates a session for sending and receiving UDP datagrams over IP
 * networks.  The session uses @iface as the interface to send and
 * receive datagrams on.
 * 
 * Return value: a pointer to a socket_udp structure on success, NULL otherwise.
 **/
socket_udp *udp_init_if(const char *addr, const char *iface, uint16_t rx_port, uint16_t tx_port, int ttl)
{
	socket_udp *res;
	
	if (strchr(addr, ':') == NULL) {
		res = udp_init4(addr, iface, rx_port, tx_port, ttl);
	} else {
		res = udp_init6(addr, iface, rx_port, tx_port, ttl);
	}
	return res;
}

/**
 * udp_exit:
 * @s: UDP session to be terminated.
 *
 * Closes UDP session.
 * 
 **/
void udp_exit(socket_udp *s)
{
    switch(s->mode) {
    case IPv4 : udp_exit4(s); break;
    case IPv6 : udp_exit6(s); break;
    default   : abort();
    }
}

/**
 * udp_send:
 * @s: UDP session.
 * @buffer: pointer to buffer to be transmitted.
 * @buflen: length of @buffer.
 * 
 * Transmits a UDP datagram containing data from @buffer.
 * 
 * Return value: 0 on success, -1 on failure.
 **/
int udp_send(socket_udp *s, char *buffer, int buflen)
{
	switch (s->mode) {
	case IPv4 : return udp_send4(s, buffer, buflen);
	case IPv6 : return udp_send6(s, buffer, buflen);
	default   : abort(); /* Yuk! */
	}
	return -1;
}



int         
udp_sendv(socket_udp *s, struct iovec *vector, int count)
{
	switch (s->mode) {
	case IPv4 : return udp_sendv4(s, vector, count);
	case IPv6 : return udp_sendv6(s, vector, count);
	default   : abort(); /* Yuk! */
	}
	return -1;
}


/**
 * udp_recv:
 * @s: UDP session.
 * @buffer: buffer to read data into.
 * @buflen: length of @buffer.
 * 
 * Reads from datagram queue associated with UDP session.
 *
 * Return value: number of bytes read, returns 0 if no data is available.
 **/
int udp_recv(socket_udp *s, char *buffer, int buflen)
{
	/* Reads data into the buffer, returning the number of bytes read.   */
	/* If no data is available, this returns the value zero immediately. */
	/* Note: since we don't care about the source address of the packet  */
	/* we receive, this function becomes protocol independent.           */
	int		len;

	assert(buffer != NULL);
	assert(buflen > 0);

	len = recvfrom(s->fd, buffer, buflen, 0, 0, 0);
	if (len > 0) {
		return len;
	}
	if (errno != ECONNREFUSED) {
		socket_error("recvfrom");
	}
	return 0;
}

static fd_set	rfd;
static fd_t	max_fd;

/**
 * udp_fd_zero:
 * 
 * Clears file descriptor from set associated with UDP sessions (see select(2)).
 * 
 **/
void udp_fd_zero(void)
{
	FD_ZERO(&rfd);
	max_fd = 0;
}

/**
 * udp_fd_set:
 * @s: UDP session.
 * 
 * Adds file descriptor associated of @s to set associated with UDP sessions.
 **/
void udp_fd_set(socket_udp *s)
{
	FD_SET(s->fd, &rfd);
	if (s->fd > (fd_t)max_fd) {
		max_fd = s->fd;
	}
}

/**
 * udp_fd_isset:
 * @s: UDP session.
 * 
 * Checks if file descriptor associated with UDP session is ready for
 * reading.  This function should be called after udp_select().
 *
 * Returns: non-zero if set, zero otherwise.
 **/
int udp_fd_isset(socket_udp *s)
{
	return FD_ISSET(s->fd, &rfd);
}

/**
 * udp_select:
 * @timeout: maximum period to wait for data to arrive.
 * 
 * Waits for data to arrive for UDP sessions.
 * 
 * Return value: number of UDP sessions ready for reading.
 **/
int udp_select(struct timeval *timeout)
{
	return select(max_fd + 1, &rfd, NULL, NULL, timeout);
}

/**
 * udp_host_addr:
 * @s: UDP session.
 * 
 * Return value: character string containing network address
 * associated with session @s.
 **/
const char *udp_host_addr(socket_udp *s)
{
	switch (s->mode) {
	case IPv4 : return host_addr4();
	case IPv6 : return host_addr6();
	default   : abort();
	}
	return NULL;
}

/**
 * udp_fd:
 * @s: UDP session.
 * 
 * This function allows applications to apply their own socketopt()'s
 * and ioctl()'s to the UDP session.
 * 
 * Return value: file descriptor of socket used by session @s.
 **/
int udp_fd(socket_udp *s)
{
	if (s && s->fd > 0) {
		return s->fd;
	} 
	return 0;
}


