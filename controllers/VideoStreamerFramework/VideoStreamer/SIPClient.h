//
//  SIPClient.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 * Everything except init and dealloc should run in the sipThread.
 * This will help protect against having to use locks.
 */

#import <Foundation/Foundation.h>


#import "SIPDialog.h"

@class SIPClient;
@class VideoStreamerContext;

/**
 * This enumeration provides reasons for a SIPClient to terminate
 * its thread and thus all outside SIP communication.
 *
 * NO_ERROR:        No error occurred; SIP tore down smoothly.
 * SOCKET_SETUP:    There was an error either obtaining the public IP via STUN
 *                  or could not reach the SIP server.
 * SOCKET_WRITE:    There was an error writing to the socket sending to the SIP server.
 * SOCKET_READ:     There was an error reading from the socket connected to the SIP server.
 * RUNLOOP_FAILURE: An error occurred while executing the SIPClient's thread's runloop.
 */

enum sip_client_error_t {
    NO_ERROR = 0,
    SOCKET_SETUP = 1,
    SOCKET_READ = 2,
    SOCKET_WRITE = 3,
    RUNLOOP_FAILURE = 4
};

/**
 * The SIPClientDelegate protocol informs the delegate of when a SIP session
 * terminates and reason for termination. Also, this protocol informs
 * when SIP has performed correct handshaking to allow an RTP media session
 * to commence or to inform the delegate that an active RTP media session
 * should tear down.
 */

@protocol SIPClientDelegate <NSObject>

- (void)client:(SIPClient *)client beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)client:(SIPClient *)client endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)client:(SIPClient *)client sipFinishedWithError:(enum sip_client_error_t)error;

@end


/**
 * The SIPClient manages all SIP Dialogs with the SIP server and
 * connected UACs. During initialization, this class first uses
 * STUN to discover this iOS Device's public IP address. If successful
 * SIPClient spawns a thread and sets up a socket to the SIP server.
 * All activity of SIPClient, from that point forward, will execute
 * on its private thread.
 */

@interface SIPClient : NSObject <SIPDialogDelegate> {
    // All SIP stuff is handled in this thread
    NSThread *sipThread;
    // This variable belongs to sipThread
    BOOL exit_thread;
    // Determines if this SIPClient is working
    BOOL valid;
    // If there was an error then this was set
    enum sip_client_error_t current_error;
    // An array of all active SIP Dialogs
    NSMutableDictionary *sipDialogs;
    
    // The socket which sends/receives from the SIP server
    CFSocketRef sipSocket;
    // A queue for all packets pending send to the SIP server
    NSMutableArray *writeQueue;
    
    // This iOS Devices IP address as seen behind NAT
    NSString *clientPrivateIP;
    // This iOS Devices IP address as seen publically on the
    // Internet
    NSString *clientPublicIP;
    
    // The Session Parameter Set that this iOS Device will
    // use for H.264 streaming over RTP
    NSData *sps;
    // The Picture Parameter Set that this iOS Device will
    // use for H.264 streaming over RTP
    NSData *pps;
    
    // The VideoStreamerContext containing all necessary
    // connection information
    VideoStreamerContext *streamerContext;
    
    // This class's delegate
    id <SIPClientDelegate> delegate;
}

@property (atomic, assign) id <SIPClientDelegate> delegate;

// public
- (id)initWithSPS:(NSData *)sps PPS:(NSData *)pps context:(VideoStreamerContext *)context delegate:(id <SIPClientDelegate>)delegate;

/**
 * Call this to connect to a SIP server via REGISTER.
 */
- (void)connectToService;
/**
 * Initiates a video call by sending INVITE.
 */
- (void)initiateVideoCall;
/**
 * Ends a video call by sending BYE. Currently doesn't work.
 */
- (void)hangUp;
/**
 * End all video calls by sending BYE and disconnect from the SIP server.
 */
- (void)disconnectFromService;
/**
 * Returns YES if the SIPClient is valid, NO otherwise.
 */
- (BOOL)isValid;
/**
 * Gives the caller a description of the error.
 */
- (NSString *)errorDescription:(enum sip_client_error_t)error;

@end




