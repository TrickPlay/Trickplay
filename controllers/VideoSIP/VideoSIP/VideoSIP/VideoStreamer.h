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

/**
 * This enumeration represents the three different reasons
 * the network may terminate a video streaming chat.
 */
enum NETWORK_TERMINATION_CODE {
    CALL_ENDED_BY_CALLEE,                     // Call ended safely
    CALL_ENDED_BY_CALLER,
    CALL_FAILED,                    // Call could not connect
    CALL_DROPPED                    // Call dropped midway through a call
};

/**
 * These are the three states that the VideoStreamer's network component
 * may be in.
 */
enum CONNECTION_STATUS {
    INITIATING,                     // Trying to contact the network
    CONNECTED,                      // Connected to the network
    DISCONNECTED                    // Disconnected from the network
};


@protocol VideoStreamerDelegate <NSObject>

- (void)videoStreamerInitiatingChat:(VideoStreamer *)videoStreamer;
- (void)videoStreamerChatStarted:(VideoStreamer *)videoStreamer;
- (void)videoStreamer:(VideoStreamer *)videoStreamer chatEndedWithInfo:(NSString *)reason networkCode:(enum NETWORK_TERMINATION_CODE)code;

@end



@interface VideoStreamerContext : NSObject

// only SIP for now
@property (nonatomic, readonly) NSString *fullAddress;
@property (nonatomic, readonly) NSString *SIPPassword;
@property (nonatomic, readonly) NSString *SIPUserName;
@property (nonatomic, readonly) NSString *SIPRemoteUserName;
@property (nonatomic, readonly) NSString *SIPServerHostName;
@property (nonatomic, readonly) UInt16 SIPServerPort;
@property (nonatomic, readonly) UInt16 SIPClientPort;

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;
// Address must be in the form: <protocol>:<user name>@<host name> i.e. sip:phone@<destination>.com
- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteAddress:(NSString *)remoteAddress serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;

@end




@interface VideoStreamer : UIViewController 

@property (nonatomic, readonly) CALayer *customLayer;
@property (nonatomic, readonly) VideoStreamerContext *streamerContext;
@property (nonatomic, readonly) enum CONNECTION_STATUS status;
@property (nonatomic, assign) id <VideoStreamerDelegate> delegate;

- (id)initWithContext:(VideoStreamerContext *)streamerContext delegate:(id <VideoStreamerDelegate>)delegate;

- (void)startChat;
- (void)endChat;

- (NSString *)networkTerminationDescription:(enum NETWORK_TERMINATION_CODE)code;
- (NSString *)connectionStatusDescription:(enum CONNECTION_STATUS)status;

@end

