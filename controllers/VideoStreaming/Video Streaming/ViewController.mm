//
//  ViewController.m
//  Video Streaming
//
//  Created by Rex Fenley on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "rtpenc_h264.h"
#import "base64.h"

enum avtype {
	AV_TYPE_AUDIO,
	AV_TYPE_VIDEO
};
typedef enum avtype AVType;

@interface AVPacket : NSObject {
@public
	NSData *data;
	AVType type;
	uint32_t size;
	uint64_t time;
	uint64_t sample_time;
}
@end

@implementation AVPacket 
- (void) dealloc {
	[data release];
	[super dealloc];
}

@end

//*
@interface ViewController()

- (IplImage *)IplImageFromCGImage:(CGImageRef)imageRef;
- (CGImageRef)CGImageFromIplImage:(IplImage *)iplImage;

@end
//*/
 
 
static NSString *fullsdp = @"v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=Livu\r\nc=IN IP4 %s\r\nt=0 0\r\na=tool:Livu RTP\r\nm=audio 0 RTP/AVP 96\r\nb=AS:64\r\na=rtpmap:96 MPEG4-GENERIC/44100/1\r\na=fmtp:96 profile-level-id=1;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3; config=1208\r\na=control:streamid=0\r\nm=video 0 RTP/AVP 97\r\nb=AS:64\r\na=rtpmap:97 H264/90000\r\na=fmtp:97 packetization-mode=1;sprop-parameter-sets=%@,%@\r\na=control:streamid=1";


//AU Headers
static NSString *audio_sdp = @"v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=Livu\r\nc=IN IP4 %s\r\nt=0 0\r\na=tool:Livu RTP\r\nm=audio 0 RTP/AVP 97\r\nb=AS:64\r\na=rtpmap:96 MPEG4-GENERIC/44100/1\r\na=fmtp:97 profile-level-id=1;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3; config=1208\r\na=control:streamid=0";

//static NSString *video_sdp = @"v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=Livu\r\nc=IN IP4 %@\r\nt=0 0\r\na=tool:Livu RTP\r\nm=video 0 RTP/AVP 97\r\nb=AS:64\r\na=rtpmap:97 H264/90000\r\na=fmtp:97 packetization-mode=1;sprop-parameter-sets=%@,%@\r\na=control:streamid=1";
//*
static NSString *video_sdp = @"v=0\r\n"
        @"o=- 536 3212164818 IN IP4 127.0.0.0\r\n"
        @"s=QuickTime\r\n"
        @"c=IN IP4 %s\r\n"
        @"t=0 0\r\n"
        @"a=range:npt=now-\r\n"
        @"a=isma-compliance:2,2.0,2\r\n"
@"m=audio 5002 RTP/AVP 96\r\n"
@"b=AS:64\r\n"
@"a=rtpmap:96 mpeg4-generic/44100/1\r\n"
@"a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n"
@"a=mpeg4-esid:101\r\n"
@"a=control:trackid=1\r\n"
        @"m=video 5002 RTP/AVP 97\r\n"
        @"b=AS:1372\r\n"
        @"a=rtpmap:97 H264/90000\r\n"
        @"a=fmtp:97 packetization-mode=1;sprop-parameter-sets=%@,%@\r\n"
        @"a=mpeg4-esid:201\r\n"
        @"a=cliprect:0,0,480,640\r\n"
        @"a=framesize:97 640-480\r\n"
        @"a=control:trackid=2\r\n";
//*/

//@"v=0\r\no=- 536 3212164818 IN IP4 127.0.0.0\r\ns=QuickTime\r\nc=IN IP4 %s\r\nt=0 0\r\na=range:npt=now-\r\na=isma-compliance:2,2.0,2\r\nm=audio 5002 RTP/AVP 96\r\nb=AS:64\r\na=rtpmap:96 mpeg4-generic/44100/1\r\na=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\na=mpeg4-esid:101\r\na=control:trackid=1\r\nm=video 5002 RTP/AVP 97\r\nb=AS:1372\r\na=rtpmap:97 H264/90000\r\na=fmtp:97 packetization-mode=1;sprop-parameter-sets=%@,%@\r\na=mpeg4-esid:201\r\na=cliprect:0,0,480,640\r\na=framesize:97 640-480\r\na=control:trackid=2\r\n"

/*
static NSString *video_sdp = @"v=0\r\n"
@"o=- 536 3212164818 IN IP4 127.0.0.0\r\n"
@"s=QuickTime\r\n"
@"c=IN IP4 10.0.190.5\r\n"
@"t=0 0\r\n"
@"a=range:npt=now-\r\n"
@"a=isma-compliance:2,2.0,2\r\n"
@"m=audio 6970 RTP/AVP 96\r\n"
@"b=AS:64\r\n"
@"a=rtpmap:96 mpeg4-generic/44100/1\r\n"
@"a=fmtp:96 profile-level-id=15;mode=AAC-hbr;sizelength=13;indexlength=3;indexdeltalength=3;config=1388\r\n"
@"a=mpeg4-esid:101\r\n"
@"a=control:trackid=1\r\n"
@"m=video 6970 RTP/AVP 97\r\n"
@"b=AS:1372\r\n"
@"a=rtpmap:97 H264/90000\r\n"
@"a=fmtp:97 packetization-mode=1;sprop-parameter-sets=Z0IAHo1oCgPZ,aM4JyA==\r\n"
@"a=mpeg4-esid:201\r\n"
@"a=cliprect:0,0,480,640\r\n"
@"a=framesize:97 640-480\r\n"
@"a=control:trackid=2\r\n";
//*/



int hostname_to_ip(char *hostname, char *ip) {
    struct hostent *he;
    struct in_addr **addr_list;
    int i;
    
    if ((he = gethostbyname(hostname)) == NULL) {
        herror("gethostbyname");
        return 1;
    }
    
    addr_list = (struct in_addr **)he->h_addr_list;
    
    for (i = 0; addr_list[i] != NULL; i++) {
        strcpy(ip, inet_ntoa(*addr_list[i]));
        return 0;
    }
    
    return 1;
}


#define HOST "rex-desktop"
#define PORT "40500"

#define RTSP_HOST "tpmini.internal.trickplay.com"
#define RTSP_PORT 554
#define RTSP_PATH "sample.sdp"

@implementation ViewController

@synthesize avcEncoder;
@synthesize socketManager;
@synthesize captureSession;
@synthesize imageView;
@synthesize customLayer;
@synthesize prevLayer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Network

void rtp_avc_session_callback(struct rtp *session, rtp_event *e) {
}

void *get_in_addr(struct sockaddr *sa) {
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }
    
    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

- (int)setUpNetwork {
    timeout.tv_sec = 5;
    timeout.tv_usec = 0;
    avc_session_id = 97;
    
    pxbuffer = NULL;
    
    socket_queue = dispatch_queue_create("Network Queue", NULL);
    image_processing_queue = dispatch_queue_create("Image Processing Queue", NULL);
    
    if (YES) {
        return 0;
    }
    
    avc_session = rtp_init_udp(HOST, 5002, 40500, 60, 2000, rtp_avc_session_callback, self);
    
    if (avc_session == NULL) {
        return 1;
    }
    
    struct addrinfo hints, *servinfo, *p;
    int rv;
    char s[INET6_ADDRSTRLEN];
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    
    if (YES) {
        return 0;
    }
    
    if ((rv = getaddrinfo(HOST, PORT, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            perror("client: socket");
            continue;
        }
        
        if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("client: connect");
            continue;
        }
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "client: failed to connect\n");
        return 2;
    }
    
    inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof(s));
    printf("client: connecting %s\n", s);
    
    return 0;
}

- (NSString*) generateSDP {
	unsigned char csps[32], cpps[32];
	NSString *b64sps = nil, *b64pps = nil, *sdp = nil;
	
	//if (profile.broadcastType != kBroadcastTypeAudio) {
		int length = base64encode(((unsigned char *)[sps bytes]) + 4, [sps length] - 4, csps, 32);
		csps[length] = '\0';
		b64sps = [NSString stringWithCString:(const char*)csps encoding:NSASCIIStringEncoding];
		
		//NSLog(@"SPS Len: %d", length);
		
		length = base64encode(((unsigned char *)[pps bytes]) + 4, [pps length] - 4, cpps, 32);
		cpps[length] = '\0';
		b64pps = [NSString stringWithCString:(const char*)cpps encoding:NSASCIIStringEncoding];
	//}
	
    /*
	switch (profile.broadcastType) {
		case kBroadcastTypeAudio:
			sdp = [NSString stringWithFormat:audio_sdp, self.profile.address];
			break;
			
		case kBroadcastTypeVideo: 
			sdp = [NSString stringWithFormat:video_sdp, self.profile.address, b64sps, b64pps];
			break;
			
		case kBroadcastTypeAudioVideo:
			sdp = [NSString stringWithFormat:fullsdp, self.profile.address, b64sps, b64pps];
			break;
		default:
			break;
	}
     */
    NSLog(@"pps: %@, b64pps: %@", pps, b64pps);
    NSLog(@"sps: %@, b64sps: %@", sps, b64sps);
    NSLog(video_sdp, RTSP_HOST, b64sps, b64pps);
    
    char ip[200];
    hostname_to_ip(RTSP_HOST, ip);
    sdp = [NSString stringWithFormat:video_sdp, ip, b64sps, b64pps];
	return sdp;
}

- (int) setupRTPUDPConnection {
	NSString *transport;
	//NSLog(@"Transport Line: %@", transport);
	NSArray *kvs;
	NSArray *ports;
	
	rtspClient = [[RTSPClient alloc] init] ;
	
	//TODO: Check result codes and return error
	
	rtspClient.sdp = [self generateSDP];
	
	//NSLog(@"SDP File: %@\n\n", rtspClient.sdp);
	
	NSLog(@"Connecting to IP %s", RTSP_HOST);
	
	int responseCode = [rtspClient connectTo:[NSString stringWithCString:RTSP_HOST encoding:NSUTF8StringEncoding] onPort:RTSP_PORT withPath:[NSString stringWithCString:RTSP_PATH encoding:NSUTF8StringEncoding]];
	
	if(responseCode != 0) {return responseCode;}
	
	rtspClient.user = @"broadcast";
	rtspClient.pass = @"saywhat";
	
	responseCode = [rtspClient options];
	NSLog(@"--- OPTIONS Response: %d ---\n\n %@ \n", responseCode, rtspClient.responseHeader);
	
	if(responseCode != RTSP_OK) {return responseCode;}
	
	responseCode = [rtspClient announce];
	NSLog(@"--- ANNOUNCE Response: %d - session: %@ ---\n\n %@ \n", responseCode, rtspClient.session, rtspClient.responseHeader);
	
	if(responseCode != RTSP_OK) {return responseCode;}
	
	rtspClient.transport = RTSP_TRANSPORT_UDP;
	rtspClient.streamType = RTSP_PUBLISH;
    
    /*
	if (profile.broadcastType != kBroadcastTypeVideo) {
		//Setup AAC
		responseCode = [rtspClient setup:(aac_session_id - 96) withRtpPort:5000 andRtcpPort:5001];
		NSLog(@"--- SETUP Response: %d ---\n\n %@ \n", responseCode, rtspClient.responseHeader);
		
		if(responseCode != RTSP_OK) {return responseCode;}
		
		transport = [rtspClient.responseHeader objectForKey:@"Transport"];
		//NSLog(@"Transport Line: %@", transport);
		kvs = [transport componentsSeparatedByString:@";"];
		for (NSString *kv in kvs) {
			if ([kv hasPrefix:@"server_port"]) {
				NSRange eq = [kv rangeOfString:@"="];
				NSString *p = [kv substringFromIndex:eq.location + 1];
				//NSLog(@"Ports: %@", p);
				ports = [p componentsSeparatedByString:@"-"];
				//NSLog(@"RTP Port: %@ - RTCP Port: %@",[ports objectAtIndex:0], [ports objectAtIndex:1] );
			}
		}
		
		aac_session = rtp_init_udp([self.profile.address cStringUsingEncoding:NSASCIIStringEncoding], 5000, [[ports objectAtIndex:0] intValue], 60, 2000, rtp_aac_session_callback, self);
		
		if(aac_session == NULL) {
			NSLog(@"Session is NULL");
			return -1;
		}
	}
	*/
	//if (profile.broadcastType != kBroadcastTypeAudio) {
		//Setup AVC
		responseCode = [rtspClient setup:(avc_session_id - 96) withRtpPort:5002 andRtcpPort:5003];
		NSLog(@"--- SETUP Response: %d ---\n\n %@ \n", responseCode, rtspClient.responseHeader);
		
		if(responseCode != RTSP_OK) {
			//rtp_done(aac_session);
			return responseCode;
		}
		
		//TODO setup rtp
		
		transport = [rtspClient.responseHeader objectForKey:@"Transport"];
		//NSLog(@"Transport Line: %@", transport);
		kvs = [transport componentsSeparatedByString:@";"];
		//NSArray *ports;
		for (NSString *kv in kvs) {
			if ([kv hasPrefix:@"server_port"]) {
				NSRange eq = [kv rangeOfString:@"="];
				NSString *p = [kv substringFromIndex:eq.location + 1];
				//NSLog(@"Ports: %@", p);
				ports = [p componentsSeparatedByString:@"-"];
				//NSLog(@"RTP Port: %@ - RTCP Port: %@",[ports objectAtIndex:0], [ports objectAtIndex:1] );
			}
		}
		
		avc_session = rtp_init_udp(RTSP_HOST, 5002, [[ports objectAtIndex:0] intValue], 60, 2000, rtp_avc_session_callback, self);
		
		if(avc_session == NULL) {
			NSLog(@"Session is NULL");
		}
	//}
	
	responseCode = [rtspClient record];
	NSLog(@"--- RECORD Response: %d ---\n\n %@ \n", responseCode, rtspClient.responseHeader);
	
	if(responseCode != RTSP_OK) {
		//rtp_done(aac_session);
		rtp_done(avc_session);
		return responseCode;
	}
	
	//broadcasting = YES;
	return responseCode;
}


#pragma mark -
#pragma mark Capture Video

- (void)setUpAvcEncoder {
    
    AVCEncoderCallback cb = ^(const void* buffer, uint32_t length, CMTime pts) {
		
		//We should not have to send these.
		/*
         if(avc_start) {
         avc_start = NO;
         send_nal(avc_session, pts.value, 97, (uint8_t*) [self.sps bytes], [self.sps length]);
         send_nal(avc_session, pts.value, 97, (uint8_t*) [self.pps bytes], [self.pps length]);
         }
		 */
		NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
        
        //fprintf(stderr, "data length: %d\n", [data length]);
        
        //UIImage *image = [UIImage imageWithData:data];
        //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        
        //*
		AVPacket *packet = [[AVPacket alloc] init];
		packet->data = data;
		packet->size = length;
		packet->time = pts.value;
		packet->type = AV_TYPE_VIDEO;
		packet->sample_time = pts.value;
		
        @synchronized(avQueue) {
            [avQueue addObject:packet];
        }
		
		[packet release];
		//*/
        //		dispatch_async(sender_queue, ^{
        //			//TODO: handle return of -1 to indicate a socket error.
        //			if( send_nal(avc_session, pts.value, avc_session_id, (uint8_t*) [packet bytes], length, &timeout) == -1) {
        //				dispatch_async(dispatch_get_main_queue(), ^{
        //					[self disconnectInternal:kStreamError];
        //				});
        //			}
        //		});
        //		
        //		[packet release];
        //fprintf(stderr, "counter: %d\n\n", counter);
        /*
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         
         NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"AVCFrame.bmp"];
         [data writeToFile:appFile atomically:YES];
        //[data writeToFile:@"/tmp/AVCFrame.bmp" atomically:YES];
        //*/
            
        //fprintf(stderr, "wrote a frame to 'Documents/AVCFrame'\n");
            
        //NSLog(@"%@", data);
            
        dispatch_async(socket_queue, ^(void) {
            if (avQueue.count < 1) {// || sockfd < 1) {
                    return;
            }
                
            AVPacket *sendPacket = nil;
                
            @synchronized(avQueue) {
                sendPacket = [avQueue objectAtIndex:0];
                [avQueue removeObjectAtIndex:0];
            }
                
            //send(sockfd, sendPacket->data.bytes, sendPacket->data.length, 0);
            int ret = send_nal(avc_session, packet->time, avc_session_id, (uint8_t*) [packet->data bytes], packet->size, &timeout);
                
            //fprintf(stderr, "ret: %d\n", ret);
        });
        
    };
    self.avcEncoder.callback = Block_copy(cb);
    
    //TODO: check retain count
    //NSLog(@"retain count: %d", self.avcEncoder.callback.retainCount);
    
    AVCParameters *params = [[AVCParameters alloc] init];
    //NSLog(@" %dx%d", profile.broadcastWidth, profile.broadcastHeight);
    /*
     params.outWidth = profile.broadcastWidth;
     params.outHeight = profile.broadcastHeight;
     params.videoProfileLevel = AVVideoProfileLevelH264Baseline30;
     params.bps = (broadcastBitrates[profile.broadcastOption] * profile.bitrateScalar);// / kIPadScale;
     params.keyFrameInterval = profile.keyFrameInterval;
     */
    self.avcEncoder.parameters = params;
    
    if(![self.avcEncoder prepareEncoder]) {
        NSLog(@"Encoder Error: %@", avcEncoder.error);
    }
    
    spspps = self.avcEncoder.spspps;
    pps = self.avcEncoder.pps;
    sps = self.avcEncoder.sps;
    
    //[self.avcEncoder start];
}

- (void)setUpAvcEncoderForNetCat {
    __block BOOL once = YES;
    __block int counter = 0;
    AVCEncoderCallback cb = ^(const void* buffer, uint32_t length, CMTime pts) {
		
		//We should not have to send these.
		/*
         if(avc_start) {
         avc_start = NO;
         send_nal(avc_session, pts.value, 97, (uint8_t*) [self.sps bytes], [self.sps length]);
         send_nal(avc_session, pts.value, 97, (uint8_t*) [self.pps bytes], [self.pps length]);
         }
		 */
		NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
        
        //fprintf(stderr, "data length: %d\n", [data length]);
        
        //UIImage *image = [UIImage imageWithData:data];
        //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        
        //*
		AVPacket *packet = [[AVPacket alloc] init];
		packet->data = data;
		packet->size = length;
		packet->time = pts.value;
		packet->type = AV_TYPE_VIDEO;
		packet->sample_time = pts.value;
		
        //*
        if (counter >= 0 && counter < 1200) {
            @synchronized(avQueue) {
                [avQueue addObject:packet];
            }
        }
        //*/
		
		[packet release];
		//*/
        //		dispatch_async(sender_queue, ^{
        //			//TODO: handle return of -1 to indicate a socket error.
        //			if( send_nal(avc_session, pts.value, avc_session_id, (uint8_t*) [packet bytes], length, &timeout) == -1) {
        //				dispatch_async(dispatch_get_main_queue(), ^{
        //					[self disconnectInternal:kStreamError];
        //				});
        //			}
        //		});
        //		
        //		[packet release];
        //fprintf(stderr, "counter: %d\n\n", counter);
        if (counter >= 0 && counter < 1200) {
            /*
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsDirectory = [paths objectAtIndex:0];
             
             NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"AVCFrame.bmp"];
             [data writeToFile:appFile atomically:YES];
             //[data writeToFile:@"/tmp/AVCFrame.bmp" atomically:YES];
             //*/
            once = !once;
            //fprintf(stderr, "wrote a frame to 'Documents/AVCFrame'\n");
            
            //NSLog(@"%@", data);
            
            dispatch_async(socket_queue, ^(void) {
                if (avQueue.count < 1) {// || sockfd < 1) {
                    return;
                }
                
                AVPacket *sendPacket = nil;
                
                @synchronized(avQueue) {
                    sendPacket = [avQueue objectAtIndex:0];
                    [avQueue removeObjectAtIndex:0];
                }
                
                //send(sockfd, sendPacket->data.bytes, sendPacket->data.length, 0);
                int ret = send_nal(avc_session, packet->time, avc_session_id, (uint8_t*) [packet->data bytes], packet->size, &timeout);
                
                fprintf(stderr, "ret: %d count: %d\n", ret, counter);
            });
        }
		counter++;
    };
    self.avcEncoder.callback = Block_copy(cb);
    
    //TODO: check retain count
    //NSLog(@"retain count: %d", self.avcEncoder.callback.retainCount);
    
    AVCParameters *params = [[AVCParameters alloc] init];
    //NSLog(@" %dx%d", profile.broadcastWidth, profile.broadcastHeight);
    /*
    params.outWidth = profile.broadcastWidth;
    params.outHeight = profile.broadcastHeight;
    params.videoProfileLevel = AVVideoProfileLevelH264Baseline30;
    params.bps = (broadcastBitrates[profile.broadcastOption] * profile.bitrateScalar);// / kIPadScale;
    params.keyFrameInterval = profile.keyFrameInterval;
     */
    self.avcEncoder.parameters = params;
    
    if(![self.avcEncoder prepareEncoder]) {
        NSLog(@"Encoder Error: %@", avcEncoder.error);
    }
    
    spspps = self.avcEncoder.spspps;
    pps = self.avcEncoder.pps;
    sps = self.avcEncoder.sps;
    
    [self.avcEncoder start];
}

- (void)initCapture {
    glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
    
    avQueue = [[NSMutableArray alloc] initWithCapacity:100];
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    if ([self setUpNetwork] != 0) {
        NSLog(@"could not set up network");
        return;
    }
    self.avcEncoder = [[[AVCEncoder alloc] init] autorelease];
    [self setUpAvcEncoder];
    
    int responseCode = [self setupRTPUDPConnection];
    
    if(responseCode != RTSP_OK) {
		//rtp_done(aac_session);
		//rtp_done(avc_session);
        NSLog(@"You FAIL!");
		return;
	}
    
    /*
    NSLog(@"start: %@; length: %d", captureOutput.availableVideoCodecTypes, captureOutput.availableVideoCodecTypes.count);
    for (NSString *type in captureOutput.availableVideoCodecTypes) {
        NSLog(@"%@", type);
    }
    NSLog(@"pixel format: %@; length: %d", captureOutput.availableVideoCVPixelFormatTypes, captureOutput.availableVideoCVPixelFormatTypes.count);
    for (NSNumber *type in captureOutput.availableVideoCVPixelFormatTypes) {
        NSLog(@"%@", type);
    }
    //*/
    
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t video_capture_queue;
    video_capture_queue = dispatch_queue_create("video_capture_queue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:video_capture_queue];
    dispatch_release(video_capture_queue);
    
    NSString *pixelBufferKey = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *pixelBufferType = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];

    captureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, pixelBufferType, pixelBufferKey, nil];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    
    self.customLayer = [CALayer layer];
    self.customLayer.frame = self.view.bounds;
    //self.customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1.0);
    self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:self.customLayer];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0.0, 0.0, 150.0, 150.0);
    [self.view addSubview:self.imageView];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.prevLayer.frame = CGRectMake(150.0, 0.0, 150.0, 150.0);
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.prevLayer];
    
    [self.avcEncoder start];
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //dispatch_sync(image_processing_queue, ^{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //fprintf(stderr, "bytesPerRow: %lu; width: %lu; height: %lu\n", bytesPerRow, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextRotateCTM(newContext, M_PI_2);
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    /*
    if (!pxbuffer) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];
        
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)options, &pxbuffer);
        
        NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(pxbuffer), width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextTranslateCTM(context, width*.5, height);
    CGContextRotateCTM(context, -M_PI_2);
    CFAbsoluteTime a_start = CFAbsoluteTimeGetCurrent();
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), newImage);
    CFAbsoluteTime an_end = CFAbsoluteTimeGetCurrent();
    CGImageRelease(newImage);
    
    
    newImage = CGBitmapContextCreateImage(context);
    
    
    fprintf(stderr, "\nNew bitmap time = %lf\n", (an_end - a_start)*1000.0);
    //*/
    
    CGContextRelease(newContext);
    //CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    CFAbsoluteTime starttime = CFAbsoluteTimeGetCurrent();
    
    fprintf(stderr, "\nSetup time = %lf\n", (starttime - begin)*1000.0);
    
    
    // TODO: create reusable OpenCV objects as instance variables to reduce
    // overhead of object creation
    /*
    using namespace cv;
    
    IplImage *iplImage = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 4);//[self IplImageFromCGImage:newImage];
    iplImage->imageData = (char *)baseAddress;
    
    CFAbsoluteTime afteripl = CFAbsoluteTimeGetCurrent();
    fprintf(stderr, "\nIplImage conversion time = %lf\n", (afteripl - starttime)*1000.0);
    
    IplImage *rotated_image = cvCreateImage(cvSize(iplImage->height, iplImage->width), iplImage->depth, iplImage->nChannels);
    
    CFAbsoluteTime afterrot = CFAbsoluteTimeGetCurrent();
    fprintf(stderr, "IplImage creation time = %lf\n", (afterrot - afteripl)*1000.0);
    
    // rotate image
    char *src = iplImage->imageData;
    char *dest = rotated_image->imageData;
    for (int x = 0; x <= iplImage->width; x++) {
        for (int y = iplImage->height - 1; y > -1; y--) {
            *dest = *(src + ((y * width) + x) * iplImage->nChannels);
            dest++;
        }
    }
    
    //cvTranspose(iplImage, rotated_image);
    //cvFlip(rotated_image, rotated_image, 1);
    
    CFAbsoluteTime rotatetime = CFAbsoluteTimeGetCurrent();
    fprintf(stderr, "Rotation time = %lf\n", (rotatetime - afterrot)*1000.0);
    
    cvReleaseImage(&iplImage);
    
    CGImageRelease(newImage);
    newImage = [self CGImageFromIplImage:rotated_image];
    
    cvReleaseImage(&rotated_image);
    
    CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
    
    fprintf(stderr, "Convert back time = %lf\n", (endtime - rotatetime)*1000.0);
    //*/
    
    //[self rotateBuffer:imageBuffer];
    
    CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
    
    fprintf(stderr, "Total time = %lf\n", (endtime - starttime)*1000.0);
    
    [self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject:(id)newImage waitUntilDone:NO];
    
    //UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(newImage);
    
    //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    [self.avcEncoder encode:sampleBuffer];
    //});
    
    [pool drain];
}

#pragma mark -
#pragma mark Rotation Functions

/*
- (CVPixelBufferRef)GLrotate:(CVImageBufferRef)imageBuffer {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSParameterAssert(context != nil);
    
    uint8_t *src_buff = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    if (!pxbuffer) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];
        
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)options, &pxbuffer);
        
        NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    }
    
    // Create a new texture from the camera frame data, display that using the shaders
    GLuint videoFrameTexture;
    
	glGenTextures(1, &videoFrameTexture);
	glBindTexture(GL_TEXTURE_2D, videoFrameTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// This is necessary for non-power-of-two textures
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// Using BGRA extension to pull in video frame data directly
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(imageBuffer));
    
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindBuffer(GL_FRAMEBUFFER, framebuffer);
    
}
//*/

- (CVPixelBufferRef)rotateBuffer:(CVImageBufferRef)imageBuffer {
    CFAbsoluteTime starttime = CFAbsoluteTimeGetCurrent();
    
    uint8_t *src_buff = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    if (!pxbuffer) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES],
                                 kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];

        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)options, &pxbuffer);
    
        NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *dest_buff = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(dest_buff != NULL);
    
    int *src = (int *)src_buff;
    int *dest = (int *)dest_buff;
    
    size_t count = (bytesPerRow * height) / 4;
    //*
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    while (count--) {
        *dest = *src;
        src++;
        dest++;
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    fprintf(stderr, "\nSwap time = %lf\n", (end - start) * 1000.0);
    //*/
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
    
    fprintf(stderr, "\nRotation time = %lf\n", (endtime - starttime) * 1000.0);
    
    return pxbuffer;
}

#pragma mark -
#pragma mark OpenCV craziness
//*
- (IplImage *)IplImageFromCGImage:(CGImageRef)imageRef {
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temp IplImage
    IplImage *iplImage = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 4);
    // Create CGContext from temp IplImage
    CGContextRef contextRef = CGBitmapContextCreate(iplImage->imageData, iplImage->width, iplImage->height, iplImage->depth, iplImage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    // Drawing CGImage to CGContext
    CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Create resulting IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplImage);
    
    return ret;
}

- (CGImageRef)CGImageFromIplImage:(IplImage *)iplImage {
    //cvCvtColor(iplImage, iplImage, CV_RGBA2BGR);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Buffer for CGImage
    NSData *data = [NSData dataWithBytes:iplImage->imageData length:iplImage->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // Create CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(iplImage->width, iplImage->height, iplImage->depth, iplImage->depth * iplImage->nChannels, iplImage->widthStep, colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}
//*/
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.imageView = nil;
    self.prevLayer = nil;
    self.customLayer = nil;
    
    [self initCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.customLayer = nil;
    self.prevLayer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    self.imageView = nil;
    self.customLayer = nil;
    self.prevLayer = nil;
    
    self.captureSession = nil;
    self.avcEncoder = nil;
    
    if (avQueue) {
        [avQueue release];
        avQueue = nil;
    }
    
    if (sockfd > 0) {
        close(sockfd);
    }
    
    if (socket_queue) {
        dispatch_release(socket_queue);
    }
    if (image_processing_queue) {
        dispatch_release(image_processing_queue);
    }
    
    [super dealloc];
}

@end
