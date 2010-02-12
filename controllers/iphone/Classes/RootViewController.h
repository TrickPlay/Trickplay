//
//  RootViewController.h
//  TrickplayRemote
//
//  Created by Kenny Ham on 1/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GestureView.h"

@interface RootViewController : UITableViewController  {
	NSNetServiceBrowser* netServiceBrowser;
	NSNetService* currentResolve;
	NSMutableArray* services;
	GestureView *gestureViewController;
}
@property (nonatomic, retain) GestureView *gestureViewController;
@property (nonatomic, retain, readwrite) NSMutableArray* services;
@property (nonatomic, retain, readwrite) NSNetServiceBrowser* netServiceBrowser;
@property (nonatomic, retain, readwrite) NSNetService* currentResolve;

- (void)removeTheChildview;

@end
