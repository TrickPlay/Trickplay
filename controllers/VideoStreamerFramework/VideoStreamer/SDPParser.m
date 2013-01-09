//
//  SDPParser.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDPParser.h"

#import "MediaDescription.h"

/**
 * Before you lie State Machine Lookup Tables for the SDP
 * parser! These help determine how to parse the SDP packet.
 * They were painful to write but make teh codes less complexish.
 */

static int const sdp_state_lookup[][15] = {
    // v  o  s  i* u* e* p* c* b* t  r* z* k* a* m*
    {  1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  }, // v
    {  0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  }, // o
    {  0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0  }, // s
    {  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0  }, // i*
    {  0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0  }, // u*
    {  0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0  }, // e*
    {  0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0  }, // p*
    {  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0  }, // c*
    {  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0  }, // b*
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1  }, // t
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1  }, // r*
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1  }, // z*
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1  }, // k*
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1  }, // a*
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1  }, // m*
};

static int const media_state_lookup[][6] = {
    // m  i* c* b* k* a*
    {  1, 1, 1, 1, 1, 1  }, // m
    {  1, 0, 1, 1, 1, 1  }, // i*
    {  1, 0, 0, 1, 1, 1  }, // c*
    {  1, 0, 0, 1, 1, 1  }, // b*
    {  1, 0, 0, 0, 0, 1  }, // k*
    {  1, 0, 0, 0, 0, 1  }  // a*
};


typedef enum {
    SESSION,
    MEDIA
} parser_mode;


@interface SDPParser()

// These parse session description parameters
- (BOOL)parseOwner:(NSString *)ownerLine;
- (BOOL)parseSessionName:(NSString *)sessionNameLine;
- (BOOL)parseConnectionInfo:(NSString *)connectionInfoLine;
- (BOOL)parseBandwidth:(NSString *)bandwidthLine;
- (BOOL)parseTimeDesc:(NSString *)descrption;

// These parse media description parameters
- (BOOL)parseMediaDesc:(NSString *)mediaLine currentMediaType:(NSMutableString *)type;
- (BOOL)parseMediaConnection:(NSString *)connectionInfoLine currentMediaType:(NSMutableString *)type;

@end



@implementation SDPParser

@synthesize owner;
@synthesize sessionName;
@synthesize connectionInfo;
@synthesize bandwidth;
@synthesize timeDescription;
@synthesize mediaDescriptions;

// TODO: We need a fast C based Regex SDP parser here.
- (id)initWithSDP:(NSString *)body {
    self = [super init];
    
    if (self) {
        NSArray *components = [body componentsSeparatedByString:@"\r\n"];
        // Guarenteed there must be 5 attributes in every SDP packet.
        if (components.count < 5) {
            [self release];
            return nil;
        }
        // Remove trailing empty string
        if ([(NSString *)[components objectAtIndex:components.count - 1] compare:@""] == NSOrderedSame) {
            components = [components subarrayWithRange:NSMakeRange(0, components.count - 1)];
        }
        
        self.mediaDescriptions = [NSMutableDictionary dictionaryWithCapacity:5];
        
        parser_mode current_mode = SESSION;
        
        NSDictionary *attributeToValLookup = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"v", [NSNumber numberWithInt:1], @"o", [NSNumber numberWithInt:2], @"s", [NSNumber numberWithInt:3], @"i", [NSNumber numberWithInt:4], @"u", [NSNumber numberWithInt:5], @"e", [NSNumber numberWithInt:6], @"p", [NSNumber numberWithInt:7], @"c", [NSNumber numberWithInt:8], @"b", [NSNumber numberWithInt:9], @"t", [NSNumber numberWithInt:10], @"r", [NSNumber numberWithInt:11], @"z", [NSNumber numberWithInt:12], @"k", [NSNumber numberWithInt:13], @"a", [NSNumber numberWithInt:14], @"m",  nil] autorelease];
        
        NSDictionary *mediaAttrToValLookup = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0], @"m", [NSNumber numberWithInt:1], @"i", [NSNumber numberWithInt:2], @"c", [NSNumber numberWithInt:3], @"b", [NSNumber numberWithInt:4], @"k", [NSNumber numberWithInt:5], @"a", nil] autorelease];
        
        NSDictionary *sessionParsers = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:@selector(parseOwner:)], @"o", [NSValue valueWithPointer:@selector(parseSessionName:)], @"s", [NSValue valueWithPointer:@selector(parseConnectionInfo:)], @"c", [NSValue valueWithPointer:@selector(parseBandwidth:)], @"b", [NSValue valueWithPointer:@selector(parseTimeDesc:)], @"t", nil];
        
        NSDictionary *mediaParsers = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:@selector(parseMediaDesc:currentMediaType:)], @"m", [NSValue valueWithPointer:@selector(parseMediaConnection:currentMediaType:)], @"c", nil];
        
        
        NSArray *elementComponents;
        NSString *key;
        NSString *val;
        NSNumber *attributeVal;
        
        int current_state = 0;
        int next_state = 0;
        
        NSMutableString *currentMediaType = [NSMutableString stringWithString:@""];
        
        BOOL parserFailure = NO;
        
        // Loop through each line of the SDP packet. Split the line
        // at an '=' token into the key, value pair. Check to make sure
        // this new key corresponds to the next attribute allowed by
        // the SDP protocol. Execute the corresponding parser for that
        // attribute line.
        for (NSString *element in components) {
            elementComponents = [element componentsSeparatedByString:@"="];
            //NSLog(@"elementComponents: %@", elementComponents);
            if (elementComponents.count < 2) {
                [self release];
                return nil;
            }
            
            key = [elementComponents objectAtIndex:0];
            val = [elementComponents objectAtIndex:1];
            
            if (current_mode == SESSION) {   // parsing session attributes
                // check to see if this next key matches the next allowed attribute
                attributeVal = [attributeToValLookup objectForKey:key];
                if (!attributeVal) {
                    parserFailure = YES;
                    break;
                }
                
                next_state = [attributeVal intValue];
                if (!sdp_state_lookup[current_state][next_state]) {
                    parserFailure = YES;
                    break;
                }
                
                if ([sessionParsers objectForKey:key]) {
                    SEL parserSelector = [[sessionParsers objectForKey:key] pointerValue];
                    if(![self performSelector:parserSelector withObject:val]) {
                        parserFailure = YES;
                        break;
                    }
                }
                
                // If 'm' media attribute (lookup table uses int 14)
                // then switch to media parsing mode
                if (next_state == 14) {
                    current_mode = MEDIA;
                    current_state = 0;
                    next_state = 0;
                }
            } 
            
            if (current_mode == MEDIA) {                         // parsing media attributes
                attributeVal = [mediaAttrToValLookup objectForKey:key];
                if (!attributeVal) {
                    parserFailure = YES;
                    break;
                }
                
                next_state = [attributeVal intValue];
                if (!media_state_lookup[current_state][next_state]) {
                    parserFailure = YES;
                    break;
                }
                
                if ([mediaParsers objectForKey:key]) {
                    SEL parserSelector = [[mediaParsers objectForKey:key] pointerValue];
                    if (![self performSelector:parserSelector withObject:val withObject:currentMediaType]) {
                        parserFailure = YES;
                        break;
                    }
                }
            }
            
            current_state = next_state;
        }
        
        if (parserFailure) {
            [self release];
            return nil;
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark Parsers

- (BOOL)parseOwner:(NSString *)ownerLine {
    self.owner = [ownerLine componentsSeparatedByString:@" "];
    if (owner.count != 6) {
        self.owner = nil;
        return NO;
    }
    
    return YES;
}

- (BOOL)parseSessionName:(NSString *)sessionNameLine {
    self.sessionName = sessionNameLine;
    
    return YES;
}

// this assumes Unicast
- (BOOL)parseConnectionInfo:(NSString *)connectionInfoLine {
    self.connectionInfo = [connectionInfoLine componentsSeparatedByString:@" "];
    if (connectionInfo.count != 3) {
        self.connectionInfo = nil;
        return NO;
    }
    
    return YES;
}

- (BOOL)parseBandwidth:(NSString *)bandwidthLine {
    self.bandwidth = bandwidthLine;
    
    return YES;
}

- (BOOL)parseTimeDesc:(NSString *)descrption {
    self.timeDescription = descrption;
    
    return YES;
}

// Media Parsers

- (BOOL)parseMediaDesc:(NSString *)mediaLine currentMediaType:(NSMutableString *)mediaType {
    NSArray *components = [mediaLine componentsSeparatedByString:@" "];
    if (components.count < 4) {
        self.mediaDescriptions = nil;
        return NO;
    }

    // TODO: might want to check media type as audio, video, text, application, or
    // message. However, without checking this media description will be ignored
    // anyway.
    [mediaType setString:[components objectAtIndex:0]];
    // there may be multiple RTP/RTCP port combos!
    NSArray *portComponents = [[components objectAtIndex:1] componentsSeparatedByString:@"/"];
    NSUInteger port = [[portComponents objectAtIndex:0] intValue];
    NSString *proto = [components objectAtIndex:2];
    NSArray *fmt = [components subarrayWithRange:NSMakeRange(3, components.count - 3)];
    
    MediaDescription *mediaDescription = [[[MediaDescription alloc] init] autorelease];
    mediaDescription.port = port;
    mediaDescription.protocol = proto;
    mediaDescription.formats = fmt;
    // for a new media description initialize with any global connection information
    if (connectionInfo) {
        mediaDescription.networkType = [connectionInfo objectAtIndex:0];
        mediaDescription.addressType = [connectionInfo objectAtIndex:1];
        mediaDescription.host = [connectionInfo objectAtIndex:2];
    }
    
    // If there are multiple RTP/RTCP port combos then add that bit of information
    if (portComponents.count > 1) {
        NSUInteger numberOfPorts = [[portComponents objectAtIndex:1] unsignedIntValue];
        mediaDescription.numberOfPorts = numberOfPorts;
    } else {
        mediaDescription.numberOfPorts = 1;
    }
    
    // Add this media description to the media descriptions dictionary
    mediaDescription.mediaType = mediaType;
    [mediaDescriptions setObject:mediaDescription forKey:mediaType];
    // Update the current media type being parsed
    
    
    return YES;
}

// this assumes Unicast
- (BOOL)parseMediaConnection:(NSString *)connectionInfoLine currentMediaType:(NSMutableString *)mediaType {
    NSArray *mediaConnectionInfo = [connectionInfoLine componentsSeparatedByString:@" "];
    MediaDescription *mediaDescription = [mediaDescriptions objectForKey:mediaType];
    if (mediaConnectionInfo.count != 3 || !mediaDescription) {
        return NO;
    }
    
    mediaDescription.networkType = [mediaConnectionInfo objectAtIndex:0];
    mediaDescription.addressType = [mediaConnectionInfo objectAtIndex:1];
    mediaDescription.host = [mediaConnectionInfo objectAtIndex:2];
    
    return YES;
}

- (MediaDescription *)audioDescription {
    MediaDescription *audioDescription = [mediaDescriptions objectForKey:@"audio"];
    if (!audioDescription || !audioDescription.host || !audioDescription.port) {
        return nil;
    }
    
    return audioDescription;
}

- (MediaDescription *)videoDescription {
    MediaDescription *videoDescription = [mediaDescriptions objectForKey:@"video"];
    if (!videoDescription || !videoDescription.host || !videoDescription.port) {
        return nil;
    }
    
    return videoDescription;
}


// TODO: might want to get rid of these. Caller might as well just get the whole
// media description rather than just the host and port
- (NSArray *)audioHostandPort {
    MediaDescription *audioDescription = [mediaDescriptions objectForKey:@"audio"];
    if (!audioDescription || !audioDescription.host || !audioDescription.port) {
        return nil;
    }
    
    NSArray *hostAndPort = [NSArray arrayWithObjects:audioDescription.host, [NSNumber numberWithUnsignedInt:audioDescription.port], nil];
    
    return hostAndPort;
}

- (NSArray *)videoHostandPort {
    MediaDescription *videoDescription = [mediaDescriptions objectForKey:@"video"];
    if (!videoDescription || !videoDescription.host || !videoDescription.port) {
        return nil;
    }
    
    NSArray *hostAndPort = [NSArray arrayWithObjects:videoDescription.host, [NSNumber numberWithUnsignedInt:videoDescription.port], nil];
    
    return hostAndPort;
}

#pragma mark -
#pragma mark Memory

- (void)dealloc {
    if (owner) {
        [owner release];
        owner = nil;
    }
    
    if (sessionName) {
        [sessionName release];
        sessionName = nil;
    }
    
    if (connectionInfo) {
        [connectionInfo release];
        connectionInfo = nil;
    }
    
    if (bandwidth) {
        [bandwidth release];
        bandwidth = nil;
    }
    
    if (timeDescription) {
        [timeDescription release];
        timeDescription = nil;
    }
    
    if (mediaDescriptions) {
        [mediaDescriptions release];
        mediaDescriptions = nil;
    }
    
    [super dealloc];
}

@end
