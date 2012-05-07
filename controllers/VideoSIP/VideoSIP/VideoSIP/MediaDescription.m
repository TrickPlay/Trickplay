//
//  MediaDescription.m
//  VideoSIP
//
//  Created by Rex Fenley on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaDescription.h"

@implementation MediaDescription

@synthesize mediaType;
@synthesize networkType;
@synthesize addressType;
@synthesize host;
@synthesize port;
@synthesize numberOfPorts;
@synthesize protocol;
@synthesize formats;


- (void)dealloc {
    self.mediaType = nil;
    self.networkType = nil;
    self.addressType = nil;
    self.host = nil;
    self.port = 0;
    self.numberOfPorts = 0;
    self.protocol = nil;
    self.formats = nil;
    
    [super dealloc];
}

@end
