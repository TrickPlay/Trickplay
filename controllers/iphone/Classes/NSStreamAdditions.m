//
//  NSStreamAdditions.m
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSStreamAdditions.h"


@implementation NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(NSUInteger)port 
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL, 
                                       (CFStringRef) hostName, 
                                       port, 
                                       ((inputStreamPtr  != nil) ? &readStream : NULL),
                                       ((outputStreamPtr != nil) ? &writeStream : NULL)
                                       );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = [NSMakeCollectable(readStream) autorelease];
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = [NSMakeCollectable(writeStream) autorelease];
    }
}

@end
