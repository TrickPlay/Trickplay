//
//  NSStreamAdditions.h
//  TrickplayRemote
//
//  Created by Kenny Ham on 9/11/10.
//  Copyright 2010 Northrop. All rights reserved.
//

//#import <Foundation/Foundation.h>


//@interface NSStreamAdditions : NSObject {

//}

//@end
//#import 

@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(NSInteger)port 
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr;

@end