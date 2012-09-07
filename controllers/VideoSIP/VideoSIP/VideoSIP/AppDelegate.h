//
//  AppDelegate.h
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoStreamer.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, VideoStreamerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@end
