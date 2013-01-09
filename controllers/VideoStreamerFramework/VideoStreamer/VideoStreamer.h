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
    CALL_ENDED_BY_CALLEE,           // Call ended safely
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


/**
 * The VideoStreamerDelegate Protocol informs the delegate when the state
 * of a 'Chat' changes in the corresponding VideoStreamer.
 */

@protocol VideoStreamerDelegate <NSObject>

- (void)videoStreamerInitiatingChat:(VideoStreamer *)videoStreamer;
- (void)videoStreamerChatStarted:(VideoStreamer *)videoStreamer;
- (void)videoStreamer:(VideoStreamer *)videoStreamer chatEndedWithInfo:(NSString *)reason networkCode:(enum NETWORK_TERMINATION_CODE)code;

@end


/**
 * VideoStreamerContext represents all the address and connection information
 * needed for a VideoStreamer to connect to and chat with a client over the
 * Internet. Currently the protocol used is SIP so only SIP connection information
 * should be provided at initialization.
 */

@interface VideoStreamerContext : NSObject

// only SIP for now

// The full remote address in the form: <protocol>:<user name>@<host name>
// i.e. sip:phone@<destination>.com
@property (nonatomic, readonly) NSString *fullAddress;
// The local user's SIP password
@property (nonatomic, readonly) NSString *SIPPassword;
// The local user's SIP username
@property (nonatomic, readonly) NSString *SIPUserName;
// The remote user's user name; if the context is initialized
// using -initWithUserName:password:remoteAddress:serverPort:clientPort:
// this property is parsed from remoteAddress parameter
@property (nonatomic, readonly) NSString *SIPRemoteUserName;
// The SIP server's host name; if the context is initialized
// using -initWithUserName:password:remoteAddress:serverPort:clientPort:
// this property is parsed from remoteAddress parameter
@property (nonatomic, readonly) NSString *SIPServerHostName;
// The port number that the SIP server is listening on
// Defaults to 5060
@property (nonatomic, readonly) UInt16 SIPServerPort;
// The port number the iOS Device will use to connect to
// the SIP server; defaults to 50160 (to prevent 5060 collisions)
@property (nonatomic, readonly) UInt16 SIPClientPort;

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;
// Address must be in the form: <protocol>:<user name>@<host name> i.e. sip:phone@<destination>.com
- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteAddress:(NSString *)remoteAddress serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort;

@end


/**
 * The VideoStreamer Class allows a caller to begin and end an RTP based video chat with
 * a SIP client connected to a TrickPlay SIP server. Simply create a VideoStreamerContext
 * with all necessary connection information, initialize a newly created VideoStreamer
 * with the VideoStreamerContext, and call startChat on the VideoStreamer object.
 *
 * Provide the VideoStreamer with a delegate object in order to receive callbacks
 * when a chat initiates, begins, and ends.
 */

@interface VideoStreamer : UIViewController 

// The VideoStreamerContext originally passed in during intialization
@property (nonatomic, readonly) VideoStreamerContext *streamerContext;
// The current status of the connection
@property (nonatomic, readonly) enum CONNECTION_STATUS status;
// This VideoStreamer's delegate
@property (nonatomic, assign) id <VideoStreamerDelegate> delegate;

- (id)initWithContext:(VideoStreamerContext *)streamerContext delegate:(id <VideoStreamerDelegate>)delegate;

// After initializing a VideoStreamer, call this to begin chat using the provided
// VideoStreamerContext
- (void)startChat;
// This ends a chat at any time
- (void)endChat;

//// TODO: These functions below don't pass back anything useful yet.

// Provides a better description of the reason for network termination
- (NSString *)networkTerminationDescription:(enum NETWORK_TERMINATION_CODE)code;
// Provides a better description of the current state of VideoStreamer
- (NSString *)connectionStatusDescription:(enum CONNECTION_STATUS)status;

////

@end

