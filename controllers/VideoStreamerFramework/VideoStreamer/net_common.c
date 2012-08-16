//
//  net_common.c
//  sRTP
//
//  Created by Steve McFarlin on 8/5/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#include "net_common.h"
#include "config_unix.h"
#include "debug.h"
#include "memory.h"
#include "inet_pton.h"
#include <ifaddrs.h> 
#include <arpa/inet.h>



void socket_error(const char *msg, ...)
{
	char		buffer[255];
	uint32_t	blen = sizeof(buffer) / sizeof(buffer[0]);
	va_list		ap;
	
	va_start(ap, msg);
	vsnprintf(buffer, blen, msg, ap);
	va_end(ap);
	perror(buffer);
	
}


int inet_aton(const char *name, struct in_addr *addr)
{
	addr->s_addr = inet_addr(name);
	return (addr->s_addr != (in_addr_t) INADDR_NONE);
}



static int addr_valid4(const char *dst)
{
	struct in_addr addr4;
	struct hostent *h;
	
	if (inet_pton(AF_INET, dst, &addr4)) {
		return TRUE;
	} 
	
	h = gethostbyname(dst);
	if (h != NULL) {
		return TRUE;
	}
	socket_error("Can't resolve IP address for %s", dst);
	
	return FALSE;
}

static int addr_valid6(const char *dst)
{
#ifdef HAVE_IPv6
	struct in6_addr addr6;
	switch (inet_pton(AF_INET6, dst, &addr6)) {
        case 1:  
			return TRUE;
			break;
        case 0: 
			return FALSE;
			break;
        case -1: 
			debug_msg("inet_pton failed\n");
			errno = 0;
	}
#endif /* HAVE_IPv6 */
	UNUSED(dst);
	return FALSE;
}

/**
 * udp_addr_valid:
 * @addr: string representation of IPv4 or IPv6 network address.
 *
 * Returns TRUE if @addr is valid, FALSE otherwise.
 **/

int addr_valid(const char *addr)
{
	return addr_valid4(addr) | addr_valid6(addr);
}

const char *host_addr4_iphone(void)
{
	static char    		 hname[MAXHOSTNAMELEN];
	struct ifaddrs *interfaces = NULL; 
	struct ifaddrs *temp_addr = NULL; 
	int success = 0; // retrieve the current interfaces - returns 0 on success 
	char *lo0 = "lo0";
	
	success = getifaddrs(&interfaces); 
	if (success == 0) { 
		// Loop through linked list of interfaces 
		temp_addr = interfaces; 
		while(temp_addr != NULL && !success) { 
			if(temp_addr->ifa_addr->sa_family == AF_INET) { 
				// Check if interface is en0 which is the wifi connection on the iPhone 
				printf("%s - %s\n", temp_addr->ifa_name, inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
				
				if( strcmp(temp_addr->ifa_name, lo0) ) {
					char *sptr = inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr);
					strncpy(hname, sptr, MAXHOSTNAMELEN);
					printf("Using %s as IP\n", hname);
					success = 1;
				}
			} 
			temp_addr = temp_addr->ifa_next; 
		} 
	} // Free memory 
	freeifaddrs(interfaces); 

	if(success == 0) {
		socket_error("Can't obtain IP address from AF_INET interface");
		return NULL;
	}
	
//	assert(hent->h_addrtype == AF_INET);
//	memcpy(&iaddr.s_addr, hent->h_addr, sizeof(iaddr.s_addr));
//	strncpy(hname, inet_ntoa(iaddr), MAXHOSTNAMELEN);
	return (const char*)hname;
}

//TODO: This needs to be rewritten.
const char *host_addr4(void)
{
	static char    		 hname[MAXHOSTNAMELEN];
	struct hostent 		*hent;
	struct in_addr  	 iaddr;
	
	if (gethostname(hname, MAXHOSTNAMELEN) != 0) {
		debug_msg("Cannot get hostname!");
		abort();
	}
	hent = NULL; //gethostbyname(hname);
	if (hent == NULL) {
		socket_error("Can't resolve IP address for %s. Trying first AF_INET interface\n", hname);
		return host_addr4_iphone();
		//return NULL;
	}
	assert(hent->h_addrtype == AF_INET);
	memcpy(&iaddr.s_addr, hent->h_addr, sizeof(iaddr.s_addr));
	strncpy(hname, inet_ntoa(iaddr), MAXHOSTNAMELEN);
	return (const char*)hname;
}

const char *host_addr6(void)
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
#else  /* HAVE_IPv6 */
	//UNUSED(s);
	return "::";	/* The unspecified address... */
#endif /* HAVE_IPv6 */
}

