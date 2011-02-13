//
//  SocketManager.m
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SocketManager.h"


#define HOST "10.0.190.153"


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


-(id)initSocketStream:(NSString *)host
                 port:(NSInteger)port
             delegate:(id <SocketManagerDelegate>)theDelegate{
    if (self == [super init]) {
   
        NSInputStream *inputStream;
        NSOutputStream *outputStream;
    
        [NSStream getStreamsToHostNamed:host
                                   port:port
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
    
        input_stream = inputStream;
        output_stream = outputStream;
    
        [input_stream setDelegate:self];
        [output_stream setDelegate:self];
    
        [input_stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [output_stream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                                 forMode:NSDefaultRunLoopMode];
    
        [input_stream open];
        [output_stream open];
        
        writeQueue = [[NSMutableArray alloc] initWithCapacity:20];
        
        commandInterpreter = [[CommandInterpreter alloc] init];
        commandInterpreter.delegate = (id <CommandInterpreterDelegate>)theDelegate;
        self.delegate = theDelegate;
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
            
            fprintf(stderr, "Has bytes available\n");
            
            NSInteger numbytes;
            
            uint8_t buffer[5000];
            while (numbytes != 0) {
                if ((numbytes = [(NSInputStream *)stream read:buffer maxLength:5000]) == -1) {
                    fprintf(stderr, "Read Error occurred\n");
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
            fprintf(stderr, "Stream end encountered\n");
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil;
            // TODO: handle disconnection.
            break;
        case NSStreamEventHasSpaceAvailable:
            fprintf(stderr, "Stream has space available\n");
            [self sendPackets];
            break;
        case NSStreamEventErrorOccurred:
            [[self delegate] socketErrorOccurred];
            break;
        default:
            fprintf(stderr, "Some other event code\n");
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
    fprintf(stderr, "Sending Data\n");
    if (![output_stream hasSpaceAvailable]) {
        return NO;
    }
    
    WritePacket *packet = [writeQueue objectAtIndex:0];
    int numbytes = [output_stream write:[packet.data bytes]+packet.position
                              maxLength:[packet.data length]-packet.position ];
    
    if (numbytes == -1) {
        fprintf(stderr, "Error sending bytes\n");
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


-(void) dealloc{
    [input_stream close];
    [output_stream close];
    
    [input_stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [output_stream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                             forMode:NSDefaultRunLoopMode];
    
    [input_stream release];
    [output_stream release];
    
    [writeQueue release];
    
    [super dealloc];
}


@end
