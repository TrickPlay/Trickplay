//
//  MediaDescription.h
//  VideoSIP
//
//  Created by Rex Fenley on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaDescription : NSObject {
    NSString *mediaType;
    NSString *networkType;
    NSString *addressType;
    NSString *host;
    NSUInteger port;
    NSUInteger numberOfPorts;
    NSString *protocol;
    NSArray *formats;
}

@property (nonatomic, retain) NSString *mediaType;
@property (nonatomic, retain) NSString *networkType;
@property (nonatomic, retain) NSString *addressType;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) NSUInteger numberOfPorts;
@property (nonatomic, retain) NSString *protocol;
@property (nonatomic, retain) NSArray *formats;

@end
