//
//  sRTSP.m
//  sRTSP
//
//  Created by Steve McFarlin on 7/14/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//
//	License: At bottom of file to avoid header licensing corruption.
//
//	Notes:
//	
//	Given that I currently do not know what I am doing. 
//	Yea. Umm. This does stuff.
//

#import "RTSPClient.h"

//RTSP Header Response Limits

#define RTSP_MAX_HEADER 4095
#define RTSP_MAX_BODY 4095

#define kCRLF			@"\r\n"

// RTSP request format strings
#define kOptions		@"OPTIONS %@ RTSP/1.0\r\n"
#define kDescribe		@"DESCRIBE %@ RTSP/1.0\r\n"
#define kAnnounce		@"ANNOUNCE %@ RTSP/1.0\r\n"
#define kSetupPublish	@"SETUP %@/streamid=%d RTSP/1.0\r\n"
#define kSetupPlay		@"SETUP %@/trackID=%d RTSP/1.0\r\n"
#define kRecord			@"RECORD %@ RTSP/1.0\r\n"
#define kPlay			@"PLAY %@ RTSP/1.0\r\n"
#define kTeardown		@"TEARDOWN %@ RTSP/1.0\r\n"

//RTSP header format strings
#define kCseq			@"Cseq: %d\r\n"
#define kContentLength	@"Content-Length: %d\r\n"
#define kContentType	@"Content-Type: %@\r\n"
#define kTransport		@"Transport: RTP/AVP/%@;unicast;%@;mode=%@\r\n"
#define kSession		@"Session: %@\r\n"
#define kRange			@"Range: %@\r\n"
#define kAccept			@"Accept: %@\r\n"
#define kNoCache        @"Cache-Control:no-cache\r\n"
#define kAuthBasic		@"Authorization: Basic %@\r\n"
#define kAuthDigest		@"Authorization: Digest username=\"%@\",realm=\"%@\",nonce=\"%@\",uri=\"%@\",response=\"%@\"\r\n"


//RTSP header keys
#define kSessionKey		@"Session"
#define kWWWAuthKey		@"WWW-Authenticate"


//RTSP Tranport 


#pragma mark -
#pragma mark Class Extention
#pragma mark -

@interface RTSPClient ()
@property (nonatomic, retain, readwrite) NSString *host, *path;
@property (nonatomic, assign, readwrite) int port;
@property (nonatomic, retain, readwrite) NSMutableDictionary *responseHeader;
@property (nonatomic, assign, readwrite) NSString *session;

- (NSString*)md5HexDigest:(NSString*)input;

- (int) parseResponse:(NSString*) response;
- (int) optionsResponse;
- (int) announceBasicAuth;
- (int) announceDigestAuth;
- (int) announceResponse;
- (int) setupResponse;
- (int) recordResponse;
- (int) teardownResponse;
/*!
 @abstract Send the request
 @result int 0 for success else SOCK_ERR_XXX
 */
- (int) write:(NSString*) request;
- (NSString*) read;
@end



/**
 @abstract RTSP Protocol 1.0.
 @discussion
 
 This class partially implements the RTSP protocol. For the most part this 
 was born out of nessesity, and pragmitism has been the driving force of 
 it's implementation. As such it is implement to get a job done quickly.
 
 */
@implementation RTSPClient
@synthesize transport, sdp;
@synthesize host, port, path, user, pass;
@synthesize mediaCount;
@synthesize session;
@synthesize sock;
@synthesize responseHeader;
@synthesize streamType;
@dynamic url;

#pragma mark -
#pragma mark Class Lifecycle
#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
		responseHeader = [[NSMutableDictionary alloc] init];
		transport = RTSP_TRANSPORT_TCP;
		streamType = RTSP_PUBLISH;
    }
    
    return self;
}

- (void)dealloc
{
	self.responseHeader = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Dynamic Properties
#pragma mark -

- (NSString*) url {
	return [NSString stringWithFormat:@"rtsp://%@:%d/%@",self.host, self.port, self.path];
}

#pragma mark -
#pragma mark Digest Auth support code
#pragma mark -


- (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
	
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


#pragma mark -
#pragma mark Connection Management
#pragma mark -

- (int) connectTo:(NSString*) _host onPort:(int) _port withPath:(NSString*) _path {
	
	//struct sockaddr_in server;
	//struct hostent *hp;
	
	//TODO: State checks
	
	self.host = _host;
	self.port = _port;
	self.path = _path;
	
    NSLog(@"RTSP client host: %@, port: %d, path: %@", self.host, self.port, self.path);
    /*
	hp = gethostbyname([_host cStringUsingEncoding:NSASCIIStringEncoding]);
    
	if (hp == NULL) {
		NSLog(@"hostent is null");
		return SOCK_ERR_RESOLVE;
	}
	memset(&server, 0, sizeof(server));
	memcpy(&server.sin_addr, hp->h_addr, hp->h_length);
	server.sin_family = hp->h_addrtype;
	server.sin_port = htons(port);
	
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if(sock < 0) {
		NSLog(@"Could not open socket");
		return SOCK_ERR_CREATE;
	}
    
	int val = 1;
    if(setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val)) < 0) {
		//        NSLog(@"Failed to set TCP_NODELAY");
    }
    //    
    //    struct linger {
    //        int   l_onoff;
    //        int   l_linger;
    //    };
    //    
    //    struct linger lng;
    //    lng.l_onoff = 1;
    //    lng.l_linger = 0;
    //    setsockopt(sock, SOL_SOCKET, SO_LINGER, &lng, sizeof lng);
    //	
    //	static struct timeval timeout;
    //	timeout.tv_sec = 8;
    //	timeout.tv_usec = 0;
    //	
    //	setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    //	setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
    
	
	if(connect(sock, (struct sockaddr*) &server, sizeof(server)) == -1) {
		NSLog(@"Connection to host failed");
		return SOCK_ERR_CONNECT;
	}
    //*/
    
    // replacing sock code with code using latest APIs
    //*
    struct addrinfo hints, *servinfo, *p;
    int rv;
    char s[INET6_ADDRSTRLEN];
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    
    
    NSLog(@"host: %s, port: %s", [_host UTF8String], [[NSString stringWithFormat:@"%d", _port] UTF8String]);
    
    if ((rv = getaddrinfo([_host UTF8String], [[NSString stringWithFormat:@"%d", _port] UTF8String], &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return SOCK_ERR_RESOLVE;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sock = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            perror("client: socket");
            continue;
        }
        
        if (connect(sock, p->ai_addr, p->ai_addrlen) == -1) {
            close(sock);
            perror("client: connect");
            continue;
        }
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "client: failed to connect\n");
        freeaddrinfo(servinfo);
        return SOCK_ERR_CONNECT;
    }
        
    inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof(s));
    printf("client: connecting %s\n", s);
    
    freeaddrinfo(servinfo);
    //*/
	
	//Initialize 
	cSeq = 0;
	mediaCount = 0;
	channelCount = 0;
	
	NSLog(@"Connected");
	
	return 0;
}


#pragma mark -
#pragma mark OPTIONS Request Response
#pragma mark -

- (int) options {
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kOptions, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendString:kCRLF];
	
#ifdef DEBUG
	NSLog(@"--- OPTIONS Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	if( ret > -1) { 
		ret = [self optionsResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) optionsResponse {
	NSString *response;
	int responseCode;
    
	response = [self read];
	
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
    
	return responseCode;
}

#pragma mark -
#pragma mark DESCRIBE Request Response
#pragma mark -

- (int) describe {
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kDescribe, self.url];
	[request appendFormat:kAccept, @"application/sdp"];
	[request appendFormat:kCseq, cSeq];
	[request appendString:kCRLF];
	
#ifdef DEBUG
	NSLog(@"--- DESCRIBE Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	if( ret > -1) { 
		ret = [self describeResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) describeResponse {
	NSString *response;
	int responseCode;
	
	response = [self read];
	
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
	
	return responseCode;
}


#pragma mark -
#pragma mark ANNOUNCE Request Response
#pragma mark -

- (int) announce {
	
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kAnnounce, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendFormat:kContentLength, [self.sdp length]];
	[request appendFormat:kContentType, @"application/sdp"];
	
	
	[request appendString:kCRLF];
	if(self.sdp != nil) { [request appendString:self.sdp]; }
	
#ifdef DEBUG
	NSLog(@"--- ANNOUNCE Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self announceResponse];
	}
	
	[request release];
	
	if(ret == RTSP_BAD_USER_PASS) {
        
#ifdef DEBUG
		NSLog(@"--- ANNOUNCE Response ---\n\n%@", responseHeader);
#endif
		
		NSString *wwwauth = [responseHeader valueForKey:kWWWAuthKey];
		if(wwwauth != nil) {
			//NSLog(@"WWW Auth Value: %@", wwwauth);
			NSRange r = [wwwauth rangeOfString:@"Basic"];
			
			if(r.location != NSNotFound) {
				ret = [self announceBasicAuth];
			}
			//We are assuming Digest here.
			else {
				ret = [self announceDigestAuth];
			}
		}
	}
	
	return ret;
}

- (int) announceBasicAuth {
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	char auth[256];
	
	if(user == nil) {
		[request release];
		return RTSP_BAD_USER_PASS;
	}
	
	cSeq++ ;
	NSString *userpass = [NSString stringWithFormat:@"%@:%@", self.user, self.pass];
	base64encode((const unsigned char*)[userpass cStringUsingEncoding:NSASCIIStringEncoding], (int)[userpass length], (unsigned char*)auth, 256);
	[request appendFormat:kAnnounce, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendFormat:kContentLength, [self.sdp length]];
	[request appendFormat:kContentType, @"application/sdp"];
	
	[request appendFormat:kAuthBasic, [NSString stringWithCString:auth encoding:NSASCIIStringEncoding]];
    NSLog(@"auth: %@", [NSString stringWithCString:auth encoding:NSASCIIStringEncoding]);
	
	[request appendString:kCRLF];
	if(self.sdp != nil) {
        [request appendString:self.sdp];
    }
	
#ifdef DEBUG
	NSLog(@"--- ANNOUNCE Basic Auth Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self announceResponse];
	}
	
	[request release];
	
	return ret;
}

//Authorization: Digest username="sgwowza",realm="Streaming Server",nonce="8283e48e87ce761ef86982cb4333a2a1",uri="rtsp://192.168.1.50:554/live/livu",response="178deaa221d691a6bc33f41648654587"
//Authorization: Digest username="sgwowza",realm="Streaming Server",nonce="6b1ea5b41a1201fb1b9af1cf85bff404",uri="rtsp://192.168.1.50:554/live/livu",response="cc12bdec0da14321ffa84b5721598d8a"


- (int) announceDigestAuth {
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	NSString *nonce, *realm;
	NSString *ha1, *ha2, *response;
	
	if(user == nil) {
		[request release];
		return RTSP_BAD_USER_PASS;
	}
	cSeq++ ;
	
	//WWW-Authenticate: Digest realm="Streaming Server",  nonce="206351b944cb28fe37a0794848c2e36f"
	NSString *wwwauth = [responseHeader valueForKey:kWWWAuthKey];
	NSRange r = [wwwauth rangeOfString:@"Digest"];
	NSString *authReq = [wwwauth substringFromIndex:r.location + r.length + 1];
	NSLog(@"Auth Req: %@", authReq);
	NSArray *split = [authReq componentsSeparatedByString:@","];
	realm = [split objectAtIndex:0];
	nonce = [split objectAtIndex:1];
	
	split = [realm componentsSeparatedByString:@"="];
	realm = [split objectAtIndex:1];
	r.location = 1; r.length = [realm length] - 2;
	realm = [realm substringWithRange:r];
	
	split = [nonce componentsSeparatedByString:@"="];
	nonce = [split objectAtIndex:1];
	r.location = 1; r.length = [nonce length] - 2;
	nonce = [nonce substringWithRange:r];
	
	NSLog(@"realm=%@", realm);
	NSLog(@"nonce=%@", nonce);
	
	ha1 = [self md5HexDigest:[NSString stringWithFormat:@"%@:%@:%@", self.user, realm, self.pass]];
	ha2 = [self md5HexDigest:[NSString stringWithFormat:@"ANNOUNCE:%@", self.url]];
	response = [self md5HexDigest:[NSString stringWithFormat:@"%@:%@:%@", ha1, nonce, ha2]];
	
	[request appendFormat:kAnnounce, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendFormat:kContentLength, [self.sdp length]];
	[request appendFormat:kContentType, @"application/sdp"];
	[request appendFormat:kAuthDigest, self.user, realm, nonce, self.url, response];
	
	[request appendString:kCRLF];
	if(self.sdp != nil) { [request appendString:self.sdp]; }
	
#ifdef DEBUG
	NSLog(@"--- ANNOUNCE Digest Auth Request ---\n\n%@", request);
#endif
	
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self announceResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) announceResponse {
	NSString *response, *tempString;
	int responseCode;
	
	response = [self read];
	if (response == Nil) { return SOCK_ERR_READ ;}
    
	responseCode = [self parseResponse:response];
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
	
	tempString = [responseHeader valueForKey:kSessionKey];
    /*
     if (tempString == nil) { return RTSP_RESP_ERR_SESSION; }
     */
    if (tempString) {
        //Parse session
        NSArray *items = [tempString componentsSeparatedByString:@";"];
        tempString = [items objectAtIndex:0];
        self.session = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
	//self.session = [tempString intValue];
	
	return responseCode;
}

#pragma mark -
#pragma mark SETUP Request Response
#pragma mark -

- (int) setup:(int) streamID withRtpPort:(int) rtpPort andRtcpPort:(int) rtcpPort {
    char auth[256];
	NSMutableString *request = [[NSMutableString alloc] init];
	NSString *tempString;
    
	int ret = 0;
	cSeq++ ;
	if(streamType == RTSP_PUBLISH)
		[request appendFormat:kSetupPublish, self.url, streamID];
	else 
        [request appendFormat:kSetupPlay, self.url, 1];//streamID];
	
    /*
	if(transport == RTSP_TRANSPORT_TCP) {
		if(streamType == RTSP_PUBLISH) {
            if (self.session) {
                [request appendFormat:kSession, self.session];
            }
			tempString = [NSString stringWithFormat:@"interleaved=%d-%d",channelCount++, channelCount++];
			[request appendFormat:kTransport, @"TCP", tempString, @"receive"];
			mediaCount = channelCount / 2;
		}
		else {
			tempString = [NSString stringWithFormat:@"interleaved=%d-%d",channelCount++, channelCount++];
			[request appendFormat:kTransport, @"TCP", tempString, @"play"];
			mediaCount = channelCount / 2;
		}
	}
	else if(transport == RTSP_TRANSPORT_UDP) {
		if(streamType == RTSP_PUBLISH) {
            if (self.session) {
                [request appendFormat:kSession, self.session];
            }
			tempString = [NSString stringWithFormat:@"client_port=%d-%d",rtpPort, rtcpPort];
			[request appendFormat:kTransport, @"UDP", tempString, @"receive"];
		}
		else {
			tempString = [NSString stringWithFormat:@"client_port=%d-%d",rtpPort, rtcpPort];
			[request appendFormat:kTransport, @"UDP", tempString, @"play"];
		}
	}
    */
    
    if (self.session) {
        [request appendFormat:kSession, self.session];
    }
    tempString = [NSString stringWithFormat:@"client_port=%d-%d", rtpPort, rtcpPort];
    [request appendFormat:kTransport, @"UDP", tempString, @"record"];
    
    //[request appendFormat:kNoCache];
    
    NSString *userpass = [NSString stringWithFormat:@"%@:%@", self.user, self.pass];
	base64encode((const unsigned char*)[userpass cStringUsingEncoding:NSASCIIStringEncoding], (int)[userpass length], (unsigned char*)auth, 256);
    
	[request appendFormat:kAuthBasic, [NSString stringWithCString:auth encoding:NSASCIIStringEncoding]];
	[request appendFormat:kCseq, cSeq];
	
	
	[request appendString:kCRLF];
#ifdef DEBUG
	NSLog(@"--- SETUP Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self setupResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) setupResponse {
	NSString *response, *tempString;
	int responseCode;
	
	response = [self read];
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
    
	//if(streamType == RTSP_PLAY) {
		tempString = [responseHeader valueForKey:kSessionKey];
		if (tempString == nil) { return RTSP_RESP_ERR_SESSION; }
		
		//Parse session
		NSArray *items = [tempString componentsSeparatedByString:@";"];
		tempString = [items objectAtIndex:0];
		self.session = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		//self.session = [tempString intValue];
	//}
	
	return responseCode;
}

#pragma mark -
#pragma mark SETUP Request Response
#pragma mark -

- (int) record{
	NSMutableString *request = [[NSMutableString alloc] init];
    char auth[256];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kRecord, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendFormat:kSession, self.session];
	//[request appendFormat:kRange, @"npt=now-"];
    
    NSString *userpass = [NSString stringWithFormat:@"%@:%@", self.user, self.pass];
	base64encode((const unsigned char*)[userpass cStringUsingEncoding:NSASCIIStringEncoding], (int)[userpass length], (unsigned char*)auth, 256);
    
    [request appendFormat:kAuthBasic, [NSString stringWithCString:auth encoding:NSASCIIStringEncoding]];
	[request appendString:kCRLF];
	
#ifdef DEBUG
	NSLog(@"--- RECORD Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self recordResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) recordResponse {
	NSString *response;
	int responseCode;
	
	response = [self read];
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
	
	return responseCode;
}

#pragma mark -
#pragma mark PLAY Request Response
#pragma mark -

- (int) play{
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kPlay, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendFormat:kSession, self.session];
	[request appendFormat:kRange, @"npt=0.000-"];
	[request appendString:kCRLF];
	
#ifdef DEBUG
	NSLog(@"--- PLAY Request ---\n\n%@", request);
#endif
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self playResponse];
	}
	
	[request release];
	
	return ret;
}

- (int) playResponse {
	NSString *response;
	int responseCode;
	
	response = [self read];
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
	
	return responseCode;
}


#pragma mark -
#pragma mark TEARDOWN Request Response
#pragma mark -


- (int) teardown{
	NSMutableString *request = [[NSMutableString alloc] init];
	int ret = 0;
	cSeq++ ;
	
	[request appendFormat:kTeardown, self.url];
	[request appendFormat:kCseq, cSeq];
	[request appendString:kCRLF];
	
#ifdef DEBUG
	NSLog(@"--- TEARDOWN Request ---\n\n%@", request);
#endif
	
	ret = [self write:request];
	
	if( ret > -1) { 
		ret = [self teardownResponse];
	}
	
	[request release];
	
	close(self->sock);
	
	return ret;
}

- (int) teardownResponse {
	NSString *response;
	int responseCode;
	
	response = [self read];
	if (response == Nil) { return SOCK_ERR_READ ;}
	
	responseCode = [self parseResponse:response];
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
	
	return responseCode;
}

#pragma mark -
#pragma mark Parsing Routines
#pragma mark -

- (int) parseResponse:(NSString*) response {
	//Parse response string
    NSLog(@"----------  Response -----------");
    NSLog(@"\n%@",response);
    NSLog(@"-----------------------");
    
	int responseCode = 0;
	NSString *tempString, *key, *value;
	
	NSArray *lines = [response componentsSeparatedByString:kCRLF];
	
	NSArray *items = [response componentsSeparatedByString:@" "];
	
	if( [items count] < 2)
		return RTSP_RESP_ERR;
	
	
	responseCode = [[items objectAtIndex:1] intValue];
	
	if(responseCode == RTSP_RESP_ERR) { return responseCode; }
	
	[responseHeader removeAllObjects];
	//Parse response header into key value pairs.
	for(int i = 1; i < [lines count]; i++) {
		tempString = [lines objectAtIndex:i];
		if ([tempString length] == 0) { break ; }
		
		NSRange range = [tempString rangeOfString:@":"];
		if(range.location == -1)
			continue;
		
		key = [tempString substringToIndex:range.location];
		value = [tempString substringFromIndex:range.location + 1] ;
        NSLog(@"key: %@, value: %@", key, value);
		[responseHeader setValue:value forKey:key];
	}
	
	
	return responseCode;
}



#pragma mark -
#pragma mark Parsing Routines
#pragma mark -

- (int) write:(NSString*) request {
	ssize_t len, sent = 0;
	const char *preq;
	
	preq = [request cStringUsingEncoding:NSASCIIStringEncoding];
	len = [request length];
	
	while (len > 0) {
		size_t count = len - sent;
		sent = send(sock, preq, count, 0);
		if(sent == -1) {
			return SOCK_ERR_WRITE;
		}
		preq += sent;
		len -= sent;
	}
	return 0;
}

- (NSString*) read {
	ssize_t len;
	char header[RTSP_MAX_HEADER + 1];
	NSString *response = nil;
	
	len = recv(sock, header, RTSP_MAX_HEADER, 0);
	if(len != -1) {
		header[len] = '\0';
		response = [NSString stringWithCString:header encoding:NSASCIIStringEncoding];
	}
	
	return response;
}

@end
