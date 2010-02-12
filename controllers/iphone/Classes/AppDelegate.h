//
//  TrickplayRemoteAppDelegate.h
//  TrickplayRemote
//
//  Created by Kenny Ham on 1/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

