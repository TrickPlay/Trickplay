//
//  AppDelegate.m
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)removeVC:(id)object {
    UIViewController *presented = self.viewController.presentedViewController;
    NSLog(@"presented: %@", presented);
    [self.viewController dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"View Controller removed");
        [presented autorelease];
    }];
}

- (void)startVideoStreamer:(id)object {
    VideoStreamerContext *context = [[[VideoStreamerContext alloc] initWithUserName:@"phone" password:@"1234" remoteUserName:@"1002" serverHostName:@"asterisk-1.asterisk.trickplay.com" serverPort:5060 clientPort:50160] autorelease];
    VideoStreamer *videostreamer = [[VideoStreamer alloc] initWithContext:context delegate:self];
    videostreamer.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    
    [self.viewController presentViewController:videostreamer animated:YES completion:^(void) {
        [videostreamer startChat];
        //[self performSelector:@selector(removeVC:) withObject:nil afterDelay:5.0];
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    //*/
    
    //VideoStreamerContext *context = [[[VideoStreamerContext alloc] initWithUserName:@"phone" password:@"1234" remoteUserName:@"1002" serverHostName:@"asterisk-1.asterisk.trickplay.com" serverPort:5060 clientPort:50160] autorelease];
    //VideoStreamer *videostreamer = [[VideoStreamer alloc] initWithContext:context delegate:self];
    //[(VideoStreamer *)self.viewController startChat];
    self.viewController = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    self.viewController.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    [self.window makeKeyAndVisible];
    
    [self performSelector:@selector(startVideoStreamer:) withObject:nil afterDelay:2.0];
    
    /*
    UIViewController *aViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    aViewController.view.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    [self.viewController presentViewController:aViewController animated:YES completion:^(void){
        NSLog(@"Starting Delay");
        [self performSelector:@selector(removeVC:) withObject:nil afterDelay:5.0];
    }];
    //*/
    
    /*
    [self.viewController presentViewController:videostreamer animated:YES completion:^(void) {
        [videostreamer startChat];
    }];
    UIViewController *presented = self.viewController.presentedViewController;
    NSLog(@"presented: %@", presented);
    //*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark VideoStreamerDelegate methods

- (void)videoStreamerInitiatingChat:(VideoStreamer *)videoStreamer {
    NSLog(@"Chat Initiating");
}

- (void)videoStreamerChatStarted:(VideoStreamer *)videoStreamer {
    NSLog(@"Chat Started");
}

- (void)videoStreamer:(VideoStreamer *)videoStreamer chatEndedWithInfo:(NSString *)reason networkCode:(enum NETWORK_TERMINATION_CODE)code {
    NSLog(@"Chat Ended: %@", reason);
    NSLog(@"Network Code: %d", code);
    UIViewController *presented = self.viewController.presentedViewController;
    //NSLog(@"presented: %@", presented);
    [self.viewController dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"Video Streamer Dismissed");
        [presented autorelease];
    }];
}

@end
