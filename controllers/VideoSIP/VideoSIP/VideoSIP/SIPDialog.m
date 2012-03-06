//
//  SIPDialog.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SIPDialog.h"

#import <uuid/uuid.h>

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
@synthesize nonce;
@synthesize auth;

@synthesize writeQueue;

@synthesize delegate;

- (id)initWithUser:(NSString *)_user contactURI:(NSString *)_contactURI remoteURI:(NSString *)_remoteURI udpClientIP:(NSString *)_udpClientIP udpClientPort:(NSUInteger)_udpClientPort udpServerPort:(NSUInteger)_udpServerPort writeQueue:(NSMutableArray *)_writeQueue delegate:(id<SIPDialogDelegate>)_delegate {

    self = [super init];
    if (self) {
        self.user = _user;
        self.contactURI = _contactURI;
        self.remoteURI = _remoteURI;
        self.udpClientIP = _udpClientIP;
        self.udpClientPort = _udpClientPort;
        self.udpServerPort = _udpServerPort;
        
        self.via = [NSMutableDictionary dictionaryWithCapacity:3];
        [via setObject:@"SIP/2.0/UDP" forKey:@"protocol"];
        [via setObject:@"clientIP" forKey:udpClientIP];
        [via setObject:@"clientPort" forKey:[NSNumber numberWithUnsignedInt:udpClientPort]];
        
        self.maxForwards = 70;
        
        self.from = [NSMutableDictionary dictionaryWithCapacity:2];
        uuid_t generated_from_tag;
        uuid_generate(generated_from_tag);
        [from setObject:@"sender" forKey:[NSString stringWithFormat:@"<%@>", contactURI]];
        [from setObject:@"tag" forKey:[[[NSString alloc] initWithBytes:generated_from_tag length:16 encoding:NSUTF8StringEncoding] autorelease] ];
        
        self.to = [NSMutableDictionary dictionaryWithCapacity:2];
        [to setObject:@"remoteContact" forKey:[NSString stringWithFormat:@"<%@>", remoteURI]];
        
        uuid_t generated_call_id;
        uuid_generate(generated_call_id);
        self.callID = [[[NSString alloc] initWithBytes:generated_call_id length:16 encoding:NSUTF8StringEncoding] autorelease];
        
        self.cseq = 101;
        
        self.contact = [NSString stringWithFormat:@"<sip:%@@%@:%d>", user, udpClientIP, udpClientPort];
        
        self.userAgent = @"Phone";
        
        self.allow = @"INVITE, ACK, BYE, CANCEL, OPTIONS, PRACK, MESSAGE, UPDATE";
        self.supported = @"timer, 100rel, path";
        
        self.branch = nil;
        self.nonce = nil;
        self.auth = nil;
        
        self.writeQueue = _writeQueue;
        
        self.delegate = delegate;
    }
    
    return self;
}

- (NSString *)generateBranch {
    uuid_t branch_suffix;
    uuid_generate(branch_suffix);
    return [NSString stringWithFormat:@"z9hG4bK%@", [[[NSString alloc] initWithBytes:branch_suffix length:16 encoding:NSUTF8StringEncoding] autorelease]];
}

- (NSString *)generateAuthLine:(NSString *)requestType {
    if (!self.nonce || !self.sipURI || !requestType) {
        return nil;
    }
        
    NSString *ha1 = [[NSString stringWithFormat:@"%@:asterisk:saywhat", self.user] md5];
    NSString *ha2 = [[NSString stringWithFormat:@"%@:%@", requestType, sipURI] md5];
    NSString *ha3 = [[NSString stringWithFormat:@"%@:%@:%@", ha1, nonce, ha2] md5];
    
    self.auth = [NSString stringWithFormat:@"Authorization: Digest username=%@, realm=\"asterisk\", nonce=%@, algorithm=MD5, uri=%@, response=%@\r\n", user, nonce, sipURI, ha3];
    
    return auth;
}

- (NSString *)genSDP {
    return [NSString stringWithFormat:@"v=0\r\no=- 0 0 IN IP4 %@\r\ns=%@\r\nc=IN IP4 %@\r\nt=0 0\r\na=range:npt=now-\r\nm=audio 7078 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\na=sendrecv\r\nm=video 9078 RTP/AVP 99\r\nb=AS:1372\r\na=rtpmap:97 H264/90000\r\na=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPz,aM4jyA==\r\nmpeg4-esid:201\r\n", udpClientIP, user, udpClientIP];
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
    self.nonce = nil;
    self.auth = nil;
    
    self.delegate = nil;
    
    [super dealloc];
}

@end



@implementation RegisterDialog

- (NSString *)generateRegister {
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
    
    if (auth) {
        registerHdr = [NSString stringWithFormat:@"%@%@", registerHdr, auth];
    }
    
    registerHdr = [NSString stringWithFormat:@"%@%@", registerHdr, @"Content-Length: 0\r\n\r\n"];
    
    cseq += 1;
    
    return registerHdr;
}

- (void)registerToAsteriskWithCallID:(uuid_t)registerCallID {
    self.callID = [[[NSString alloc] initWithBytes:registerCallID length:16 encoding:NSUTF8StringEncoding] autorelease];
    
    self.auth = [self generateAuthLine:@"REGISTER"];
    NSString *packet = [self generateRegister];
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
    
    if (auth) {
        invite = [NSString stringWithFormat:@"%@%@", invite, auth];
    }
    
    NSString *sdpPacket = [self genSDP];
    
    invite = [NSString stringWithFormat:@"%@%@%d%@%@", invite, @"Content-Length: ", [sdpPacket length], @"\r\n\r\n", sdpPacket];
    
    cseq += 1;
    
    return invite;
}

- (void)invite {
    self.auth = [self generateAuthLine:@"INVITE"];
    NSString *packet = [self generateInvite];
    
    //TODO: send this packet out
}

@end










