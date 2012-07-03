//
//  net_common.h
//  sRTP
//
//  Created by Steve McFarlin on 8/5/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#ifndef NET_COMMON
#define NET_COMMON

//Forwards
struct in_addr;

#define IPv4	4
#define IPv6	6


#ifdef WIN2K_IPV6
const struct	in6_addr	in6addr_any = {IN6ADDR_ANY_INIT};
#endif

#ifdef WINXP_IPV6
const struct	in6_addr	in6addr_any = {IN6ADDR_ANY_INIT};
#endif

/* This is pretty nasty but it's the simplest way to get round */
/* the Detexis bug that means their MUSICA IPv6 stack uses     */
/* IPPROTO_IP instead of IPPROTO_IPV6 in setsockopt calls      */
/* We also need to define in6addr_any */
#ifdef  MUSICA_IPV6
#define	IPPROTO_IPV6	IPPROTO_IP
struct	in6_addr	in6addr_any = {IN6ADDR_ANY_INIT};

/* These DEF's are required as MUSICA's winsock6.h causes a clash with some of the 
 * standard ws2tcpip.h definitions (eg struct in_addr6).
 * Note: winsock6.h defines AF_INET6 as 24 NOT 23 as in winsock2.h - I have left it
 * set to the MUSICA value as this is used in some of their function calls. 
 */
//#define AF_INET6        23
#define IP_MULTICAST_LOOP      11 /*set/get IP multicast loopback */
#define	IP_MULTICAST_IF		9 /* set/get IP multicast i/f  */
#define	IP_MULTICAST_TTL       10 /* set/get IP multicast ttl */
#define	IP_MULTICAST_LOOP      11 /*set/get IP multicast loopback */
#define	IP_ADD_MEMBERSHIP      12 /* add an IP group membership */
#define	IP_DROP_MEMBERSHIP     13/* drop an IP group membership */

#define IN6_IS_ADDR_UNSPECIFIED(a) (((a)->s6_addr32[0] == 0) && \
((a)->s6_addr32[1] == 0) && \
((a)->s6_addr32[2] == 0) && \
((a)->s6_addr32[3] == 0))
struct ip_mreq {
	struct in_addr imr_multiaddr;	/* IP multicast address of group */
	struct in_addr imr_interface;	/* local IP address of interface */
};
#endif

#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff
#endif

int		inet_aton(const char *name, struct in_addr *addr);
void	socket_error(const char *msg, ...);
int     addr_valid(const char *addr);

const char *host_addr4_iphone(void);
const char *host_addr4(void);
const char *host_addr6(void);


#endif