//
//  SIPClient.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreFoundation/CoreFoundation.h>

@interface SIPClient : NSObject {
    NSThread *sipThread;
    
    NSMutableDictionary *sipDialogs;
    
    CFSocketRef sipSocket;
}

// public
- (void)connectToService;
- (void)initiateVideoCall;
- (void)hangUp;

// private
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void*info);

- (void)registerSIP;

- (void)threadMain:(id)argument;

@end
