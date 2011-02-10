//
//  SocketManager.h
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSStreamAdditions.h"


@interface SocketManager : NSObject <NSStreamDelegate> {
    NSInputStream *input_stream;
    NSOutputStream *output_stream;
    
    CFReadStreamRef read_stream;
    CFWriteStreamRef write_stream;
    
    BOOL can_write;
}

@property (nonatomic, retain) NSOutputStream *output_stream;
@property (nonatomic, retain) NSInputStream *input_stream;

-(id)initSocketStream:(NSString *)host port:(NSInteger)port;

-(id)initSocketStreamWithCF:(id)var
readStreamCallback:(CFReadStreamClientCallBack)readCallback;
-(BOOL)sendData:(void *)data numberOfBytes:(int)bytes;

@end
