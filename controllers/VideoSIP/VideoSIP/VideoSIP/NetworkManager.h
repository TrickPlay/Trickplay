//
//  NetworkManager.h
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AVCEncoder.h"
#import "SIPClient.h"

#import <netinet/in.h>
#import "rtp.h"

static struct timeval timeout;

typedef void (^socket_queue_callback)(const void* buffer, uint32_t length);

@interface NetworkManager : NSObject {
    dispatch_queue_t socket_queue;
    
    uint8_t avc_session_id;
    struct rtp *avc_session;
    
    NSData *spspps, *pps, *sps;
    
    AVCEncoder *avcEncoder;
    NSMutableArray *avQueue;
    
    SIPClient *sipClient;
}

void *get_in_addr(struct sockaddr *sa);

- (void)startEncoder;
- (void)packetize:(CMSampleBufferRef)sampleBuffer;

@end
