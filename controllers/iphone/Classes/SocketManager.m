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
@synthesize appViewController;

@synthesize host;


- (id)initSocketStream:(NSString *)theHost
                 port:(NSUInteger)thePort
             delegate:(id <SocketManagerDelegate>)theDelegate
             protocol:(CommandProtocol)protocol {
    if ((self = [super init])) {
        functional = YES;
        
        self.input_stream = nil;
        self.output_stream = nil;
        self.host = nil;
        self.delegate = nil;
        self.appViewController = nil;
        
        commandInterpreter = nil;
        writeQueue = nil;
        
        // Defines the type of communications protocol that will be used
        // for messages coming through this socket
        if (protocol == ADVANCED_UI_PROTOCOL) {
            commandInterpreter = [[CommandInterpreterAdvancedUI alloc] init:(id)theDelegate];
        } else if (protocol == APP_PROTOCOL) {
            commandInterpreter = [[CommandInterpreterApp alloc] init:(id)theDelegate];
        } else {
            NSLog(@"Error, protocol not defined");
            functional = NO;
            return self;
        }
        
        // Create the socket
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
            
            functional = NO;
            return self;
        }
        
        // Dot syntax properly releases and retains objects
        self.host = theHost;
        port = thePort;
    
        self.input_stream = inputStream;
        self.output_stream = outputStream;
    
        [input_stream setDelegate:self];
        [output_stream setDelegate:self];

        writeQueue = [[NSMutableArray alloc] initWithCapacity:20];
        
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

- (BOOL)isFunctional {
    return functional;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    if (!functional) {
        return;
    }
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    switch (eventCode) {
        /**
         * Unload all the data from the socket stream and send it to the command
         * interpreter.
         */
        case NSStreamEventHasBytesAvailable:
            if (stream != input_stream) return;
            
            //NSLog(@"\n\nHas bytes available. delegate: %@\n\n", delegate);
            
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
                } else {
                    NSLog(@"Zero bytes. delegate: %@", delegate);
                }
            }
            
            /*
            char buffer[100];
            numbytes = [(NSInputStream *)stream read:(uint8_t *)buffer
                                     maxLength:(NSUInteger) 99];

            buffer[numbytes] = '\0';
            fprintf(stderr, "received: '%s' length: %d\n", buffer, numbytes);
            */
            //NSLog(@"\n\nBytes done reading. delegate %@\n\n", delegate);
            CFAbsoluteTime then = CFAbsoluteTimeGetCurrent();
            fprintf(stderr, "read time = %lf\n", (then-start)*1000.0);
            //NSLog(@"read time = %lf \t. delegate %@", (then - now)*1000.0, delegate);
            break;
        // Close up the streams cuz there aint nothin left.
        case NSStreamEventEndEncountered:
            NSLog(@"Stream end encountered");
            [appViewController streamEndEncountered];
            [delegate streamEndEncountered];
            // TODO: continues to crash here without checking (functional == YES) at top
            // of method.
            // space in memory might be reassigned for some other variable after
            // dealloc, then this method gets called after this object deallocs
            // because the stream is somehow still accessing its delegate
            // (which should have been assigned to nil).
            
            
            break;
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"\n\nStream has space available. delegate: %@\n\n", delegate);
            [self sendPackets];

            //CFAbsoluteTime bytessenttime = CFAbsoluteTimeGetCurrent();
            //fprintf(stderr, "write time = %lf\n", (bytessenttime-start)*1000.0);
            //NSLog(@"write time = %lf\t. delegate %@", (bytessenttime - start)*1000.0, delegate);
            //NSLog(@"\n\nBytes done sending. delegate: %@\n\n", delegate);
            break;
        case NSStreamEventErrorOccurred:
            [appViewController socketErrorOccurred];
            [delegate socketErrorOccurred];
            
            // TODO: delete this test
            [(id <SocketManagerDelegate>) nil socketErrorOccurred];
            
            break;
        case NSStreamEventNone:
            NSLog(@"Stream no event has occurred");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream Open Completed");
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
    if (!functional) {
        return;
    }
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
    //NSLog(@"Sending Data");
    if (![output_stream hasSpaceAvailable]) {
        return NO;
    }
    
    WritePacket *packet = [writeQueue objectAtIndex:0];
    int numbytes = [output_stream write:[packet.data bytes]+packet.position
                              maxLength:[packet.data length]-packet.position];
    
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


// Getters/Setters not synthesized
- (NSUInteger)port {
    return port;
}
// Used if switching to http server
- (void)setPort:(NSUInteger)value {
    port = value;
}

- (void)setCommandInterpreterDelegate:(id)_delegate withProtocol:(CommandProtocol)protocol {
    if (commandInterpreter) {
        if ([commandInterpreter isKindOfClass:[CommandInterpreterApp class]] && protocol == APP_PROTOCOL) {
            ((CommandInterpreterApp *)commandInterpreter).delegate = (id <CommandInterpreterAppDelegate>)_delegate;
        } else if ([commandInterpreter isKindOfClass:[CommandInterpreterAdvancedUI class]] && protocol == ADVANCED_UI_PROTOCOL) {
            ((CommandInterpreterAdvancedUI *)commandInterpreter).delegate = (id <CommandInterpreterAdvancedUIDelegate>)_delegate;
        }
    }
}

- (void)disconnect {
    functional = NO;
    
    self.host = nil;
    self.delegate = nil;
    self.appViewController = nil;
    
    if (input_stream) {
        input_stream.delegate = nil;
        [input_stream close];
        [input_stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        self.input_stream = nil;
    }
    
    if (output_stream) {
        output_stream.delegate = nil;
        [output_stream close];    
        [output_stream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                                 forMode:NSDefaultRunLoopMode];
        self.output_stream = nil;
    }
    
    if (writeQueue) {
        [writeQueue release];
        writeQueue = nil;
    }
    
    if (commandInterpreter) {
        [commandInterpreter release];
        commandInterpreter = nil;
    }
    
    NSLog(@"Socket disconnected");
}

- (void)dealloc {
    NSLog(@"Socket Manager dealloc with CommandInterpreter: %@", commandInterpreter);

    [self disconnect];
        
    [super dealloc];
}


@end
