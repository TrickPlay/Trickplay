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
// private methods/functions/properties

@property (nonatomic, retain) NSMutableArray *writeQueue;

/**
 * This function gets called back every time the sipSocket is
 * ready to read or write data.
 */
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void*info);
/**
 * This is the sipThread execution target.
 */
- (void)threadMain:(id)argument;
/**
 * This calls stop in the sipThread which closes all open SIP
 * Dialogs, invalidates the sipSocket, and tells the thread
 * to exit safely. dealloc will not be called on this object
 * until this method is called and sipThread exits.
 */
- (void)stop;
/**
 * This method sets the value of current_error to error and then calls
 * terminate.
 */
- (void)terminateThreadWithError:(enum sip_client_error_t)error;
/**
 * End all SIP service without properly tearing down the connection.
 */
- (void)terminate;
/**
 * Send the SIP data received over the network to this method.
 */
- (void)sipParse:(NSData *)sipData fromAddr:(NSData *)addr;

@end



@implementation SIPClient

@synthesize writeQueue;
@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithSPS:nil PPS:nil context:nil delegate:nil];
}

/**
 * This is our designated initializer
 */
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
        
        if (!stun) {
            NSLog(@"Failed to initiate STUN module");
            [self release];
            return nil;
        }
        NSDictionary *ipInfo = [stun getIPInfo];
        if (!ipInfo) {
            NSLog(@"Failed to STUN public IP/port");
            [self release];
            return nil;
        }
        // We are going to create a new socket for SIP, so close the socket from STUN
        if (close(stun.sock_fd)) {
            perror("STUN socket could not close");
        }
        // Release STUN
        [stun release];
        
        if (!ipInfo) {
            [self release];
            return nil;
        }
        clientPublicIP = [[ipInfo objectForKey:@"host"] retain];
        
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
        
        valid = YES;
        current_error = 0;
        
        streamerContext = [_context retain];
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark -
#pragma mark User Control

- (void)registerToAsterisk:(id)arg {
    RegisterDialog *registerDialog = [[[RegisterDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP delegate:self] autorelease];
        
    NSString *registerCallID = [NSString uuid];
    [registerDialog registerToAsteriskWithCallID:registerCallID];
    
    [sipDialogs setObject:registerDialog forKey:registerCallID];
}

- (void)connectToService {
    [sipThread start];
    [self performSelector:@selector(registerToAsterisk:) onThread:sipThread withObject:nil waitUntilDone:NO];
}

- (void)sendInvite:(id)arg {
    InviteDialog *inviteDialog = [[[InviteDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP sps:sps pps:pps delegate:self] autorelease];
        
    [sipDialogs setObject:inviteDialog forKey:inviteDialog.callID];
    
    [inviteDialog inviteWithAuthHeader:nil];
}

- (void)initiateVideoCall {
    [self performSelector:@selector(sendInvite:) onThread:sipThread withObject:nil waitUntilDone:NO];
}

- (void)hangUp {
    // TODO: Check if there are any active Invite Dialogs and cancel them (on sipThread)
}

- (void)disconnectFromService {
    [self stop];
}

#pragma mark -
#pragma mark SIPDialogDelegate Protocol

/**
 * This method is used by a SIPDialog to to send a SIP message
 * over the network.
 */
- (void)dialog:(SIPDialog *)dialog wantsToSendData:(NSData *)data {
    // Queue the packet
    [writeQueue addObject:data];
    // Enable the write callback
    CFSocketEnableCallBacks(sipSocket, kCFSocketWriteCallBack);
}

/**
 * This delegate method informs this SIPClient that
 * a dialog has begun for the given SIPDialog
 */
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

/**
 * Informs our SIPClient that an SDP packet was properly parsed and we may now
 * form an RTP stream with another client.
 */
- (void)dialog:(SIPDialog *)dialog beganRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate client:self beganRTPStreamWithMediaDestination:mediaDest];
    });
}

/**
 * Informs our SIPClient an RTP stream with the provided media destination has terminated.
 */
- (void)dialog:(SIPDialog *)dialog endRTPStreamWithMediaDestination:(NSDictionary *)mediaDest {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.delegate client:self endRTPStreamWithMediaDestination:mediaDest];
    });
}

#pragma mark -
#pragma mark Network

/**
 * If a packet arrived over the network associated with an unknown SIP Dialog then this method
 * will attempt to discover if this packet contains a new dialog which may be negotiated with.
 */
- (void)handleNewDialogWithHdr:(NSDictionary *)sipHdrDic body:(NSString *)sipBody fromAddr:(NSData *)remoteAddr {
    NSString *statusLine = [sipHdrDic objectForKey:@"Status-Line"];
    if ([statusLine rangeOfString:@"OPTIONS "].location != NSNotFound) {
        OptionsDialog *options = [[[OptionsDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP delegate:self] autorelease];
                
        [options receivedOptions:sipHdrDic fromAddr:remoteAddr];
    } else if ([statusLine rangeOfString:@"NOTIFY "].location != NSNotFound) {
        NotifyDialog *notify = [[[NotifyDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP delegate:self] autorelease];
                
        [notify receivedNotify:sipHdrDic fromAddr:remoteAddr];
    } else if ([statusLine rangeOfString:@"BYE "].location != NSNotFound) {
        ByeDialog *bye = [[[ByeDialog alloc] initWithVideoStreamerContext:streamerContext clientPublicIP:clientPublicIP clientPrivateIP:clientPrivateIP delegate:self] autorelease];
        
        [bye receivedBye:sipHdrDic fromAddr:remoteAddr];
    } else {
        NSLog(@"\nUnauthorized New Dialog\n");
    }
}

/**
 * This is where we parse a SIP packet.
 *
 * This is broken, it assumes that the buffer only holds exactly 1 SIP packet at a time.
 * Sockets, however, do not guarentee you read 1 packet at a time.
 * TODO: Fix this later.
 */
- (void)sipParse:(NSData *)sipData fromAddr:(NSData *)remoteAddr {
    if (!sipData) {
        return;
    }
    
    NSString *sipPacket = [[[NSString alloc] initWithData:sipData encoding:NSUTF8StringEncoding] autorelease];
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

/**
 * This is our CFSocket callback. This callback is NOT associated with the current
 * object of this SIPClient class. No instance variables are directly accessible from
 * this callback. Use the callback's void *info parameter to access 'self'.
 */
void sipSocketCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address,
                       const void *data, void *info) {
    //fprintf(stderr, "SIP Socket Callback\n");
    SIPClient *self = (SIPClient *)info;
    
    // Don't use [self isValid] because thread lock may slow down
    // socket behavior.
    if (!CFSocketIsValid(socket) || !self->valid) {
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
                strerror(err);
                [self terminateThreadWithError:SOCKET_READ];
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
                    [self terminateThreadWithError:SOCKET_WRITE];
                } else if (error == kCFSocketTimeout) {
                    fprintf(stderr, "Timeout Writing to socket\n");
                    [self terminateThreadWithError:SOCKET_WRITE];
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

/**
 * Connect sipSocket to the appropriate address.
 * If anything fails then current_error is set.
 */
- (void)createSocket {
    struct addrinfo hints, *servinfo, *p;
    int rv;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    
    if ((rv = getaddrinfo([streamerContext.SIPServerHostName UTF8String], [[NSString stringWithFormat:@"%d", streamerContext.SIPServerPort] UTF8String], &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        current_error = SOCKET_SETUP;
        return;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        CFDataRef addressRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)p->ai_addr, p->ai_addrlen);
        if (CFSocketConnectToAddress(sipSocket, addressRef, 0)) {
            CFSocketInvalidate(sipSocket);
            perror("client: connect");
            CFRelease(addressRef);
            current_error = SOCKET_SETUP;
            continue;
        }
        CFRelease(addressRef);
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "client: failed to connect\n");
        freeaddrinfo(servinfo);
        current_error = SOCKET_SETUP;
        return;
    }
    
    char str[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, p->ai_addr, str, INET_ADDRSTRLEN);
    fprintf(stderr, "\nSIP IP address: %s\nSIP port: %d\n", str, ntohs(((struct sockaddr_in *)(p->ai_addr))->sin_port));
    
    freeaddrinfo(servinfo);
}

/**
 * SIP Thread's main point of execution.
 */
- (void)threadMain:(id)argument {
    // First create our SIP Socket for this thread and add it as a Run Loop Source
    @autoreleasepool {
        [self createSocket];
        
        @synchronized(self) {
            if (current_error == NO_ERROR) {
                exit_thread = NO;
            
                // Add my input sources here (sockets, etc.)
                CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(NULL, sipSocket, 0);
                if (rls) {
                    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
                    CFRelease(rls);
                } else {
                    exit_thread = YES;
                }
            } else {
                exit_thread = YES;
            }
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
        // We invalidate our socket in ONE place, here and here alone.
        // Having this in only one place makes coding easier.
        if (sipSocket && CFSocketIsValid(sipSocket)) {
            CFSocketInvalidate(sipSocket);
        }
        
        valid = NO;
    }
    
    // Tell the delegate that the thread and socket terminated.
    // Return any possible error values.
    
    // Currently we need to check that the delegate exists because
    // if an RTP stream ends we throw away the NetworkManager that is
    // likely this delegate.
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.delegate client:self sipFinishedWithError:current_error];
        });
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
        
        // TODO: Rather than immediately exit, wait for the 200 responses
        // and then exit the thread.
        exit_thread = YES;
    }
}

- (void)terminateThreadWithError:(enum sip_client_error_t)error {
    current_error = error;
    // Terminate all dialogs and exit the thread
    [self terminate];
}

- (void)terminate {
    @synchronized (self) {
        // Destroy all SIP Dialogs, don't wait for proper termination
        if (sipDialogs) {
            [sipDialogs removeAllObjects];
        }
        
        exit_thread = YES;
        valid = NO;
    }
}

#pragma mark -
#pragma mark Thread Agnostic Methods

/**
 * Returns whether or not this SIPClient is still functioning.
 * This method is thread safe.
 */
- (BOOL)isValid {
    BOOL temp;
    @synchronized(self) {
        temp = valid;
    }
    
    return temp;
}

- (NSString *)errorDescription:(enum sip_client_error_t)error {
    // TODO: return a description of the error to the caller
    switch (error) {
        case NO_ERROR:
            return nil;
        case SOCKET_SETUP:
            return @"The SIP socket failed to connect to the server";
        case SOCKET_READ:
            return @"An error occurred while reading from the SIP socket";
        case SOCKET_WRITE:
            return @"An error occurred while writing to the SIP socket";
        case RUNLOOP_FAILURE:
            return @"The SIPClient NSRunLoop failed during execution";
            
        default:
            return @"Not a valid error";
    }
}

- (void)stop {
    [self performSelector:@selector(stopInBackground:) onThread:sipThread withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    // DO NOT EVER put [self stop] here! Causes a DEADLOCK!
    // [self stop] had to have been called sometime earlier anyway because
    // sipThread retains 'self'.
    
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
    
    if (streamerContext) {
        [streamerContext release];
        streamerContext = nil;
    }
    
    [super dealloc];
}

@end



