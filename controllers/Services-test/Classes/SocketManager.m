//
//  SocketManager.m
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocketManager.h"


#define HOST "10.0.190.153"

@implementation SocketManager

@synthesize input_stream;
@synthesize output_stream;


-(id)initSocketStream:(NSString *)host port:(NSInteger)port{
    [super init];
    
    // Cannot write to the socket yet
    can_write = NO;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    [NSStream getStreamsToHostNamed:host
                               port:port
                        inputStream:&inputStream
                       outputStream:&outputStream];
    
    input_stream = inputStream;
    output_stream = outputStream;
    
    [input_stream retain];
    [output_stream retain];
    
    [input_stream setDelegate:self];
    [output_stream setDelegate:self];
    
    [input_stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [output_stream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                             forMode:NSDefaultRunLoopMode];
    
    [input_stream open];
    [output_stream open];
    
    return self;
}

-(id)initSocketStreamWithCF:(id)var
readStreamCallback:(CFReadStreamClientCallBack)readCallback{
    [super init];
    
    // Cannot write to the socket yet
    can_write = NO;
    
    char message[] = "Hello Server\n";
    
	// Grab the current RunLoop
	CFRunLoopRef current_runloop = CFRunLoopGetCurrent();
	
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, CFSTR(HOST), 3490,
                                       &read_stream, &write_stream);
	
	if (!read_stream)
	{
		fprintf(stderr, "read_stream creation error\n");
		exit(EXIT_FAILURE);
	}
	if (!write_stream)
	{
		fprintf(stderr, "write_stream creation error\n");
		exit(EXIT_FAILURE);
	}
	
	CFReadStreamSetProperty(read_stream, kCFStreamPropertyShouldCloseNativeSocket, 
							kCFBooleanTrue);
	CFWriteStreamSetProperty(write_stream, kCFStreamPropertyShouldCloseNativeSocket, 
							 kCFBooleanTrue);
	
	CFStreamClientContext client_ctx = {0, message, NULL, NULL, NULL};
	
	
    if (!CFReadStreamSetClient(read_stream, kCFStreamEventHasBytesAvailable,
                               readCallback, &client_ctx))
	{
		perror("Error creating read_stream client");
		exit(EXIT_FAILURE);
	}
	
	CFReadStreamScheduleWithRunLoop(read_stream, current_runloop,
                                    kCFRunLoopCommonModes);
	
	CFReadStreamOpen(read_stream);
    
    return self;
}

-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            if (stream != input_stream) return;
            
            fprintf(stderr, "Has bytes available\n");
            
            char buffer[100];
            NSInteger numbytes = [(NSInputStream *)stream read:(uint8_t *)buffer 
                                     maxLength:(NSUInteger) 99];

            buffer[numbytes] = '\0';
            fprintf(stderr, "received: '%s' length: %d\n", buffer, numbytes);

            break;
        case NSStreamEventEndEncountered:
            fprintf(stderr, "Stream end encountered\n");
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil;
            break;
        case NSStreamEventHasSpaceAvailable:
            fprintf(stderr, "Stream has space available\n");
            can_write = YES;
            break;
        default:
            fprintf(stderr, "Some other event code\n");
            break;
    }
}

-(BOOL)sendData:(void *)data numberOfBytes:(int)bytes{
    
    
    return YES;
}

-(void) dealloc{
    CFReadStreamClose(read_stream);
    CFWriteStreamClose(write_stream);
    CFRelease(read_stream);
    CFRelease(write_stream);
    
    [input_stream close];
    [input_stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [input_stream release];
    
    [output_stream close];
    [output_stream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                             forMode:NSDefaultRunLoopMode];
    [output_stream release];
    
    [super dealloc];
}


@end
