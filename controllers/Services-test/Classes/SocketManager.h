//
//  SocketManager.h
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSStreamAdditions.h"
#import "CommandInterpreter.h"


@interface WritePacket : NSObject
{
    NSData *data;
    NSUInteger position;
}

@property (retain) NSData *data;
@property (readwrite) NSUInteger position;

@end



@protocol SocketManagerDelegate

@optional
- (void) socketErrorOccurred;

@end

@interface SocketManager : NSObject <NSStreamDelegate> {
    NSInputStream *input_stream;
    NSOutputStream *output_stream;
    
    id <SocketManagerDelegate> delegate;
    
    NSMutableArray *writeQueue;
    
    CommandInterpreter *commandInterpreter;
}

@property (nonatomic, retain) NSOutputStream *output_stream;
@property (nonatomic, retain) NSInputStream *input_stream;
@property (nonatomic, assign) id <SocketManagerDelegate> delegate;


- (id)initSocketStream:(NSString *)host
                  port:(NSInteger)port
              delegate:(id <SocketManagerDelegate>)theDelegate;

- (void)sendData:(const void *)data numberOfBytes:(int)bytes;
- (BOOL)sendPackets;
- (BOOL)sendPacket;


@end
