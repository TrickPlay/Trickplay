//
//  SIPClient.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPClient.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>

#import "SIPDialog.h"

#define ASTERISK_HOST "asterisk-1.asterisk.trickplay.com"
#define ASTERISK_PORT "5060"


@implementation SIPClient

- (id)init {
    self = [super init];
    if (self) {
        sipDialogs = [[NSMutableDictionary alloc] initWithCapacity:40];
        
        const CFSocketContext context = {0, self, NULL, NULL, NULL};
        sipSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketReadCallBack | kCFSocketWriteCallBack, sipSocketCallback, &context);
        
        writeQueue = [[NSMutableArray alloc] initWithCapacity:100];
        
        sipThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark User Control

- (void)connectToService {
    [sipThread start];
}

- (void)initiateVideoCall {
    
}

- (void)hangUp {
    
}

- (void)disconnectFromService {
    [self stop];
    
}

#pragma mark -
#pragma mark Network

static void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void *info) {
    fprintf(stderr, "SIP Socket Callback\n");
    
    switch (type) {
        case kCFSocketReadCallBack:
            fprintf(stderr, "SIP Socket Read\n");
            break;
            
        case kCFSocketDataCallBack:
            fprintf(stderr, "SIP Socket Data\n");
            break;
            
        case kCFSocketConnectCallBack:
            fprintf(stderr, "SIP Socket Connected\n");
            break;
            
        case kCFSocketWriteCallBack:
            fprintf(stderr, "SIP Socket Write\n");
            break;
            
        default:
            fprintf(stderr, "SIP Socket callback type unknown\n");
            break;
    }
}

#pragma mark -
#pragma mark Thread Execution and Runloop

- (void)threadMain:(id)argument {
    @autoreleasepool {
    
        struct addrinfo hints, *servinfo, *p;
        int rv;
    
        memset(&hints, 0, sizeof(hints));
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_DGRAM;
    
    
        if ((rv = getaddrinfo(ASTERISK_HOST, ASTERISK_PORT, &hints, &servinfo)) != 0) {
            fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
            return;
        }
    
        for (p = servinfo; p != NULL; p = p->ai_next) {
            CFDataRef addressRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)p->ai_addr, p->ai_addrlen);
            if (CFSocketConnectToAddress(sipSocket, addressRef, 0)) {
                close(CFSocketGetNative(sipSocket));
                perror("client: connect");
                continue;
            }
        
            break;
        }
    
        if (p == NULL) {
            fprintf(stderr, "client: failed to connect\n");
            return;
        }
    
        @synchronized(self) {
            exit_thread = NO;
    
            // TODO: Add my input sources here (sockets, etc.)
            CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(NULL, sipSocket, 0);
            assert(rls != NULL);
    
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    
            CFRelease(rls);
        }
    
    }
    
    do {
        // Start the run loop but return after each source is handled
        @autoreleasepool {
            BOOL ran_successfully = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            if (!ran_successfully) {
                NSLog(@"SIP Runloop ran unsuccessfully");
                exit_thread = YES;
            }
        }
    } while (!exit_thread);
}

/**
 * Only call this in our sipThread
 */
- (void)stopInBackground:(id)arg {
    @synchronized (self) {
        // First cancel all sipDialogs. They should send corresponding
        // CANCEL or BYE messages to all open SIP Sessions.
        if (sipDialogs) {
            for (SIPDialog *dialog in sipDialogs) {
                [dialog cancel];
            }
        }
        
        if (sipSocket) {
            // TODO: Not sure if I need to create a new socket or not to restart
            // a connection.
            CFSocketInvalidate(sipSocket);
        }
        
        exit_thread = YES;
    }
}

- (void)stop {
    [self performSelector:@selector(stopInBackground:) onThread:sipThread withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    // Technically this shouldn't need to be called since dealloc isn't called until
    // sipThread exits. Thus, [self stop] should be called somewhere else on the main
    // Thread in order to dealloc. Test to find out.
    [self stop];
    
    if (sipDialogs) {
        [sipDialogs release];
        sipDialogs = nil;
    }
    
    if (writeQueue) {
        [writeQueue release];
        writeQueue = nil;
    }
    
    if (sipThread) {
        [sipThread release];
        sipThread = nil;
    }
    
    if (sipSocket) {
        CFRelease(sipSocket);
        sipSocket = NULL;
    }
    
    [super dealloc];
}

@end



