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


enum NETWORK_TERMINATION_CODE;

/**
 * The NetworkManagerDelegate protocol informs the delegate of when
 * the NetworkManager referencing the delegate is ready to encode
 * video/audio data and when a call has finished and video/audio
 * encoding has terminated.
 */

@protocol NetworkManagerDelegate <NSObject>

/**
 * Informs the Delegate that this NetworkManager is ready to encode
 * and send video/audio packets.
 */
- (void)networkManagerEncoderReady:(NetworkManager *)networkManager;
/**
 * Informs the Delegate that this NetworkManager no longer is good
 * for use.
 */
- (void)networkManagerInvalid:(NetworkManager *)networkManager endedWithCode:(enum NETWORK_TERMINATION_CODE)code;

@end



/**
 * The NetworkManager holds a SIPClient for regulating all SIP tasks,
 * an AVCEncoder for encoding Video frames in H.264, and
 * various rtp structs for sending encoded data to a destination
 * determined by the SIP negotiation. NetworkManager Objects must
 * be initialized with a VideoStreamerContext.
 *
 * TODO: An Audio encoder will be added later
 */
@interface NetworkManager : NSObject <SIPClientDelegate> {
    // A dispatch queue used for queuing RTP packets
    dispatch_queue_t socket_queue;
    
    // The AVCEncoder class requires a session id.
    // This id is used as the payload type for the RTP
    // packets that NetworkManager will be sending
    // to the outside UAC it's chatting with.
    uint8_t avc_session_id;
    // RTP structures which carry necessary data for
    // sending AVC and PCMU packets
    struct rtp *avc_session;
    struct rtp *pcmu_session;
    
    // This is a discrete counter used as a hack for sending
    // PCMU packets.
    uint32_t rtp_audio_ts;
    
    // Our AVCEncoder
    AVCEncoder *avcEncoder;
    // The Queue used to queue up AVC packets to the RTP stream
    NSMutableArray *avQueue;
    
    // Our SIP client which negotiates calls
    SIPClient *sipClient;
    
    // The streamerContext contains all necessary address information
    // to establish network connections
    VideoStreamerContext *streamerContext;
    
    id <NetworkManagerDelegate> delegate;
}

@property (nonatomic, assign) id <NetworkManagerDelegate> delegate;
@property (nonatomic, assign) AVCEncoder *avcEncoder;

/**
 * This function is called every time something changes with the
 * RTP stream. Usually indicating an RTCP packet arrived over the network.
 */
void rtp_avc_session_callback(struct rtp *session, rtp_event *e);
/**
 * This function returns a pointer to the 32 bit IPv4 address
 * or the 128 bit IPv6 address, depending on socket family.
 */ 
void *get_in_addr(struct sockaddr *sa);

/**
 * Designated initializer. Always provide streamerContext.
 */
- (id)initWithContext:(VideoStreamerContext *)streamerContext;
/**
 * If NetworkManagerDelegate receives
 * - (void)networkManagerEncoderReady:(NetworkManager *)networkManager;
 * indicating that the network is ready to receive an RTP stream,
 * call startEncoder to begin sending data over the stream.
 * This method first send the Sequence Paramter Set and Picture
 * Parameter Set over the network to ready the other remote client
 * for H.264 streaming.
 */
- (void)startEncoder;
/**
 * Close RTP stream and disconnect from SIP server.
 */
- (void)endChat;
/**
 * Encode any arbitrary sample buffer and send it over the active RTP stream.
 */
- (void)packetize:(CMSampleBufferRef)sampleBuffer;

@end




