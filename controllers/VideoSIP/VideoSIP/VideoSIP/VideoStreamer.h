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

@class VideoStreamer;
@class NetworkManager;


@protocol VideoStreamerDelegate <NSObject>

- (void)videoStreamerInitiatingChat:(VideoStreamer *)videoStreamer;
- (void)videoStreamerChatStarted:(VideoStreamer *)videoStreamer;
// TODO: Change info to some Macro NSUInteger value corresponding to an error code.
// Then add a function in the library that you can pass the value too to get an
// explanation printed to console.
- (void)videoStreamer:(VideoStreamer *)videoStreamer chatEndedWithInfo:(NSString *)reason;

@end



@interface VideoStreamerContext : NSObject

@property (nonatomic, readonly) NSString *SIPPassword;
@property (nonatomic, readonly) NSString *SIPUserName;
@property (nonatomic, readonly) NSString *SIPRemoteUserName;
@property (nonatomic, readonly) NSString *SIPServerHostName;
@property (nonatomic, readonly) UInt16 SIPServerPort;
@property (nonatomic, readonly) UInt16 SIPClientPort;

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;

@end



@interface VideoStreamer : UIViewController 

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic, assign) id <VideoStreamerDelegate> delegate;

- (id)initWithContext:(VideoStreamerContext *)streamerContext delegate:(id <VideoStreamerDelegate>)delegate;

- (void)startChat;
- (void)endChat;

@end

