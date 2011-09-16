//
//  NSStreamAdditions.h
//  ImageOverSocket-test
//
//  Created by Rex Fenley on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSStream (MyAdditions)
    
+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(NSUInteger)port 
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr;
@end
