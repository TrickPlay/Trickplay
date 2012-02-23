//
//  ViewController.h
//  Video Streaming
//
//  Created by Rex Fenley on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import "AVCEncoder.h"
#import "SocketManager.h"
#import "RTSPClient.h"

#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <errno.h>
#import <netdb.h>
#import <sys/types.h>
#import <netinet/in.h>
#import <sys/socket.h>

#import <arpa/inet.h>

#import "rtp.h"

static struct timeval timeout;

typedef void (^socket_queue_callback)(const void* buffer, uint32_t length);

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    int sockfd;
    dispatch_queue_t socket_queue;
    
    RTSPClient *rtspClient;
    
    uint8_t avc_session_id;
    struct rtp *avc_session;
    
    NSData *spspps, *pps, *sps;
    
    AVCEncoder *avcEncoder;
    SocketManager *socketManager;
    AVCaptureSession *captureSession;
    UIImageView *imageView;
    CALayer *customLayer;
    AVCaptureVideoPreviewLayer *prevLayer;
    
    NSMutableArray *avQueue;
}

void rtp_avc_session_callback(struct rtp *session, rtp_event *e);
void *get_in_addr(struct sockaddr *sa);

@property (retain) SocketManager *socketManager;
@property (retain) AVCEncoder *avcEncoder;
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

- (void)initCapture;

@end
