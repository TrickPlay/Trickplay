//
//  NetworkManager.m
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"

#import "rtpenc_h264.h"
#import "base64.h"


enum avtype {
	AV_TYPE_AUDIO,
	AV_TYPE_VIDEO
};
typedef enum avtype AVType;

@interface AVPacket : NSObject {
@public
	NSData *data;
	AVType type;
	uint32_t size;
	uint64_t time;
	uint64_t sample_time;
}
@end

@implementation AVPacket 
- (void) dealloc {
	[data release];
	[super dealloc];
}
@end



@implementation NetworkManager

#pragma mark -
#pragma mark Network

void *get_in_addr(struct sockaddr *sa) {
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in *)sa)->sin_addr);
    }
    
    return &(((struct sockaddr_in6 *)sa)->sin6_addr);
}

- (void)packetize:(CMSampleBufferRef)sampleBuffer {
    [avcEncoder encode:sampleBuffer];
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super init];
    if (self) {
        timeout.tv_sec = 5;
        timeout.tv_usec = 0;
        avc_session_id = 97;
        
        avQueue = [[NSMutableArray alloc] initWithCapacity:100];
        avcEncoder = [[AVCEncoder alloc] init];
        
        //TODO:
        //avc_session = rtp_init_udp(RTSP_HOST, 5002, [[ports objectAtIndex:0] intValue], 60, 2000, rtp_avc_session_callback, self);
		
		if(avc_session == NULL) {
			NSLog(@"Session is NULL");
		}
        
        socket_queue = dispatch_queue_create("Network Queue", NULL);
    }
    
    return self;
}

- (void)setUpAvcEncoder {
    AVCEncoderCallback cb = ^(const void* buffer, uint32_t length, CMTime pts) {
		
		NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
        
        AVPacket *packet = [[AVPacket alloc] init];
		packet->data = data;
		packet->size = length;
		packet->time = pts.value;
		packet->type = AV_TYPE_VIDEO;
		packet->sample_time = pts.value;
		
        @synchronized(avQueue) {
            [avQueue addObject:packet];
        }
		
		[packet release];
		
        dispatch_async(socket_queue, ^(void) {
            if (avQueue.count < 1) {// || sockfd < 1) {
                return;
            }
            
            AVPacket *sendPacket = nil;
            
            @synchronized(avQueue) {
                sendPacket = [avQueue objectAtIndex:0];
                [avQueue removeObjectAtIndex:0];
            }
            
            //send(sockfd, sendPacket->data.bytes, sendPacket->data.length, 0);
            /* TODO: send stuff */
            //int ret = send_nal(avc_session, packet->time, avc_session_id, (uint8_t*) [packet->data bytes], packet->size, &timeout);
            
            //fprintf(stderr, "ret: %d\n", ret);
        });
        
    };
    avcEncoder.callback = Block_copy(cb);
    
    //TODO: check retain count
    //NSLog(@"retain count: %d", self.avcEncoder.callback.retainCount);
    
    AVCParameters *params = [[AVCParameters alloc] init];
    //NSLog(@" %dx%d", profile.broadcastWidth, profile.broadcastHeight);
    /*
     params.outWidth = profile.broadcastWidth;
     params.outHeight = profile.broadcastHeight;
     params.videoProfileLevel = AVVideoProfileLevelH264Baseline30;
     params.bps = (broadcastBitrates[profile.broadcastOption] * profile.bitrateScalar);// / kIPadScale;
     params.keyFrameInterval = profile.keyFrameInterval;
     */
    avcEncoder.parameters = params;
    
    if(![avcEncoder prepareEncoder]) {
        NSLog(@"Encoder Error: %@", avcEncoder.error);
    }
    
    spspps = avcEncoder.spspps;
    pps = avcEncoder.pps;
    sps = avcEncoder.sps;
    
    //[avcEncoder start];
}

- (void)startEncoder {
    //[avcEncoder start];
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    if (socket_queue) {
        dispatch_release(socket_queue);
    }
    
    if (avcEncoder) {
        [avcEncoder release];
        avcEncoder = nil;
    }
    
    if (avQueue) {
        [avQueue release];
        avQueue = nil;
    }
}

@end






