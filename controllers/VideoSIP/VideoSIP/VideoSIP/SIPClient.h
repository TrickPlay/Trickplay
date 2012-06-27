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


enum sip_client_error_t {
    NO_ERROR = 0,
    SOCKET_SETUP = 1,
    SOCKET_READ = 2,
    SOCKET_WRITE = 3,
    RUNLOOP_FAILURE = 4
};



@protocol SIPClientDelegate <NSObject>

- (void)client:(SIPClient *)client beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)client:(SIPClient *)client endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)client:(SIPClient *)client sipFinishedWithError:(enum sip_client_error_t)error;

@end


@interface SIPClient : NSObject <SIPDialogDelegate> {
    // all SIP stuff is handled in this thread
    NSThread *sipThread;
    // this variable belongs to sipThread
    BOOL exit_thread;
    // determines if this SIPClient is working
    BOOL valid;
    // if there was an error then this was set
    enum sip_client_error_t current_error;
    
    NSMutableDictionary *sipDialogs;
    
    CFSocketRef sipSocket;
    NSMutableArray *writeQueue;
    
    NSString *clientPrivateIP;
    NSString *clientPublicIP;
    
    NSData *sps;
    NSData *pps;
    
    VideoStreamerContext *streamerContext;
    
    id <SIPClientDelegate> delegate;
}

@property (atomic, assign) id <SIPClientDelegate> delegate;

// public
- (id)initWithSPS:(NSData *)sps PPS:(NSData *)pps context:(VideoStreamerContext *)context delegate:(id <SIPClientDelegate>)delegate;

- (void)connectToService;
- (void)initiateVideoCall;
- (void)hangUp;
- (void)disconnectFromService;
/**
 * Returns YES if the SIPClient is valid, NO otherwise
 */
- (BOOL)isValid;
/**
 * Gives the caller a description of the error
 */
- (NSString *)errorDescription:(enum sip_client_error_t)error;

@end




