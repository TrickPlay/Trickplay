//
//  GestureView.h
//  TrickplayRemote
//
//  Created by Kenny Ham on 1/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AsyncSocket.h"

@class AudioStreamer;

@interface GestureView : UIViewController <UITextFieldDelegate, AVAudioPlayerDelegate> {
    UIAccelerationValue accelerationY;
	UIAccelerationValue accelerationX;
	UIAccelerationValue accelerationZ;
	UIAccelerationValue myAcceleration[3];
	AsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
    CGPoint startTouchPosition;
	CGPoint currentTouchPosition;
	BOOL mSwipeSent;
	BOOL mKeySent;
	NSTimeInterval mTouchedTime;
	NSInteger mAccelMode;
	NSInteger mAccelerationFrequency;
	NSMutableArray      *multipleChoiceArray;
	id mSender;
	BOOL mTryingToConnect;
	UIActivityIndicatorView *waitingView;
	UIActionSheet *mStyleAlert;
	UITextField *mTextField;
	BOOL mClickEventsAllowed;
	BOOL mTouchEventsAllowed;
	UIImageView *backgroundView;
	NSMutableArray *mResourceNameCollection;
	NSMutableArray *mResourceDataCollection;
	AVAudioPlayer  *mAudioPlayer;
	NSString *mSoundLoopName;
	AudioStreamer *streamer;
}

@property NSTimeInterval mTouchedTime;
@property (nonatomic, retain) NSString *mSoundLoopName;
@property (nonatomic, retain) id *mSender;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingView;
@property (nonatomic, retain) UIActionSheet *mStyleAlert;
@property (nonatomic, retain) IBOutlet UITextField *mTextField;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) NSMutableArray *mResourceNameCollection;
@property (nonatomic, retain) AVAudioPlayer  *mAudioPlayer;
@property (nonatomic, retain) NSMutableArray *mResourceDataCollection;

- (void)setupService:(NSInteger)port hostname:(NSString *)hostname thetitle:(NSString *)thetitle;
- (void)setTheParent:(id)sender;
- (void)removeServiceFromCollection;
- (IBAction)hideTextBox:(id)sender;

@end
