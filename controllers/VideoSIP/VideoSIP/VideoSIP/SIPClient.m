//
//  SIPClient.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPClient.h"

#import "SIPDialog.h"

#define ASTERISK_HOST "asterisk-1.asterisk.trickplay.com"
#define ASTERISK_PORT 5060

@implementation SIPClient

- (id)init {
    self = [super init];
    if (self) {
        sipDialogs = [[NSMutableDictionary alloc] initWithCapacity:40];
        
        const CFSocketContext context = {0, self, NULL, NULL, NULL};
        sipSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketReadCallBack | kCFSocketWriteCallBack, sipSocketCallback, &context);
        
        sipThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark User Control

- (void)connectToService {
    [sipThread start];
}

#pragma mark -
#pragma mark Network

void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void*info) {
    
}

#pragma mark -
#pragma mark Thread Execution and Runloop

- (void)threadMain:(id)argument {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BOOL exit_thread = NO;
    
    // TODO: Add my input sources here (sockets, etc.)
    
    do {
        // Start the run loop but return after each source is handled
        BOOL ran_successfully = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        if (!ran_successfully) {
            NSLog(@"SIP Runloop ran unsuccessfully");
            exit_thread = YES;
        }
        
        
        [pool drain];
    } while (!exit_thread);
    
    [pool drain];
}

@end
