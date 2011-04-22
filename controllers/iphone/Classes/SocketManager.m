//
//  SocketManager.m
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocketManager.h"

@implementation WritePacket

@synthesize data;
@synthesize position;

- (void)dealloc {
    [data release];
    [super dealloc];
}

@end


@implementation SocketManager

@synthesize input_stream;
@synthesize output_stream;
@synthesize delegate;

@synthesize host;


-(id)initSocketStream:(NSString *)theHost
                 port:(NSInteger)thePort
             delegate:(id <SocketManagerDelegate>)theDelegate{
    if (self == [super init]) {
        
        NSInputStream *inputStream;
        NSOutputStream *outputStream;
    
        [NSStream getStreamsToHostNamed:theHost
                                   port:thePort
                            inputStream:&inputStream
                           outputStream:&outputStream];
    
        // Must be duplex, thus error occurred
        if (!inputStream || !outputStream) {
            if (inputStream) {
                [inputStream release];
            }
            if (outputStream) {
                [outputStream release];
            }
            
            [super dealloc];
            return nil;
        }
        
        // Dot syntax properly releases and retains objects
        self.host = theHost;
        port = thePort;
    
        self.input_stream = inputStream;
        self.output_stream = outputStream;
    
        [input_stream setDelegate:self];
        [output_stream setDelegate:self];

        
        writeQueue = [[NSMutableArray alloc] initWithCapacity:20];
        
        commandInterpreter = [[CommandInterpreter alloc] 
                              init:(id <CommandInterpreterDelegate>)theDelegate];
        
        delegate = theDelegate;
        
        
        [input_stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [output_stream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                                 forMode:NSDefaultRunLoopMode];
    
        [input_stream open];
        [output_stream open];
    }
        
    return self;
}


-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        /**
         * Unload all the data from the socket stream and send it to the command
         * interpreter.
         */
        case NSStreamEventHasBytesAvailable:
            if (stream != input_stream) return;
            
            NSLog(@"Has bytes available");
            
            NSInteger numbytes = 1;
            
            uint8_t buffer[5000];
            while ([(NSInputStream *)stream hasBytesAvailable]) {
                if ((numbytes = [(NSInputStream *)stream read:buffer maxLength:5000]) < 0) {
                    NSLog(@"Read Error occurred :%@", stream.streamError);
                    break;
                    //TODO: Error handling.
                }
                
                if (numbytes > 0) {
                    // Converting numbytes to unsigned, but numbytes never
                    // exceeds 5000, unless negative, in which case an error
                    // occurred and would never reach this point.
                    [commandInterpreter addBytes:(const uint8_t *)buffer
                                           length:(NSUInteger)numbytes];
                }
            }
            
            /*
            char buffer[100];
            numbytes = [(NSInputStream *)stream read:(uint8_t *)buffer
                                     maxLength:(NSUInteger) 99];

            buffer[numbytes] = '\0';
            fprintf(stderr, "received: '%s' length: %d\n", buffer, numbytes);
            */
            break;
        // Close up the streams cuz there aint nothin left.
        case NSStreamEventEndEncountered:
            NSLog(@"Stream end encountered");
            [delegate streamEndEncountered];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available");
            [self sendPackets];
            break;
        case NSStreamEventErrorOccurred:
            [[self delegate] socketErrorOccurred];
            break;
        default:
            NSLog(@"Some other event code");
            break;
    }
}


/**
 * Packs data into a WritePacket that will be queued for sending.
 * Packets get sent out in order of creation when space is available
 * on the sockets write buffer.
 */
- (void)sendData:(const void *)data numberOfBytes:(int)bytes {
    WritePacket *packet = [[WritePacket alloc] autorelease];
    packet.data = [NSData dataWithBytes:data length:bytes];
    packet.position = 0;
    [writeQueue addObject:packet];
    [self sendPackets];
}


- (BOOL)sendPackets {
    while ([writeQueue count] > 0) {
        if (![self sendPacket]) {
            break;
        }
    }
    
    return YES;
}


- (BOOL)sendPacket {
    NSLog(@"Sending Data");
    if (![output_stream hasSpaceAvailable]) {
        return NO;
    }
    
    WritePacket *packet = [writeQueue objectAtIndex:0];
    int numbytes = [output_stream write:[packet.data bytes]+packet.position
                              maxLength:[packet.data length]-packet.position ];
    
    if (numbytes == -1) {
        NSLog(@"Error sending bytes");
        //TODO: handle this
        //NSError *error = [output_stream streamError];
        
        return NO;
    }
    
    if (numbytes < [packet.data length]-packet.position) {
        packet.position += numbytes;
        [self sendPacket];
    }
    
    [writeQueue removeObjectAtIndex:0];
    
    return YES;
}


//Getters/Setters not synthesized
- (NSInteger)port {
    return port;
}
// Used if switching to http server
- (void)setPort:(NSInteger)value {
    port = value;
}

- (void)dealloc{
    NSLog(@"Socket Manager dealloc");
    [host release];
    
    [input_stream close];
    [output_stream close];
    
    [input_stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [output_stream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                             forMode:NSDefaultRunLoopMode];
    
    [input_stream release];
    [output_stream release];
    
    [writeQueue release];
    [commandInterpreter release];
    
    [super dealloc];
}


@end
