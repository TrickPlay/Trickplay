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

@class VideoStreamer;
@class VideoStreamerContext;
@class NetworkManager;


@protocol NetworkManagerDelegate <NSObject>

/**
 * Informs the Delegate that this NetworkManager is ready to encode
 * and send video/audio packets.
 */
- (void)networkManagerEncoderReady:(NetworkManager *)networkManager;

@end



static struct timeval timeout;

/**
 * The NetworkManager holds a SIPClient for regulating all SIP tasks,
 * an AVCEncoder for encoding Video frames in H.264, and
 * various rtp structs for sending encoded data to a destination
 * determined by the SIP negotiation.
 *
 * TODO: An Audio encoder will be added later
 */
@interface NetworkManager : NSObject <SIPClientDelegate> {
    dispatch_queue_t socket_queue;
    
    uint8_t avc_session_id;
    struct rtp *avc_session;
    struct rtp *pcmu_session;
    
    uint32_t rtp_audio_ts;
    
    NSData *spspps, *pps, *sps;
    
    AVCEncoder *avcEncoder;
    NSMutableArray *avQueue;
    
    SIPClient *sipClient;
    
    VideoStreamerContext *streamerContext;
    
    id <NetworkManagerDelegate> delegate;
}

@property (nonatomic, assign) id <NetworkManagerDelegate> delegate;
@property (nonatomic, assign) AVCEncoder *avcEncoder;

void rtp_avc_session_callback(struct rtp *session, rtp_event *e);
void *get_in_addr(struct sockaddr *sa);

- (id)initWithContext:(VideoStreamerContext *)streamerContext;
- (void)startEncoder;
- (void)packetize:(CMSampleBufferRef)sampleBuffer;

@end
