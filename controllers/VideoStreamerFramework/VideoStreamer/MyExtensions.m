//
//  MyExtensions.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// md5 code found here: http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
// uuid code found here: http://stackoverflow.com/questions/227590/unique-identifier-for-an-iphone-app
//

#import "MyExtensions.h"

#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access

@implementation NSString (MyExtensions)

+ (NSString *)uuid {
    NSString *uuid = nil;
    CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
    if (theUUID) {
        uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
        [uuid autorelease];
        CFRelease(theUUID);
    }
    
    return uuid;
}

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end

@implementation NSData (MyExtensions)

- (NSString *)md5 {
    unsigned char result[16];
    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end