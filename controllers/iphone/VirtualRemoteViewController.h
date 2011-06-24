//
//  VirtualRemoteViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VirtualRemoteDelegate <NSObject>

@required
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

@end

@interface VirtualRemoteViewController : UIViewController {
    id <VirtualRemoteDelegate> delegate;
}

@property (assign) id<VirtualRemoteDelegate> delegate;

- (IBAction)rightPressed:(id)sender;
- (IBAction)leftPressed:(id)sender;
- (IBAction)downPressed:(id)sender;
- (IBAction)upPressed:(id)sender;
- (IBAction)OKPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;

@end
