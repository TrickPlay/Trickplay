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
#import <arpa/inet.h>

#import "net_common.h"

#import "VideoStreamer.h"
#import "STUNClient.h"
#import "MyExtensions.h"

//#define ASTERISK_HOST "asterisk-1.asterisk.trickplay.com"
//#define ASTERISK_HOST "freeswitch.internal.trickplay.com"
//#define ASTERISK_PORT "5060"


//static NSString *const user = @"phone";
//*
//static NSString *const contactURI = @"sip:phone@asterisk-1.asterisk.trickplay.com";
//static NSString *const remoteURI = @"sip:1002@asterisk-1.asterisk.trickplay.com";
//static NSString *const asteriskURI = @"sip:asterisk-1.asterisk.trickplay.com";
//*/
/*
static NSString *const contactURI = @"sip:phone@freeswitch.internal.trickplay.com";
static NSString *const remoteURI = @"sip:1002@freeswitch.internal.trickplay.com";
static NSString *const asteriskURI = @"sip:freeswitch.internal.trickplay.com";
//*/
//static NSString *udpClientIP = @"10.0.190.153";
//static NSUInteger const udpClientPort = 50160;
//static NSUInteger const udpServerPort = 5060;


@interface SIPClient()

@property (nonatomic, retain) NSMutableArray *writeQueue;

@end



@implementation SIPClient

@synthesize writeQueue;
@synthesize delegate;

- (id)init {
    return [self initWithSPS:nil PPS:nil context:nil delegate:nil];
}

- (id)initWithSPS:(NSData *)_sps PPS:(NSData *)_pps context:(VideoStreamerContext *)_context delegate:(id <SIPClientDelegate>)_delegate {
    if (!_sps || !_pps || !_context) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        // First get the private IP address
        clientPrivateIP = [[NSString stringWithFormat:@"%s", host_addr4()] retain];
        if (!clientPrivateIP) {
            [self release];
            return nil;
        }
        
        // Next STUN the public IP address
        struct sockaddr_in client_address;
        client_address.sin_family = AF_INET;
        client_address.sin_addr.s_addr = inet_addr([clientPrivateIP UTF8String]);
        // TODO: figure out a better way to get a port number
        client_address.sin_port = htons(0);
        memset(client_address.sin_zero, 0, sizeof(client_address.sin_zero));
        
        STUNClient *stun = [[STUNClient alloc] initWithOutgoingAddress:client_address];
        NSDictionary *ipInfo = [stun getIPInfo];
        if (!ipInfo) {
            [self release];
            return nil;
        }
        clientPublicIP = [[ipInfo objectForKey:@"host"] retain];
        // We are going to create a new socket for SIP, so close the socket from STUN
        if (close(stun.sock_fd)) {
            perror("STUN socket could not close");
        }
        // Release STUN
        [stun release];
        
        // This contains all the currently active SIP Dialogs
        sipDialogs = [[NSMutableDictionary alloc] initWithCapacity:40];
        
        // Create SIP socket
        // TODO: Consider just reusing the STUN socket here and originally binding the STUN
        // socket to the SIP port
        const CFSocketContext context = {0, self, NULL, NULL, NULL};
        sipSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketReadCallBack | kCFSocketWriteCallBack, sipSocketCallback, &context);
        if (!sipSocket) {
            [self release];
            return nil;
        }
        
        // Bind socket to appropriate port
        int sock = CFSocketGetNative(sipSocket);
        
        // reuse client_address struct
        client_address.sin_family = AF_INET;
        client_address.sin_addr.s_addr = inet_addr([clientPrivateIP UTF8String]);
        client_address.sin_port = htons(_context.SIPClientPort);
        memset(client_address.sin_zero, 0, sizeof(client_address.sin_zero));
        
        if (bind(sock, (struct sockaddr *)&client_address, sizeof(client_address))) {
            perror("SIP Socket could not bind to local address");
            [self release];
            return nil;
        }
        
        writeQueue = [[NSMutableArray alloc] initWithCapacity:100];
        
        sipThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
        
        sps = [_sps retain];
        pps = [_pps retain];
        
        streamerContext = [_context retain];
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark -
#pragma mark User Control

- (void)registerToAsterisk:(id)arg {
    RegisterDialog *registerDialog = [[[RegisterDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP writeQueue:writeQueue delegate:self] autorelease];
    
    //RegisterDialog *registerDialog = [[[RegisterDialog alloc] initWithUser:user contactURI:contactURI remoteURI:asteriskURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue delegate:self] autorelease];
    
    NSString *registerCallID = [NSString uuid];
    [registerDialog registerToAsteriskWithCallID:registerCallID];
    
    [sipDialogs setObject:registerDialog forKey:registerCallID];
}

- (void)connectToService {
    [sipThread start];
    [self performSelector:@selector(registerToAsterisk:) onThread:sipThread withObject:nil waitUntilDone:NO];
}

// TODO: Since this call is public but needs to run on sipThread this should be changed
// to leverage performSelector:onThread:
- (void)initiateVideoCall {
    InviteDialog *inviteDialog = [[[InviteDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP writeQueue:writeQueue sps:sps pps:pps delegate:self] autorelease];
    
    //InviteDialog *inviteDialog = [[[InviteDialog alloc] initWithUser:user contactURI:contactURI remoteURI:remoteURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue sps:sps pps:pps delegate:self] autorelease];
    
    [sipDialogs setObject:inviteDialog forKey:inviteDialog.callID];
    
    [inviteDialog inviteWithAuthHeader:nil];
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

- (void)dialogSessionStarted:(SIPDialog *)dialog {
    
}

/**
 * This is our main callback from Dialog sessions ending. This
 * will have a large impact on the state machine.
 */
- (void)dialogSessionEnded:(SIPDialog *)dialog {
    
    if ([dialog isKindOfClass:[RegisterDialog class]]) {
        [self initiateVideoCall];
    } else if ([dialog isKindOfClass:[InviteDialog class]]) {
        // TODO: might feel like updating network manager on this bit of info?
    }
    
    [sipDialogs removeObjectForKey:dialog.callID];
}

- (void)dialog:(SIPDialog *)dialog beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    // TODO: SIP connection could possibly die on sipThread before this gets called.
    // Handle this possible race condition gracefully.
    // delegate callbacks may have already taken care of that by using async dispatching however...
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate client:self beganRTPStreamWithMediaDestination:mediaDest];
    });
}

- (void)dialog:(SIPDialog *)dialog endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate client:self endRTPStreamWithMediaDestination:mediaDest];
    });
}

#pragma mark -
#pragma mark Network

- (void)handleNewDialogWithHdr:(NSDictionary *)sipHdrDic body:(NSString *)sipBody fromAddr:(NSData *)remoteAddr {
    NSString *statusLine = [sipHdrDic objectForKey:@"Status-Line"];
    if ([statusLine rangeOfString:@"OPTIONS "].location != NSNotFound) {
        OptionsDialog *options = [[[OptionsDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP writeQueue:writeQueue delegate:self] autorelease];
        
        //OptionsDialog *options = [[[OptionsDialog alloc] initWithUser:user contactURI:contactURI remoteURI:asteriskURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue delegate:self] autorelease];
        
        [options receivedOptions:sipHdrDic fromAddr:remoteAddr];
    } else if ([statusLine rangeOfString:@"NOTIFY "].location != NSNotFound) {
        NotifyDialog *notify = [[[NotifyDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP writeQueue:writeQueue delegate:self] autorelease];
        
        //NotifyDialog *notify = [[[NotifyDialog alloc] initWithUser:user contactURI:contactURI remoteURI:asteriskURI udpClientIP:udpClientIP udpClientPort:udpClientPort udpServerPort:udpServerPort writeQueue:writeQueue delegate:self] autorelease];
        
        [notify receivedNotify:sipHdrDic fromAddr:remoteAddr];
    } else if ([statusLine rangeOfString:@"BYE "].location != NSNotFound) {
        NSLog(@"Fix handling extra BYEs here\n");
    } else {
        NSLog(@"\nUnauthorized New Dialog\n");
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
    NSLog(@"Received SIP packet:\n%@\n", sipPacket);
    
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
    
    //NSLog(@"SIP Header Dictionary:\n%@", sipHdrDic);
    // If a Dialog is already open for this packet, find it
    // and the packet to it
    NSString *callID = [sipHdrDic objectForKey:@"Call-ID"];
    if (callID) {
        SIPDialog *dialog = [sipDialogs objectForKey:callID];
        if (dialog) {
            [dialog interpretSIP:sipHdrDic body:sipBody fromAddr:remoteAddr];
        } else {
            [self handleNewDialogWithHdr:(NSDictionary *)sipHdrDic body:(NSString *)sipBody fromAddr:(NSData *)remoteAddr];
        }
    }
}

- (void)socketBrokeWithError:(NSInteger)error {
    [self stopInBackground:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [delegate client:self didDisconnectWithError:error];
    });
}

/**
 * This is our CFSocket callback. This callback is NOT associated with the current
 * object of this SIPClient class. No instance variables are directly accessible from
 * this callback. Use the callback's void *info parameter to access 'self'.
 */
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void *info) {
    //fprintf(stderr, "SIP Socket Callback\n");
    if (!CFSocketIsValid(socket)) {
        return;
    }
    
    switch (type) {
        case kCFSocketReadCallBack:
        {
            //fprintf(stderr, "SIP Socket Read\n");
            
            int err;
            int sock = CFSocketGetNative(socket);
            struct sockaddr_storage addr;
            socklen_t addrLen = sizeof(addr);
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
                //NSLog(@"\nReceived from address: %@\n\n", addrObj);
                if (addrLen > 0) {
                    [self sipParse:dataObj fromAddr:addrObj];
                }
            }
            
            if (err != 0) {
                NSLog(@"SIP error reading data; error code: %d", err);
                //TODO: Tell the delegate that things messed the eff up
                SIPClient *self = (SIPClient *)info;
                [self socketBrokeWithError:err];
            }
            
            break;
        }    
        case kCFSocketDataCallBack:
            fprintf(stderr, "SIP Socket Data\n");
            break;
            
        case kCFSocketConnectCallBack:
            fprintf(stderr, "SIP Socket Connected\n");
            break;
            
        case kCFSocketWriteCallBack:
        {
            //fprintf(stderr, "SIP Socket Write\n");
            
            SIPClient *self = (SIPClient *)info;
            
            while (self.writeQueue.count > 0) {
                CFDataRef packet = (CFDataRef)[self.writeQueue objectAtIndex:0];
                CFSocketError error = CFSocketSendData(socket, NULL, packet, 0);
                [self.writeQueue removeObjectAtIndex:0];
                if (error == kCFSocketError) {
                    fprintf(stderr, "Error Writing to socket\n");
                    [self socketBrokeWithError:error];
                } else if (error == kCFSocketTimeout) {
                    fprintf(stderr, "Timeout Writing to socket\n");
                    [self socketBrokeWithError:error];
                }
            }
            
            break;
        }   
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
        
        
        //if ((rv = getaddrinfo(ASTERISK_HOST, ASTERISK_PORT, &hints, &servinfo)) != 0) {
        if ((rv = getaddrinfo([streamerContext.SIPServerHostName UTF8String], [[NSString stringWithFormat:@"%d", streamerContext.SIPServerPort] UTF8String], &hints, &servinfo)) != 0) {
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
            freeaddrinfo(servinfo);
            return;
        }
        
        char str[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, p->ai_addr, str, INET_ADDRSTRLEN);
        fprintf(stderr, "\nSIP IP address: %s\nSIP port: %d\n", str, ntohs(((struct sockaddr_in *)(p->ai_addr))->sin_port));
        
        freeaddrinfo(servinfo);
        
        @synchronized(self) {
            exit_thread = NO;
            
            // Add my input sources here (sockets, etc.)
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
    
    @synchronized(self) {
        if (sipSocket && CFSocketIsValid(sipSocket)) {
            CFSocketInvalidate(sipSocket);
        }
    }
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
    // sipThread exits (FYI: NSThread -initWithTarget: retains the target).
    // Thus, [self stop] should be called somewhere else on the main
    // Thread in order to dealloc. But no harm done having it here.
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
    
    /*
    if (udpClientIP) {
        [udpClientIP release];
        udpClientIP = nil;
    }
    //*/
    
    if (clientPublicIP) {
        [clientPublicIP release];
        clientPublicIP = nil;
    }
    
    if (clientPrivateIP) {
        [clientPrivateIP release];
        clientPrivateIP = nil;
    }
    
    if (sps) {
        [sps release];
        sps = nil;
    }
    
    if (pps) {
        [pps release];
        pps = nil;
    }
    
    [super dealloc];
}

@end



