//
//  SIPDialog.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPDialog.h"

#import <CoreFoundation/CoreFoundation.h>
#import <netdb.h>
#import <arpa/inet.h>

#import "MyExtensions.h"


@implementation SIPDialog

@synthesize user;
@synthesize contactURI;
@synthesize remoteURI;
@synthesize sipURI;
@synthesize udpClientIP;
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

@synthesize writeQueue;

@synthesize delegate;

- (id)initWithUser:(NSString *)_user contactURI:(NSString *)_contactURI remoteURI:(NSString *)_remoteURI udpClientIP:(NSString *)_udpClientIP udpClientPort:(NSUInteger)_udpClientPort udpServerPort:(NSUInteger)_udpServerPort writeQueue:(NSMutableArray *)_writeQueue delegate:(id<SIPDialogDelegate>)_delegate {

    self = [super init];
    if (self) {
        self.user = _user;
        self.contactURI = _contactURI;
        self.remoteURI = _remoteURI;
        self.sipURI = _remoteURI;
        self.udpClientIP = _udpClientIP;
        self.udpClientPort = _udpClientPort;
        self.udpServerPort = _udpServerPort;
        
        self.via = [NSMutableDictionary dictionaryWithCapacity:3];
        [via setObject:@"SIP/2.0/UDP" forKey:@"protocol"];
        [via setObject:udpClientIP forKey:@"clientIP"];
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
        
        self.contact = [NSString stringWithFormat:@"<sip:%@@%@:%d>", user, udpClientIP, udpClientPort];
        
        self.userAgent = @"Phone";
        
        self.allow = @"INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE";
        self.supported = @"timer, 100rel, path";
        
        self.branch = nil;
        self.authLine = nil;
        self.auth = [NSMutableDictionary dictionaryWithCapacity:10];
        
        self.writeQueue = _writeQueue;
        
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

- (NSString *)generateAuthLine:(NSString *)requestType {
    NSString *nonce = [auth objectForKey:@"nonce"];
    NSString *realm = [auth objectForKey:@"realm"];
    if (!nonce || !realm || !self.sipURI || !requestType) {
        return nil;
    }
        
    NSString *ha1 = [[NSString stringWithFormat:@"%@:%@:saywhat", self.user, realm] md5];
    NSString *ha2 = [[NSString stringWithFormat:@"%@:%@", requestType, sipURI] md5];
    NSString *ha3 = [[NSString stringWithFormat:@"%@:%@:%@", ha1, nonce, ha2] md5];
    
    self.authLine = [NSString stringWithFormat:@"Authorization: Digest username=%@, realm=\"asterisk\", nonce=%@, algorithm=MD5, uri=%@, response=%@\r\n", user, nonce, sipURI, ha3];
    
    return authLine;
}

- (NSString *)genSDP {
    return [NSString stringWithFormat:@"v=0\r\no=- 0 0 IN IP4 %@\r\ns=%@\r\nc=IN IP4 %@\r\nt=0 0\r\na=range:npt=now-\r\nm=audio 7078 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\na=sendrecv\r\nm=video 9078 RTP/AVP 99\r\nb=AS:1372\r\na=rtpmap:97 H264/90000\r\na=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPz,aM4jyA==\r\nmpeg4-esid:201\r\n", udpClientIP, user, udpClientIP];
}

- (void)parseAuthentication:(NSString *)authResponse {
    //NSArray *components = [authLine componentsSeparatedByString:@", "];
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

- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body {
    NSLog(@"This method should be overwritten");
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    self.user = nil;
    self.contactURI = nil;
    self.remoteURI = nil;
    self.sipURI = nil;
    self.udpClientIP = nil;
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
                             @"CSeq: %d INVITE\r\n"
                             @"Contact: %@\r\n"
                             @"User-Agent: %@\r\n"
                             @"Allow: %@\r\n"
                             @"Supported: %@\r\n",
                             sipURI,
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
    
    self.authLine = [self generateAuthLine:@"REGISTER"];
    NSString *packet = [self generateRegister];
    
    [delegate dialog:self wantsToSendData:[packet dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[writeQueue addObject:[packet dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)interpretSIP:(NSDictionary *)parsedPacket body:(NSString *)body {
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
        NSLog(@"Unrecognized Response: %@", statusLine);
    }
}

@end


@implementation OptionsDialog

- (void)receivedOptions:(NSDictionary *)optionsPacket fromAddr:(NSData *)remoteAddr {
    // respond to the packet
    struct sockaddr_in *addr = (struct sockaddr_in *)[remoteAddr bytes];
    char ip_string[INET_ADDRSTRLEN];

    inet_ntop(AF_INET, &(addr->sin_addr), ip_string, INET_ADDRSTRLEN);

    NSArray *remoteVia = [[optionsPacket objectForKey:@"Via"] componentsSeparatedByString:@";"];

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


@implementation InviteDialog

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
    
    invite = [NSString stringWithFormat:@"%@%@%d%@%@", invite, @"Content-Length: ", [sdpPacket length], @"\r\n\r\n", sdpPacket];
    
    cseq += 1;
    
    return invite;
}

- (void)invite {
    self.authLine = [self generateAuthLine:@"INVITE"];
    NSString *packet = [self generateInvite];
    
    [delegate dialog:self wantsToSendData:[packet dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[writeQueue addObject:[packet dataUsingEncoding:NSUTF8StringEncoding]];
}

@end










