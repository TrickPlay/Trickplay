//
//  SIPClient.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPClient.h"

#import <CoreFoundation/CoreFoundation.h>

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>

#import "MyExtensions.h"

#define ASTERISK_HOST "asterisk-1.asterisk.trickplay.com"
#define ASTERISK_PORT "5060"


static NSString *const user = @"phone";
static NSString *const contactURI = @"sip:phone@asterisk-1.asterisk.trickplay.com";
static NSString *const remoteURI = @"sip:asterisk-1.asterisk.trickplay.com";
static NSString *const udpClientIP = @"10.0.190.153";
static NSUInteger const udpClientPort = 50418;
static NSUInteger const udpServerPort = 5060;


@interface SIPClient()

@property (nonatomic, retain) NSMutableArray *writeQueue;

@end



@implementation SIPClient

@synthesize writeQueue;

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

- (void)registerToAsterisk:(id)arg {
    RegisterDialog *registerDialog = [[[RegisterDialog alloc] initWithUser:user contactURI:contactURI remoteURI:remoteURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue delegate:self] autorelease];
       
    NSString *registerCallID = [NSString uuid];
    [registerDialog registerToAsteriskWithCallID:registerCallID];
    
    [sipDialogs setObject:registerDialog forKey:registerCallID];
}

- (void)connectToService {
    [sipThread start];
    //[self registerToAsterisk:nil];
    [self performSelector:@selector(registerToAsterisk:) onThread:sipThread withObject:nil waitUntilDone:NO];
}

- (void)initiateVideoCall {
    
}

- (void)hangUp {
    
}

- (void)disconnectFromService {
    [self stop];
}

#pragma mark -
#pragma mark SIPDialogDelegate Protocol

- (void)dialog:(SIPDialog *)dialog wantsToSendData:(NSData *)data {
    // Queue the packet
    [writeQueue addObject:data];
    // Enable the write callback
    CFSocketEnableCallBacks(sipSocket, kCFSocketWriteCallBack);
}

- (void)dialogSessionEnded:(SIPDialog *)dialog {
    
}

#pragma mark -
#pragma mark Network

- (void)handleNewDialogWithHdr:(NSDictionary *)sipHdrDic body:(NSString *)sipBody fromAddr:(NSData *)remoteAddr {
    NSString *statusLine = [sipHdrDic objectForKey:@"Status-Line"];
    if ([statusLine rangeOfString:@"OPTIONS "].location != NSNotFound) {
        OptionsDialog *options = [[[OptionsDialog alloc] initWithUser:user contactURI:contactURI remoteURI:remoteURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue delegate:self] autorelease];

        [options receivedOptions:sipHdrDic fromAddr:remoteAddr];
    } else if ([statusLine rangeOfString:@"BYE "].location != NSNotFound) {
        
    }
}

/**
 * This is broken, it assumes that the buffer only holds exactly 1 SIP packet at a time.
 * TODO: Fix this later.
 */
- (void)sipParse:(NSData *)sipData fromAddr:(NSData *)remoteAddr {
    if (!sipData) {
        return;
    }
    
    NSString *sipPacket = [[NSString alloc] initWithData:sipData encoding:NSUTF8StringEncoding];
    
    // Separate header and body
    NSArray *components = [sipPacket componentsSeparatedByString:@"\r\n\r\n"];
    NSString *sipHdr = [components objectAtIndex:0];
    NSString *sipBody = nil;
    if (components.count > 1) {
        sipBody = [components objectAtIndex:1];
        if ([sipBody compare:@""] == NSOrderedSame) {
            sipBody = nil;
        }
    }
    
    // Organize the elements of the Header into a Dictionary
    NSMutableDictionary *sipHdrDic = [NSMutableDictionary dictionaryWithCapacity:20];
    NSMutableArray *sipHdrComponents = [NSMutableArray arrayWithArray:[sipHdr componentsSeparatedByString:@"\r\n"]];
    [sipHdrDic setObject:[sipHdrComponents objectAtIndex:0] forKey:@"Status-Line"];
    [sipHdrComponents removeObjectAtIndex:0];
    
    for (NSString *component in sipHdrComponents) {
        NSArray *sipLineComponents = [component componentsSeparatedByString:@": "];
        [sipHdrDic setObject:[sipLineComponents objectAtIndex:1] forKey:[sipLineComponents objectAtIndex:0]];
    }
    
    NSLog(@"SIP Header Dictionary:\n%@", sipHdrDic);
    // If a Dialog is already open for this packet, find it
    // and the packet to it
    NSString *callID = [sipHdrDic objectForKey:@"Call-ID"];
    if (callID) {
        SIPDialog *dialog = [sipDialogs objectForKey:callID];
        if (dialog) {
            [dialog interpretSIP:sipHdrDic body:sipBody];
        } else {
            [self handleNewDialogWithHdr:(NSDictionary *)sipHdrDic body:(NSString *)sipBody fromAddr:(NSData *)remoteAddr];
        }
    }
}

/**
 * This is our CFSocket callback. This callback is NOT associated with the current
 * object of this SIPCient class. No instance variables are directly accessible from
 * this callback. Use the callback's void *info parameter to access 'self'.
 */
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void *info) {
    fprintf(stderr, "SIP Socket Callback\n");
    
    switch (type) {
        case kCFSocketReadCallBack:
            fprintf(stderr, "SIP Socket Read\n");
            
            int err;
            int sock = CFSocketGetNative(socket);
            struct sockaddr_storage addr;
            socklen_t addrLen;
            uint8_t buffer[65536];
            ssize_t bytesRead;
            
            assert(sock >= 0);
            
            bytesRead = recvfrom(sock, buffer, sizeof(buffer), 0, (struct sockaddr *)&addr, &addrLen);
            if (bytesRead < 0) {
                err = errno;
            } else if (bytesRead == 0) {
                err = EPIPE;
            } else {
                NSData *dataObj;
                NSData *addrObj;
                
                err = 0;
                
                dataObj = [NSData dataWithBytes:buffer length:bytesRead];
                assert(dataObj != nil);
                addrObj = [NSData dataWithBytes:&addr length:addrLen];
                assert(addrObj != nil);
                
                //NSLog(@"SIP read at address: %@ with data:\n%@", addrObj, dataObj);
                SIPClient *self = (SIPClient *)info;
                // TODO: Some type of error catching here is well advised, in case of
                // malformed packets.
                [self sipParse:dataObj fromAddr:addrObj];
            }
            
            if (err != 0) {
                NSLog(@"SIP error reading data; error code: %d", err);
                //TODO: Tell the delegate that things messed the eff up
            }
            
            break;
            
        case kCFSocketDataCallBack:
            fprintf(stderr, "SIP Socket Data\n");
            break;
            
        case kCFSocketConnectCallBack:
            fprintf(stderr, "SIP Socket Connected\n");
            break;
            
        case kCFSocketWriteCallBack:
            fprintf(stderr, "SIP Socket Write\n");
            
            SIPClient *self = (SIPClient *)info;
            
            if (self.writeQueue.count > 0) {
                CFDataRef packet = (CFDataRef)[self.writeQueue objectAtIndex:0];
                [self.writeQueue removeObjectAtIndex:0];
                CFSocketError error = CFSocketSendData(socket, NULL, packet, 0);
                if (error == kCFSocketError) {
                    fprintf(stderr, "Error Writing to socket\n");
                } else if (error == kCFSocketTimeout) {
                    fprintf(stderr, "Timeout Writing to socket\n");
                }
            }
            
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



