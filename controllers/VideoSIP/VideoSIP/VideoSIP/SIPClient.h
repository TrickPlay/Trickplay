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

#import <CoreFoundation/CoreFoundation.h>


@interface SIPClient : NSObject {
    NSThread *sipThread;
    // this variable belongs to sipThread
    BOOL exit_thread;
    
    NSMutableDictionary *sipDialogs;
    
    CFSocketRef sipSocket;
    NSMutableArray *writeQueue;
}

// public
- (void)connectToService;
- (void)initiateVideoCall;
- (void)hangUp;

// private
static void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void*info);

- (void)threadMain:(id)argument;

/**
 * This calls stop in the sipThread which closes all open SIP
 * Dialogs, invalidates the sipSocket, and tells the thread
 * to exit safely. dealloc will not be called on this object
 * until this method is called and sipThread exits.
 */
- (void)stop;

@end
