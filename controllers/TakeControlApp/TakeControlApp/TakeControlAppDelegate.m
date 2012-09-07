//
//  TakeControlAppAppDelegate.m
//  TakeControlApp
//
//  Created by Rex Fenley on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"

#import "TakeControlAppDelegate.h"

#import "TakeControlAppViewController.h"

@implementation TakeControlAppAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"6ff472dad8451a622a5f2e1c5f6fe20a_MzY1NDUyMDExLTEwLTI0IDE1OjA1OjIyLjI0MDk1NA"];
    // Override point for customization after application launch.
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[TakeControlAppViewController alloc] initWithNibName:@"TakeControlAppViewController_iPhone" bundle:nil] autorelease]; 
    } else {
        self.viewController = [[[TakeControlAppViewController alloc] initWithNibName:@"TakeControlAppViewController_iPad" bundle:nil] autorelease]; 
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [TestFlight passCheckpoint:@"didFinishLaunchingWithOptions"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [TestFlight passCheckpoint:@"applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
  [TestFlight passCheckpoint:@"applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
  [TestFlight passCheckpoint:@"applicationWillEnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
  [TestFlight passCheckpoint:@"applicationDidBecomeActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
  [TestFlight passCheckpoint:@"applicationWillTerminate"];
}

@end
