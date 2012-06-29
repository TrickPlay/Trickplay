//
//  SDPParser.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Taken from RFC 4566
 
 ...
 
 An SDP session description consists of a session-level section
 followed by zero or more media-level sections.  The session-level
 part starts with a "v=" line and continues to the first media-level
 section.  Each media-level section starts with an "m=" line and
 continues to the next media-level section or end of the whole session
 description.  In general, session-level values are the default for
 all media unless overridden by an equivalent media-level value.
 
 Some lines in each description are REQUIRED and some are OPTIONAL,
 but all MUST appear in exactly the order given here (the fixed order
 greatly enhances error detection and allows for a simple parser).
 OPTIONAL items are marked with a "*".
 
 Session description
 v=  (protocol version)
 o=  (originator and session identifier)
 s=  (session name)
 i=* (session information)
 u=* (URI of description)
 e=* (email address)
 p=* (phone number)
 c=* (connection information -- not required if included in
 all media)
 b=* (zero or more bandwidth information lines)
 One or more time descriptions ("t=" and "r=" lines; see below)
 z=* (time zone adjustments)
 k=* (encryption key)
 a=* (zero or more session attribute lines)
 Zero or more media descriptions
 
 Time description
 t=  (time the session is active)
 r=* (zero or more repeat times)
 
 Media description, if present
 m=  (media name and transport address)
 i=* (media title)
 c=* (connection information -- optional if included at
 session level)
 b=* (zero or more bandwidth information lines)
 k=* (encryption key)
 a=* (zero or more media attribute lines)
 
 The set of type letters is deliberately small and not intended to be
 extensible -- an SDP parser MUST completely ignore any session
 description that contains a type letter that it does not understand.
 The attribute mechanism ("a=" described below) is the primary means
 for extending SDP and tailoring it to particular applications or
 media.  Some attributes (the ones listed in Section 6 of this memo)
 have a defined meaning, but others may be added on an application-,
 media-, or session-specific basis.  An SDP parser MUST ignore any
 attribute it doesn't understand.
 
 ...
**/



#import <Foundation/Foundation.h>

@class MediaDescription;

/**
 * This class parses SDP messages and discovers the IP address and ports
 * to use to establish an RTP audio or video stream.
 */

@interface SDPParser : NSObject {
    NSArray *owner;
    NSString *sessionName;
    NSArray *connectionInfo;
    NSString *bandwidth;
    NSString *timeDescription;
    NSMutableDictionary *mediaDescriptions;
}

@property (nonatomic, retain) NSArray *owner;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSArray *connectionInfo;
@property (nonatomic, retain) NSString *bandwidth;
@property (nonatomic, retain) NSString *timeDescription;
@property (nonatomic, retain) NSMutableDictionary *mediaDescriptions;

- (id)initWithSDP:(NSString *)body;

- (MediaDescription *)audioDescription;
- (MediaDescription *)videoDescription;

- (NSArray *)audioHostandPort;
- (NSArray *)videoHostandPort;

@end
