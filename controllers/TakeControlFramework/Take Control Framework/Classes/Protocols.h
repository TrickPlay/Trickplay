//
//  Protocols.h
//  TrickplayController
//
//  Created by Rex Fenley on 9/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * TVConnection Delegate Protocol for TVBrowser informing of successful
 * or unsuccessful connection.
 */

@protocol TVConnectionDidConnectDelegate <NSObject>

@required
- (void)tvConnection:(TVConnection *)tvConnection didConnectToService:(NSNetService *)service;
- (void)tvConnection:(TVConnection *)tvConnection didNotConnectToService:(NSNetService *)service;

@end



#pragma mark -
#pragma mark TPAppViewController related protocols

/**
 * The AdvancedUIDelegate protocol implemented by AdvancedUIObjectManager
 * registers a delegate which is passed asyncronous calls made for AdvancedUI.
 * (Given that the TPAppViewController is the only object which utilizes
 * asynchronous socket communication with Trickplay, it is the only object
 * which has one of these delgates.)
 *
 * The calls currently available include informing the AdvancedUIObjectManager
 * of the host and port to use for its socket connection, starting this connection,
 * and cleaning (involves deleting objects and reseting values).
 */

@protocol AdvancedUIDelegate <NSObject>

@required
- (void)setupServiceWithPort:(NSUInteger)p
                    hostname:(NSString *)h;
- (BOOL)startServiceWithID:(NSString *)ID;

- (void)clean;

@end

/**
 * The ViewControllerTouchDelegate handles commands from Trickplay to
 * enable/disable touch events. Likewise this delegate must inform
 * the TPAppViewController of iOS touch events so these events can be
 * forwarded back to Trickplay.
 *
 * Only the TouchController class implements this protocol.
 */

@protocol ViewControllerTouchDelegate

@required
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)startTouches;
- (void)stopTouches;

- (void)setSwipe:(BOOL)allowed;

- (void)reset;

@end