//
//  SIPDialog.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPDialog.h"

#import <netdb.h>
#import <arpa/inet.h>

#import "MyExtensions.h"
#import "STUNClient.h"
#import "SDPParser.h"
#import "MediaDescription.h"
#import "VideoStreamer.h"

#import "base64.h"


@implementation SIPDialog

@synthesize user;
@synthesize contactURI;
@synthesize remoteURI;
@synthesize sipURI;
@synthesize clientPrivateIP;
@synthesize clientPublicIP;
@synthesize udpClientPort;
@synthesize udpServerPort;
@synthesize via;
@synthesize maxForwards;
@synthesize from;
@synthesize to;
@synthesize callID;
@synthesize cseq;
@synthesize contact;
@synthesize userAgent;
@synthesize allow;
@synthesize supported;
@synthesize branch;
@synthesize authLine;
@synthesize auth;

@synthesize delegate;

- (id)initWithVideoStreamerContext:(VideoStreamerContext *)_context clientPublicIP:(NSString *)_clientPublicIP clientPrivateIP:(NSString *)_clientPrivateIP delegate:(id <SIPDialogDelegate>)_delegate {
    if (!_context || !_delegate || !_clientPublicIP || !_clientPrivateIP) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        // Go through and construct all the necessary pieces for any SIP packet
        self.user = _context.SIPUserName;
        self.contactURI = [NSString stringWithFormat:@"sip:%@@%@", _context.SIPUserName, _context.SIPServerHostName];
        self.remoteURI = [NSString stringWithFormat:@"sip:%@@%@", _context.SIPRemoteUserName, _context.SIPServerHostName];
        self.sipURI = self.remoteURI;
        self.clientPublicIP = _clientPublicIP;
        self.clientPrivateIP = _clientPrivateIP;
        self.udpClientPort = _context.SIPClientPort;
        self.udpServerPort = _context.SIPServerPort;
        
        self.via = [NSMutableDictionary dictionaryWithCapacity:3];
        [via setObject:@"SIP/2.0/UDP" forKey:@"protocol"];
        [via setObject:clientPublicIP forKey:@"clientIP"];
        [via setObject:[NSNumber numberWithUnsignedInt:udpClientPort] forKey:@"clientPort"];
        
        self.maxForwards = 70;
        
        self.from = [NSMutableDictionary dictionaryWithCapacity:2];
        NSString *fromTag = [NSString uuid];
        [from setObject:[NSString stringWithFormat:@"<%@>", contactURI] forKey:@"sender"];
        [from setObject:fromTag forKey:@"tag"];
        
        self.to = [NSMutableDictionary dictionaryWithCapacity:2];
        [to setObject:[NSString stringWithFormat:@"<%@>", remoteURI] forKey:@"remoteContact"];
        
        self.callID = [NSString uuid];
        
        self.cseq = 101;
        
        self.contact = [NSString stringWithFormat:@"<sip:%@@%@:%d>", _context.SIPUserName, clientPublicIP, udpClientPort];
        
        self.userAgent = @"Phone";
        
        self.allow = @"INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE";
        self.supported = @"timer, 100rel, path";
        
        self.branch = nil;
        self.authLine = nil;
        self.auth = [NSMutableDictionary dictionaryWithCapacity:10];
                
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark -
#pragma mark Utilities

- (NSString *)generateBranch {
    NSString *branchSuffix = [NSString uuid];
    return [NSString stringWithFormat:@"z9hG4bK%@", branchSuffix];
}

/**
 * This method returns an NSString that is the line one should add to any
 * SIP header using WWW-Authentication or Proxy-Authentication.
 */
- (NSString *)generateAuthLine:(NSString *)requestType headerKey:(NSString *)key {
    NSString *nonce = [auth objectForKey:@"nonce"];
    NSString *realm = [auth objectForKey:@"realm"];
    NSString *qop = [auth objectForKey:@"qop"];
    if (!nonce || !realm || !self.sipURI || !requestType || !key) {
        return nil;
    }
    
    if (!qop) {
        NSString *ha1 = [[NSString stringWithFormat:@"%@:%@:1234", self.user, realm] md5];
        NSString *ha2 = [[NSString stringWithFormat:@"%@:%@", requestType, sipURI] md5];
        NSString *ha3 = [[NSString stringWithFormat:@"%@:%@:%@", ha1, nonce, ha2] md5];
    
        self.authLine = [NSString stringWithFormat:@"%@: Digest username=%@, realm=\"%@\", nonce=%@, algorithm=MD5, uri=%@, response=%@\r\n", key, user, realm, nonce, sipURI, ha3];
    
        return authLine;
    } else {  // handle qop case
        NSString *cnonce = [NSString uuid];
        
        NSString *ha1 = [[NSString stringWithFormat:@"%@:%@:1234", self.user, realm] md5];
        NSString *ha2 = [[NSString stringWithFormat:@"%@:%@", requestType, sipURI] md5];
        NSString *ha3 = [[NSString stringWithFormat:@"%@:%@:00000001:%@:%@:%@", ha1, nonce, cnonce, qop, ha2] md5];
        
        self.authLine = [NSString stringWithFormat:@"%@: Digest username=\"%@\", realm=\"%@\", nonce=\"%@\", nc=00000001, cnonce=\"%@\", qop=\"%@\", algorithm=MD5, uri=\"%@\", response=\"%@\"\r\n", key, user, realm, nonce, cnonce, qop, sipURI, ha3];
        
        return authLine;
    }
}

/**
 * When a SIP Header from over the network asks for Authentication
 * this method parses that SIP line and adds all Authentication
 * paramters to this SIPDialog's auth NSMutableDictionary.
 */
- (void)parseAuthentication:(NSString *)authResponse {
    // Make sure the challenge is Digest
    NSRange authTypeRange = [authResponse rangeOfString:@"Digest "];
    if (authTypeRange.location == NSNotFound) {
        return;
    }
    // Eliminate "Digest" so only the parameters are left
    NSString *split = [authResponse substringFromIndex:authTypeRange.location + authTypeRange.length];
    // TODO: probably should handle case with and without whitespace
    // Put parameters and values into a dictionary for easy lookup
    NSArray *authParams = [split componentsSeparatedByString:@", "];
    for (NSString *authParam in authParams) {
        NSArray *components = [authParam componentsSeparatedByString:@"="];
        NSString *param = [components objectAtIndex:0];
        NSString *value = [components objectAtIndex:1];
        // trim out quotation marks
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        [auth setObject:[value stringByTrimmingCharactersInSet:characterSet] forKey:param];
    }
}

- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body fromAddr:(NSData *)remoteAddr {
    NSLog(@"This method should be overwritten: SIPDialog.m line 174");
}

- (void)cancel {
    // TODO: Send BYE messages and whatnot to other UAS/UAC. Only Dialogs that need to send
    // BYE should override this method.
    NSLog(@"This method should be overwritten: SIPDialog.m line 180");
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    self.user = nil;
    self.contactURI = nil;
    self.remoteURI = nil;
    self.sipURI = nil;
    self.clientPublicIP = nil;
    self.clientPrivateIP = nil;
    self.udpClientPort = 0;
    self.udpServerPort = 0;
    self.via = nil;
    self.maxForwards = 0;
    self.from = nil;
    self.to = nil;
    self.callID = nil;
    self.cseq = 0;
    self.contact = nil;
    self.userAgent = nil;
    self.allow = nil;
    self.supported = nil;
    self.branch = nil;
    self.authLine = nil;
    self.auth = nil;
    
    self.delegate = nil;
    
    [super dealloc];
}

@end




@implementation RegisterDialog

- (NSString *)generateRegister {
    // TODO: figure out why shit is null
    self.branch = [self generateBranch];
    
    NSString *registerHdr = [NSString stringWithFormat:@"REGISTER %@ SIP/2.0\r\n"
                             @"Via: %@ %@:%d;rport;branch=%@\r\n"
                             @"Max-Forwards: %d\r\n"
                             @"From: %@;tag=%@\r\n"
                             @"To: %@\r\n"
                             @"Call-ID: %@\r\n"
                             @"CSeq: %d REGISTER\r\n"
                             @"Contact: %@\r\n"
                             @"User-Agent: %@\r\n"
                             @"Allow: %@\r\n"
                             @"Supported: %@\r\n",
                             contactURI,
                             [via objectForKey:@"protocol"], [via objectForKey:@"clientIP"], [[via objectForKey:@"clientPort"] unsignedIntValue], branch,
                             maxForwards,
                             [from objectForKey:@"sender"], [from objectForKey:@"tag"],
                             [from objectForKey:@"sender"],
                             callID,
                             cseq,
                             contact,
                             userAgent,
                             allow,
                             supported];
    
    if (authLine) {
        registerHdr = [NSString stringWithFormat:@"%@%@", registerHdr, authLine];
    }
    
    registerHdr = [NSString stringWithFormat:@"%@%@", registerHdr, @"Content-Length: 0\r\n\r\n"];
    
    NSLog(@"Register packet:\n%@", registerHdr);
    
    cseq += 1;
    
    return registerHdr;
}

- (void)registerToAsteriskWithCallID:(NSString *)registerCallID {
    self.callID = registerCallID;
    
    self.authLine = [self generateAuthLine:@"REGISTER" headerKey:@"Authorization"];
    NSString *packet = [self generateRegister];
    
    [delegate dialog:self wantsToSendData:[packet dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body fromAddr:(NSData *)remoteAddr {
    NSString *statusLine = [parsedPacket objectForKey:@"Status-Line"];
    if (!statusLine) {
        return;
    }
    if ([statusLine compare:@"SIP/2.0 200 OK"] == NSOrderedSame) {
        [delegate dialogSessionEnded:self];
    } else if ([statusLine compare:@"SIP/2.0 401 Unauthorized"] == NSOrderedSame) {
        NSString *authRequest = [parsedPacket objectForKey:@"WWW-Authenticate"];
        if (authRequest) {
            [self parseAuthentication:authRequest];
            [self registerToAsteriskWithCallID:self.callID];
        }
    } else {
        NSLog(@"Unrecognized Response: %@\n", statusLine);
    }
}

- (void)cancel {
    // Do nothing
}

@end




@implementation OptionsDialog

- (void)receivedOptions:(NSDictionary *)optionsPacket fromAddr:(NSData *)remoteAddr {
    // respond to the packet
    struct sockaddr_in *addr = (struct sockaddr_in *)[remoteAddr bytes];
    char ip_string[INET_ADDRSTRLEN];

    inet_ntop(AF_INET, &(addr->sin_addr), ip_string, INET_ADDRSTRLEN);

    NSArray *remoteVia = [[optionsPacket objectForKey:@"Via"] componentsSeparatedByString:@";"];

    // TODO: malformed packets that are missing information could crash this.
    NSString *response = [NSString stringWithFormat:@"SIP/2.0 200 OK\r\n"
                          @"Via: %@;%@;rport=%d;received=%s\r\n"
                          @"From: %@\r\n"
                          @"To: %@;tag=%@\r\n"
                          @"Call-ID: %@\r\n"
                          @"CSeq: %@\r\n"
                          @"Contact: %@\r\n"
                          @"User-Agent: %@\r\n"
                          @"Accept: application/sdp\r\n"
                          @"Supported: %@\r\n"
                          @"Content-Length: 0\r\n\r\n",
                          [remoteVia objectAtIndex:0], [remoteVia objectAtIndex:1], ntohs(addr->sin_port), ip_string,
                          [optionsPacket objectForKey:@"From"],
                          [optionsPacket objectForKey:@"To"], [from objectForKey:@"tag"],
                          [optionsPacket objectForKey:@"Call-ID"],
                          [optionsPacket objectForKey:@"CSeq"],
                          contact,
                          userAgent,
                          supported];
                          
    NSLog(@"Options Response: %@\n", response);
    
    [delegate dialog:self wantsToSendData:[response dataUsingEncoding:NSUTF8StringEncoding]];
}

@end


@implementation NotifyDialog

- (void)receivedNotify:(NSDictionary *)notifyPacket fromAddr:(NSData *)remoteAddr {
    // respond to the packet
    struct sockaddr_in *addr = (struct sockaddr_in *)[remoteAddr bytes];
    char ip_string[INET_ADDRSTRLEN];
    
    inet_ntop(AF_INET, &(addr->sin_addr), ip_string, INET_ADDRSTRLEN);
    
    NSArray *remoteVia = [[notifyPacket objectForKey:@"Via"] componentsSeparatedByString:@";"];
    
    // TODO: malformed received packets that have different information could crash this.
    // copied from vippie
    NSString *response = [NSString stringWithFormat:@"SIP/2.0 200 OK\r\n"
                          @"Via: %@;rport=%d;received=%s;%@\r\n"
                          @"From: %@\r\n"
                          @"To: %@;tag=%@\r\n"
                          @"Call-ID: %@\r\n"
                          @"CSeq: %@\r\n"
                          @"Content-Length: 0\r\n\r\n",
                          [remoteVia objectAtIndex:0], ntohs(addr->sin_port), ip_string, [remoteVia objectAtIndex:2],
                          [notifyPacket objectForKey:@"From"],
                          [notifyPacket objectForKey:@"To"], [from objectForKey:@"tag"],
                          [notifyPacket objectForKey:@"Call-ID"],
                          [notifyPacket objectForKey:@"CSeq"]];
    
    NSLog(@"Notify Response: %@\n", response);
    
    [delegate dialog:self wantsToSendData:[response dataUsingEncoding:NSUTF8StringEncoding]];
}

@end


@implementation ByeDialog

- (void)receivedBye:(NSDictionary *)byePacket fromAddr:(NSData *)remoteAddr {
    // respond to the packet
    struct sockaddr_in *addr = (struct sockaddr_in *)[remoteAddr bytes];
    char ip_string[INET_ADDRSTRLEN];
    
    inet_ntop(AF_INET, &(addr->sin_addr), ip_string, INET_ADDRSTRLEN);
    
    NSArray *remoteVia = [[byePacket objectForKey:@"Via"] componentsSeparatedByString:@";"];
    
    // TODO: malformed received packets that have different information could crash this.
    // copied from vippie
    NSString *response = [NSString stringWithFormat:@"SIP/2.0 481 Dialog/Transaction Does Not Exist\r\n"
                          @"Via: %@;rport=%d;received=%s;%@\r\n"
                          @"From: %@\r\n"
                          @"To: %@;tag=%@\r\n"
                          @"Call-ID: %@\r\n"
                          @"CSeq: %@\r\n"
                          @"Content-Length: 0\r\n\r\n",
                          [remoteVia objectAtIndex:0], ntohs(addr->sin_port), ip_string, [remoteVia objectAtIndex:2],
                          [byePacket objectForKey:@"From"],
                          [byePacket objectForKey:@"To"], [from objectForKey:@"tag"],
                          [byePacket objectForKey:@"Call-ID"],
                          [byePacket objectForKey:@"CSeq"]];
    
    NSLog(@"BYE Response: %@\n", response);
    
    [delegate dialog:self wantsToSendData:[response dataUsingEncoding:NSUTF8StringEncoding]];
}

@end


@implementation InviteDialog

- (id)initWithVideoStreamerContext:(VideoStreamerContext *)_context clientPublicIP:(NSString *)_clientPublicIP clientPrivateIP:(NSString *)_clientPrivateIP sps:(NSData *)_sps pps:(NSData *)_pps delegate:(id <SIPDialogDelegate>)_delegate {
    
    if (!_sps || !_pps) {
        [self release];
        return nil;
    }
    
    self = [super initWithVideoStreamerContext:_context clientPublicIP:_clientPublicIP clientPrivateIP:_clientPrivateIP delegate:_delegate];
    
    if (self) {
        previousAcks = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        sps = [_sps retain];
        pps = [_pps retain];
    }
    
    return self;
}

- (void)cancel {
    // Send a BYE packet
    NSString *bye = [NSString stringWithFormat:@"BYE %@ SIP/2.0\r\n"
                     @"Via: %@ %@:%d;rport;branch=%@\r\n"
                     @"Max-Forwards: %d\r\n"
                     @"From: %@;tag=%@\r\n"
                     @"To: %@\r\n"
                     @"Call-ID: %@\r\n"
                     @"CSeq: %d BYE\r\n"
                     @"Contact: %@\r\n"
                     @"User-Agent: %@\r\n"
                     @"Allow: %@\r\n"
                     @"Supported %@\r\n",
                     sipURI,
                     [via objectForKey:@"protocol"], [via objectForKey:@"clientIP"], [[via objectForKey:@"clentPort"] unsignedIntValue], branch,
                     maxForwards,
                     [from objectForKey:@"sender"], [from objectForKey:@"tag"],
                     [to objectForKey:@"remoteContact"],
                     callID,
                     cseq,
                     contact,
                     userAgent,
                     allow,
                     supported];
    
    NSLog(@"\nBYE Request:\n%@\n", bye);
    [delegate dialog:self wantsToSendData:[bye dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark INVITE and related packet generation

- (NSString *)genSDP {
    
    NSString *sdp = nil;
    /*
    unsigned char csps[32], cpps[32];
	NSString *b64sps = nil, *b64pps = nil;
	
    int length = base64encode(((unsigned char *)[sps bytes]) + 4, [sps length] - 4, csps, 32);
    csps[length] = '\0';
    b64sps = [NSString stringWithCString:(const char*)csps encoding:NSASCIIStringEncoding];
        
    length = base64encode(((unsigned char *)[pps bytes]) + 4, [pps length] - 4, cpps, 32);
    cpps[length] = '\0';
    b64pps = [NSString stringWithCString:(const char*)cpps encoding:NSASCIIStringEncoding];
    //*/
    
    struct sockaddr_in client_address;
    client_address.sin_family = AF_INET;
    client_address.sin_addr.s_addr = inet_addr([clientPrivateIP UTF8String]);
    client_address.sin_port = htons(22078);
    memset(client_address.sin_zero, 0, sizeof(client_address.sin_zero));
    
    STUNClient *stun = [[[STUNClient alloc] initWithOutgoingAddress:client_address] autorelease];
    NSDictionary *ipInfo = [stun getIPInfo];
    if (!ipInfo) {
        return nil;
    }
    NSString *publicIP = [ipInfo objectForKey:@"host"];
    NSNumber *publicVideoPort = (NSNumber *)[ipInfo objectForKey:@"port"];
    // We are going to create a new socket with this info later, so close the socket from STUN
    close(stun.sock_fd);
    
    sdp = [NSString stringWithFormat:@"v=0\r\n"
                                    @"o=- 0 0 IN IP4 %@\r\n"
                                    @"s=%@\r\n"
                                    @"c=IN IP4 %@\r\n"
                                    @"t=0 0\r\n"
                                    @"m=audio 21078 RTP/AVP 0\r\n"
                                    @"a=rtpmap:0 PCMU/8000\r\n"
                                    @"a=sendrecv\r\n"
                                    @"m=video %@ RTP/AVP 99\r\n"
                                    @"a=rtpmap:99 H264/90000\r\n"
                                    @"a=sendonly\r\n"
                                    @"a=fmtp:99 packetization-mode=0\r\n",
                                    //@"a=fmtp:99 packetization-mode=1;sprop-parameter-sets=%@,%@\r\n",
                                    //udpClientIP, user, udpClientIP];//, b64sps, b64pps];
                                    publicIP, user, publicIP, publicVideoPort];//, b64sps, b64pps];
    
    return sdp;
}


- (NSString *)generateInvite {
    
    NSString *invite = [NSString stringWithFormat:@"INVITE %@ SIP/2.0\r\n"
                        @"Via: %@ %@:%d;rport;branch=%@\r\n"
                        @"Max-Forwards: %d\r\n"
                        @"From: %@;tag=%@\r\n"
                        @"To: %@\r\n"
                        @"Call-ID: %@\r\n"
                        @"CSeq: %d INVITE\r\n"
                        @"Contact: %@\r\n"
                        @"User-Agent: %@\r\n"
                        @"Allow: %@\r\n"
                        @"Supported: %@\r\n",
                        sipURI,
                        [via objectForKey:@"protocol"], [via objectForKey:@"clientIP"], [[via objectForKey:@"clientPort"] unsignedIntValue], branch,
                        maxForwards,
                        [from objectForKey:@"sender"], [from objectForKey:@"tag"],
                        [to objectForKey:@"remoteContact"],
                        callID,
                        cseq,
                        contact,
                        userAgent,
                        allow,
                        supported];
    
    if (authLine) {
        invite = [NSString stringWithFormat:@"%@%@", invite, authLine];
    }
    
    NSString *sdpPacket = [self genSDP];
    if (!sdpPacket) {
        return nil;
    }
    
    invite = [NSString stringWithFormat:@"%@%@%d%@%@", invite, @"Content-Type: application/sdp\r\nContent-Length: ", [sdpPacket length], @"\r\n\r\n", sdpPacket];
        
    return invite;
}

- (void)ackResponse:(NSDictionary *)response withBranch:(NSString *)ackBranch {
    NSString *existingAck = [previousAcks objectForKey:[response objectForKey:@"CSeq"]];
    if (existingAck) {
        [delegate dialog:self wantsToSendData:[existingAck dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"\nACK with packet:\n%@\n", existingAck);
        return;
    }
    
    if (!ackBranch) {
        ackBranch = branch;
    }
    
    NSString *responseCSeq = [response objectForKey:@"CSeq"];
    NSArray *components = [responseCSeq componentsSeparatedByString:@" "];
    responseCSeq = [components objectAtIndex:0];
    NSNumber *cseqVal = [NSNumber numberWithInt:[responseCSeq intValue]];
    NSUInteger ackCSeq = [cseqVal unsignedIntValue];
    
    NSString *ack = [NSString stringWithFormat:@"ACK %@ SIP/2.0\r\n"
                     @"Via: %@ %@:%d;rport;branch=%@\r\n"
                     @"Max-Forwards: %d\r\n"
                     @"From: %@;tag=%@\r\n"
                     @"To: %@\r\n"
                     @"Call-ID: %@\r\n"
                     @"CSeq: %d ACK\r\n"
                     @"Content-Length: 0\r\n\r\n",
                     sipURI,
                     [via objectForKey:@"protocol"], [via objectForKey:@"clientIP"], [[via objectForKey:@"clientPort"] unsignedIntValue], ackBranch,
                     maxForwards,
                     [from objectForKey:@"sender"], [from objectForKey:@"tag"],
                     [response objectForKey:@"To"],
                     callID,
                     ackCSeq];
    
    [delegate dialog:self wantsToSendData:[ack dataUsingEncoding:NSUTF8StringEncoding]];
    
    [previousAcks setObject:ack forKey:[NSString stringWithFormat:@"%@", [response objectForKey:@"CSeq"]]];
    
    if (ackCSeq == cseq) {
        cseq += 1;
    }
    
    NSLog(@"\nACK with packet:\n%@\n", ack);
}

/**
 * Queues up a response to a received BYE message.
 */
- (void)byeResponse:(NSDictionary *)request fromAddr:(NSData *)remoteAddr {
    struct sockaddr_in *addr = (struct sockaddr_in *)[remoteAddr bytes];
    char ip_string[INET_ADDRSTRLEN];
    
    inet_ntop(AF_INET, &(addr->sin_addr), ip_string, INET_ADDRSTRLEN);
    
    NSString *response = [NSString stringWithFormat:@"SIP/2.0 200 OK\r\n"
                          @"Via: %@;rport=%d;received=%s\r\n"
                          @"From: %@\r\n"
                          @"To: %@\r\n"
                          @"Call-ID: %@\r\n"
                          @"CSeq %@\r\n"
                          @"Content-Length: 0\r\n\r\n",
                          [request objectForKey:@"Via"], ntohs(addr->sin_port), ip_string,
                          [request objectForKey:@"From"],
                          [request objectForKey:@"To"],
                          [request objectForKey:@"Call-ID"],
                          [request objectForKey:@"CSeq"]];
    
    NSLog(@"\nBYE Response:\n%@\n", response);
    [delegate dialog:self wantsToSendData:[response dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark INVITE main control flow

/**
 * Any INVITE with a change in the packet (new SDP, Authorization added in) must
 * have a new branch ID. All non-200 ACKs must use the corresponding INVITEs branch ID.
 * A 200 ACK uses a new branch ID.
 *
 * TODO: Get rid of this Auth Header and authenticate in a different way so the method can
 * be reduced to just "invite"
 *
 * TODO: If packet does not generate, send bubble up failure
 */
- (void)inviteWithAuthHeader:(NSString *)key {
    self.authLine = [self generateAuthLine:@"INVITE" headerKey:key];
    self.branch = [self generateBranch];
    NSString *packet = [self generateInvite];
    
    NSLog(@"\nInvite packet:\n%@\n\n", packet);
    
    if (!packet) {
        return;
    }
    
    [delegate dialog:self wantsToSendData:[packet dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark INVITE interpreting data

- (NSDictionary *)parseSDP:(NSString *)sdp {
    if (!sdp) {
        return nil;
    }
    
    SDPParser *sdpParser = [[[SDPParser alloc] initWithSDP:sdp] autorelease];
    if (!sdpParser) {
        return nil;
    }
    
    MediaDescription *audioDest = [sdpParser audioDescription];
    MediaDescription *videoDest = [sdpParser videoDescription];
    
    if (!audioDest || !videoDest) {
        return nil;
    }
    
    NSMutableDictionary *mediaDest = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (audioDest) {
        [mediaDest setObject:audioDest forKey:@"audio"];
    }
    
    if (videoDest) {
        [mediaDest setObject:videoDest forKey:@"video"];
    }
    
    return mediaDest;
}

/**
 * This method figures out what to do based on a received SIP packet.
 */
- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body fromAddr:(NSData *)remoteAddr {
    NSString *statusLine = [parsedPacket objectForKey:@"Status-Line"];
    if (!statusLine) {
        return;
    }
    if ([statusLine compare:@"SIP/2.0 200 OK"] == NSOrderedSame) {
        [self ackResponse:parsedPacket withBranch:[NSString uuid]];
        // If we already have an RTP stream then we can ignore this;
        // if we enable re-invites this will have to change
        if (!mediaDestination) {
            mediaDestination = [[self parseSDP:body] retain];
            NSLog(@"media destination:\n%@\n", mediaDestination);
         
            if (mediaDestination) {
                [delegate dialog:self beganRTPStreamWithMediaDestination:mediaDestination];
            }
        }
    } else if ([statusLine compare:@"SIP/2.0 401 Unauthorized"] == NSOrderedSame) {
        NSString *authRequest = [parsedPacket objectForKey:@"WWW-Authenticate"];
        if (authRequest) {
            [self ackResponse:parsedPacket withBranch:nil];
            [self parseAuthentication:authRequest];
            [self inviteWithAuthHeader:@"Authorization"];
        }
    } else if ([statusLine compare:@"SIP/2.0 407 Proxy Authentication Required"] == NSOrderedSame) {
        NSString *authRequest = [parsedPacket objectForKey:@"Proxy-Authenticate"];
        if (authRequest) {
            [self ackResponse:parsedPacket withBranch:nil];
            [self parseAuthentication:authRequest];
            [self inviteWithAuthHeader:@"Proxy-Authorization"];
        }
    } else if ([statusLine rangeOfString:@"BYE "].location != NSNotFound) {
        [self byeResponse:parsedPacket fromAddr:remoteAddr];
        [delegate dialog:self endRTPStreamWithMediaDestination:mediaDestination];
        [delegate dialogSessionEnded:self];
    } else {
        NSLog(@"Unrecognized Response: %@\n", statusLine);
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    if (previousAcks) {
        [previousAcks release];
        previousAcks = nil;
    }
    
    if (sps) {
        [sps release];
        sps = nil;
    }
    
    if (pps) {
        [pps release];
        pps = nil;
    }
    
    if (mediaDestination) {
        [mediaDestination release];
        mediaDestination = nil;
    }
    
    [super dealloc];
}

@end










