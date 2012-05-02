//
//  STUNClient.h
//  VideoSIP
//
//  Created by Rex Fenley on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STUN_HOST "stun.xten.com"
#define STUN_PORT 3478

#define BINDING 0x0001
#define BINDING_RESPONSE 0x0101
#define MAGIC_COOKIE 0x2112A442

typedef struct {
    uint16_t type;
    uint16_t length;
    uint8_t *value;
} attribute;

void free_attributes(attribute *attributes[], int length);

@interface STUNClient : NSObject {
    uint16_t message_type;
    uint16_t message_length;
    uint32_t magic_cookie;
    uint8_t transaction_id[12];
    attribute *attributes[100];
    
    uint8_t request[20];
}

@end
