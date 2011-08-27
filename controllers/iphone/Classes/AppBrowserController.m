//
//  AppBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowserController.h"

@implementation AppBrowserController

@synthesize appsAvailable;
@synthesize delegate;
@synthesize currentAppName;
//@synthesize appViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setupService:(NSInteger)p hostname:(NSString *)h thetitle:(NSString *)n {
    
}

@end
