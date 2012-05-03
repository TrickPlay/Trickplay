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

#define STUN_HOST "stun.xten.com"
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

typedef struct {
    uint16_t type;
    uint16_t length;
    uint8_t *value;
} attribute;

void free_attributes(attribute *attributes[], int length);

@interface STUNClient : NSObject {
    struct sockaddr_in outgoing_addr;
    
    uint16_t message_type;
    uint16_t message_length;
    uint32_t magic_cookie;
    uint8_t transaction_id[12];
    attribute *attributes[100];
    
    uint8_t request[20];
    
    // It is the caller's responsibility to close this socket.
    // I.E. If getIPInfo returns the publicHostPortSocket combo then
    // assume that socket stays open for use.
    int sock_fd;
    NSDictionary *publicHostPortSocket;
}

- (id)initWithOutgoingAddress:(struct sockaddr_in)outgoing_addr;
- (NSDictionary *)getIPInfo;

@end
