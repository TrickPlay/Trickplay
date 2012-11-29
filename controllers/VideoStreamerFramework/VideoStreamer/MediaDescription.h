//
//  MediaDescription.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A MediaDesription holds all information parsed from a media
 * attribute in an SDP packet. This information may be used to
 * form an RTP stream with a client over the cloud.
 *
 * Consult RFC 4566 for more information
 */

@interface MediaDescription : NSObject {
    // @"audio", @"video", @"application"
    NSString *mediaType;
    // Generally @"IN" for internet
    NSString *networkType;
    // @"IP4" or @"IP6"
    NSString *addressType;
    // Host name of client that wants to form an RTP stream
    NSString *host;
    // Port number of client that wants to form an RTP stream
    NSUInteger port;
    // RTP allows for multiple different port numbers to use
    // for the same stream to one-or-many clients.
    // We only provide one port number for now so this
    // instance variable is useless.
    NSUInteger numberOfPorts;
    // Protocol for this media attribute. Likely will be
    // @"RTP/AVP" considering we are using RTP
    NSString *protocol;
    // Media format types supported for this media type.
    // Usually an integer representing a specific codec.
    // I.E. PCMU, PCMA, iLBC, GSM, MP3, etc. for audio
    // H264, H261, MPV, etc. for video
    NSArray *formats;
}

@property (nonatomic, retain) NSString *mediaType;
@property (nonatomic, retain) NSString *networkType;
@property (nonatomic, retain) NSString *addressType;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) NSUInteger numberOfPorts;
@property (nonatomic, retain) NSString *protocol;
@property (nonatomic, retain) NSArray *formats;

@end
