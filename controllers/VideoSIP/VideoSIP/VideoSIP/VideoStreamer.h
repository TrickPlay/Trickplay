//
//  VideoStreamer.h
//  VideoSIP
//
//  Created by Rex Fenley on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

#import "NetworkManager.h"

@interface VideoStreamerContext : NSObject {
@private
    NSString *SIPPassword;
    NSString *SIPUserName;
    NSString *SIPRemoteUserName;
    NSString *SIPServerHostName;
    NSUInteger SIPServerPort;       // defaults to 5060
    NSUInteger SIPClientPort;       // defaults to 5060
}

@property (nonatomic, readonly) NSString *SIPPassword;
@property (nonatomic, readonly)NSString *SIPUserName;
@property (nonatomic, readonly)NSString *SIPRemoteUserName;
@property (nonatomic, readonly)NSString *SIPServerHostName;
@property (nonatomic, readonly)NSUInteger SIPServerPort;
@property (nonatomic, readonly)NSUInteger SIPClientPort;

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;

@end




@interface VideoStreamer : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, NetworkManagerDelegate> {
    NetworkManager *networkMan;
    
    AVCaptureSession *captureSession;
    CALayer *customLayer;
    
    CVPixelBufferRef pxbuffer;
    
    VideoStreamerContext *streamerContext;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) CALayer *customLayer;

- (id)initWithContext:(VideoStreamerContext *)streamerContext;
- (void)initCapture;

@end

