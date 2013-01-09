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

#import "MediaDescription.h"
#import "VideoStreamer.h"


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


@interface NetworkManager()
    - (BOOL)setUpAvcEncoder;
@end


static struct timeval timeout;

// TODO: rather than pass the media host/port combos up to here from SIPDialog, make avc/aac encoders
// members of SIPDialog and pass a connection context up to the Video/Audio samplers
// (which are currently in ViewController.m)

@implementation NetworkManager

@synthesize avcEncoder;
@synthesize delegate;

#pragma mark -
#pragma mark Network

void rtp_avc_session_callback(struct rtp *session, rtp_event *e) {
    // TODO: check on the session. this callback should get called on rtcp messages
    // I believe.
}

/**
 * This function returns a pointer to the 32 bit IPv4 address
 * or the 128 bit IPv6 address, depending on socket family.
 */
void *get_in_addr(struct sockaddr *sa) {
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in *)sa)->sin_addr);
    }
    
    return &(((struct sockaddr_in6 *)sa)->sin6_addr);
}

/**
 * Tell the AVCEncoder to encode the sample.
 */
- (void)packetize:(CMSampleBufferRef)sampleBuffer {
    if (!avcEncoder) {
        return;
    }
    [avcEncoder encode:sampleBuffer];
}

/**
 * Stop all encoders.
 */
- (void)invalidate:(enum NETWORK_TERMINATION_CODE)code {
    if (sipClient) {
        sipClient.delegate = nil;
        // Must call disconnectFromService! SIPClient objects
        // have their own thread that retains "self" and this is
        // the only way to stop the thread and release "self"
        [sipClient disconnectFromService];
        [sipClient release];
        sipClient = nil;
    }
    
    if (avcEncoder) {
        [avcEncoder stop];
        // TODO: AVCEncoder should Block_release automatically.
        Block_release(avcEncoder.callback);
        avcEncoder.callback = nil;
        self.avcEncoder = nil;
    }
    if (avc_session) {
        rtp_send_bye(avc_session);
        rtp_done(avc_session);
        avc_session = NULL;
    }
    // TODO: Add audio encoder invalidation
    
    if (socket_queue) {
        dispatch_release(socket_queue);
        socket_queue = nil;
    }
        
    [delegate networkManagerInvalid:self endedWithCode:code];
}

- (void)endChat {
    [sipClient disconnectFromService];
}

#pragma mark -
#pragma mark SIPClientDelegate Protocol

/**
 * This is a hack method used to send PCMU noise at even intervals of 160 ms.
 * Use this method for testing the RTP stream.
 */
- (void)sendAudio:(NSTimer *)timer {
    dispatch_async(socket_queue, ^(void) {
        char buff[122];
        for (int i = 0; i < 122; i++) {
            buff[i] = 0xFF;
        }
        rtp_send_data(pcmu_session, rtp_audio_ts, 0, 1, 0, NULL, (char *)buff, 122, NULL, 0, 0, &timeout);
    });
    rtp_audio_ts += 160;
}

/**
 * sipClient callback stating that the Call handshake succeeded and it is time to
 * begin the RTP stream.
 */
- (void)client:(SIPClient *)client beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    // If no current RTP sessions and 
    if (avc_session || pcmu_session) {
        return;
    }
    // TODO: Audio
    MediaDescription *video = [mediaDest objectForKey:@"video"];
    MediaDescription *audio = [mediaDest objectForKey:@"audio"];
    
    if (video) {
        // Our Rx ports for video/audio is apart of the string established in genSDP method of
        // SIPDialog.m
        // TODO: make the Rx ports some globally defined constant
        // IMPROVEMENT: Search for arbitrary Rx port in genSDP to prevent collisions and make that
        // a part of this MediaDescription
        
        // TODO: think of all the places avc_session might need to send BYE and get freed. still
        // not sure if i'm covering them all.
        avc_session = rtp_init_udp([video.host UTF8String], 22078, video.port, 60, 2000, rtp_avc_session_callback, self);
        NSLog(@"port: %d", video.port);
        
        if(avc_session == NULL) {
            // TODO: handle this gracefully
			NSLog(@"AVC session is NULL");
            [self invalidate:CALL_FAILED];
            return;
		}
    }
    /*
    if (audio) {
        pcmu_session = rtp_init_udp([audio.host UTF8String], 21078, audio.port, 60, 2000, rtp_avc_session_callback, self);
        [NSTimer scheduledTimerWithTimeInterval:0.16 target:self selector:@selector(sendAudio:) userInfo:nil repeats:YES];
    }
    */
    
    [delegate networkManagerEncoderReady:self];
}

/**
 * This delegate is called when the callee decides to send BYE over the network, formorally
 * ending the RTP session.
 */
- (void)client:(SIPClient *)client endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    [self invalidate:CALL_ENDED_BY_CALLEE];
}

/**
 * SIP can end for a variety of reasons. This callback informs you of those reasons.
 */
- (void)client:(SIPClient *)client sipFinishedWithError:(enum sip_client_error_t)error {
    NSLog(@"SIP Client finished with error: %@", [client errorDescription:error]);
    if (error == NO_ERROR) {
        [self invalidate:CALL_ENDED_BY_CALLER];
    } else {
        [self invalidate:CALL_FAILED];
    }
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithContext:nil];
}

// Designated Initializer
- (id)initWithContext:(VideoStreamerContext *)_streamerContext {
    if (!_streamerContext) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        streamerContext = [_streamerContext retain];
        
        timeout.tv_sec = 5;
        timeout.tv_usec = 0;
        avc_session_id = 99;
        
        rtp_audio_ts = 0;
        
        avQueue = [[NSMutableArray alloc] initWithCapacity:100];
        avcEncoder = [[AVCEncoder alloc] init];
        if (![self setUpAvcEncoder]) {
            [self release];
            return nil;
        }
        
        avc_session = NULL;
        pcmu_session = NULL;
        
        sipClient = [[SIPClient alloc] initWithSPS:avcEncoder.sps PPS:avcEncoder.pps context:streamerContext delegate:self];
        if (!sipClient) {
            [self release];
            return nil;
        }
        [sipClient connectToService];
        socket_queue = dispatch_queue_create("Network Queue", NULL);
    }
    
    return self;
}

/**
 * Hooks up the callback from the AVCEncoder. This callback returns to
 * NetworkManager whenever a frame has finished encoding. buffer is the
 * encoded frame, length is the size of the frame, pts is the RTP timestamp
 * to use.
 */
- (BOOL)setUpAvcEncoder {
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
            /*
            if (avQueue.count < 1) {// || sockfd < 1) {
                return;
            }
            */
            
            AVPacket *sendPacket = nil;
            @synchronized(avQueue) {
                while (avQueue.count > 0) {
                    sendPacket = [[avQueue objectAtIndex:0] retain];
                    [avQueue removeObjectAtIndex:0];
            
                    int ret = send_nal(avc_session, sendPacket->time, avc_session_id, (uint8_t*) [sendPacket->data bytes], sendPacket->size, &timeout);
                    
                    //fprintf(stderr, "ret: %d\n", ret);
            
                    [sendPacket release];
                    
                    if (ret == -1) {
                        fprintf(stderr, "RTP socket write error\n");
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self invalidate:CALL_DROPPED];
                        });
                    }
                }
            }
        });
        
    };
    // TODO: Fix AVCEncoder and include Block_copy and Block_release at appropriate moments.
    // This will include adding a method - (void)setCallback to AVCEncoder.
    avcEncoder.callback = Block_copy(cb);
    
    // You can adjust the AVCEncoder's paramters here!
    AVCParameters *params = [[AVCParameters alloc] init];
    //params.outWidth = 640;
    //params.outHeight = 480;
    //params.bps = 60000;
    params.videoProfileLevel = AVVideoProfileLevelH264Main31;
    params.keyFrameInterval = 100;
    //NSLog(@" %dx%d", profile.broadcastWidth, profile.broadcastHeight);
    /*
     params.outWidth = profile.broadcastWidth;
     params.outHeight = profile.broadcastHeight;
     params.videoProfileLevel = AVVideoProfileLevelH264Baseline30;
     params.bps = (broadcastBitrates[profile.broadcastOption] * profile.bitrateScalar);// / kIPadScale;
     params.keyFrameInterval = profile.keyFrameInterval;
    */
    avcEncoder.parameters = params;
    [params release];
    
    if(![avcEncoder prepareEncoder]) {
        NSLog(@"Encoder Error: %@", avcEncoder.error);
        return NO;
    }
    
    return YES;
}

- (void)startEncoder {
    fprintf(stderr, "sps packet size: %d\n", send_sps(avc_session, CACurrentMediaTime(), avc_session_id, (uint8_t *)avcEncoder.sps.bytes, avcEncoder.sps.length, &timeout));
    fprintf(stderr, "pps packet size: %d\n", send_pps(avc_session, CACurrentMediaTime(), avc_session_id, (uint8_t *)avcEncoder.pps.bytes, avcEncoder.pps.length, &timeout));
    [avcEncoder start];
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    // Set the delegate to nil before invalidating to prevent
    // calling back on the object that's trying to delete this
    // NetworkManager.
    self.delegate = nil;
    
    [self invalidate:CALL_ENDED_BY_CALLER];
    
    if (avQueue) {
        [avQueue release];
        avQueue = nil;
    }
    
    if (streamerContext) {
        [streamerContext release];
    }
    
    [super dealloc];
}

@end






