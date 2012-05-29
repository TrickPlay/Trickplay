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

@protocol SIPClientDelegate <NSObject>

- (void)client:(SIPClient *)client beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;
- (void)client:(SIPClient *)client endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest;

@end


@interface SIPClient : NSObject <SIPDialogDelegate> {
    NSThread *sipThread;
    // this variable belongs to sipThread
    BOOL exit_thread;
    
    NSMutableDictionary *sipDialogs;
    
    CFSocketRef sipSocket;
    NSMutableArray *writeQueue;
    
    NSString *clientPrivateIP;
    NSString *clientPublicIP;
    //NSString *udpClientIP;
    
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

// private
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void*info);

- (void)threadMain:(id)argument;

/**
 * This calls stop in the sipThread which closes all open SIP
 * Dialogs, invalidates the sipSocket, and tells the thread
 * to exit safely. dealloc will not be called on this object
 * until this method is called and sipThread exits.
 */
- (void)stop;

/**
 * Send the SIP data received over the network to this method.
 */
- (void)sipParse:(NSData *)sipData fromAddr:(NSData *)addr;

@end




