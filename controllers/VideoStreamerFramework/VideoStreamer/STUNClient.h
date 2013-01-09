//
//  STUNClient.h
//  VideoSIP
//
//  Created by Rex Fenley on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>

//#define STUN_HOST "stun.xten.com"
#define STUN_HOST "stun.ekiga.net"
#define STUN_PORT 3478

// Header values
#define BINDING 0x0001
#define BINDING_RESPONSE 0x0101
#define MAGIC_COOKIE 0x2112A442

// Attribute values (Comprehension-required range [0x000-0x7FFF])
#define MAPPED_ADDRESS 0x0001
#define USERNAME 0x0006
#define MESSAGE_INTEGRITY 0x0008
#define ERROR_CODE 0x0009
#define UNKNOWN_ATTRIBUTES 0x000A
#define REALM 0x0014
#define NONCE 0x0015
#define XOR_MAPPED_ADDRESS 0x0020
// Attribute values (Comprehension-optional range [0x8000-0xFFFF])
#define SOFTWARE 0x8022
#define ALTERNATE_SERVER 0x8023
#define FINGERPRINT 0x8028

// Old STUN Attribute values (Comprehension-required range [0x0000-0x7FFF])
#define RESPONSE_ADDRESS 0x0002     // This is from OLD STUN
#define CHANGE_ADDRESS 0x0003       // This is from OLD STUN
#define SOURCE_ADDRESS 0x0004       // This is from OLD STUN
#define CHANGED_ADDRESS 0x0005      // This is from OLD STUN
#define PASSWORD 0x0007             // This is from OLD STUN
#define REFLECTED_FROM 0x000B       // This is from OLD STUN

// All STUN attributes use this struct.
typedef struct {
    uint16_t type;
    uint16_t length;
    uint8_t *value;
} attribute;
// Free all of the STUN attributes
void free_attributes(attribute *attributes[], int length);

/**
 * The STUNClient performs STUN in order to discover the iOS Device's
 * public IP address. Init with -initWithOutgoingAddress:<stun server>
 * and use -getIPInfo to retrieve your public IP and a public port used
 * to send this STUN request plus the socket used for STUN.
 *
 * The STUNClient class is meant to be used synchronously. Create a
 * STUNClient object, initialize, and call getIPInfo it will return the
 * STUNed information or nil shortly thereafter. STUNClient uses two
 * 5s select calls but generally operates in <100ms.
 *
 * This implementation of STUN uses IPv4 and UDP for communication.
 *
 * Consult RFC 5389 - Session Traversal Utilities for NAT for more information.
 */

@interface STUNClient : NSObject {
    struct sockaddr_in outgoing_addr;
    
    // Every STUN message is of a type, we use BINDING
    uint16_t message_type;
    // Message length does not include the header, thus
    // it is 0 for a BINDING request
    uint16_t message_length;
    // Every STUN packet has a magic cookie to, used to
    // determine version of STUN
    uint32_t magic_cookie;
    // Every STUN request/response has a transaction ID
    // to identify it
    uint8_t transaction_id[12];
    // This is an array of parsed STUN response attributes
    attribute *attributes[100];
    // This is the STUN request packet
    uint8_t request[20];
    
    // It is the caller's responsibility to close this socket.
    // I.E. If getIPInfo returns the publicHostPortSocket combo then
    // assume that socket stays open for use.
    int sock_fd;
    NSDictionary *publicHostPortSocket;
}

// The socket that this client STUNs on
@property (nonatomic, readonly) int sock_fd;
// The same host/port/socket returned from the call to getIPInfo.
// Keys are @"socket" for an NSNumber storing the integer socket
// file descriptor, @"port" for an NSNumber storing the unsigned
// short port number, and @"host" for an NSString host name.
@property (nonatomic, readonly) NSDictionary *publicHostPortSocket;

// Initializer. Provide a sockaddr_in of the local address that
// the STUN socket will bind to.
- (id)initWithOutgoingAddress:(struct sockaddr_in)outgoing_addr;
// Get the public IP/port and socket used. Returns nil on failure.
- (NSDictionary *)getIPInfo;

@end
