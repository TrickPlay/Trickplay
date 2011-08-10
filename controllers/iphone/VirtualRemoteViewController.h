//
//  VirtualRemoteViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

@protocol VirtualRemoteDelegate <NSObject>

@required
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

@end

@interface VirtualRemoteViewController : UIViewController <UIInputViewAudioFeedback> {
    id <VirtualRemoteDelegate> delegate;
    
    CFURLRef clickSoundRef;
    SystemSoundID audioClick;
    
    UIImageView *background;
}

@property (assign) id<VirtualRemoteDelegate> delegate;
@property (retain) IBOutlet UIImageView *background;

- (IBAction)rightPressed:(id)sender;
- (IBAction)leftPressed:(id)sender;
- (IBAction)downPressed:(id)sender;
- (IBAction)upPressed:(id)sender;
- (IBAction)OKPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;
- (IBAction)redPressed:(id)sender;
- (IBAction)greenPressed:(id)sender;
- (IBAction)bluePressed:(id)sender;
- (IBAction)yellowPressed:(id)sender;

@end
