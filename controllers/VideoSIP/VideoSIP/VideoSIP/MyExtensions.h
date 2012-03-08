//
//  MyExtensions.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// code found here: http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
//

#import <Foundation/Foundation.h>

@interface NSString (MyExtensions)

+ (NSString *)uuid;
- (NSString *)md5;

@end


@interface NSData (MyExtensions)

- (NSData *)md5;

@end