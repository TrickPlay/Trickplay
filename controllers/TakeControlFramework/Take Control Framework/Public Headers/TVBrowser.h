//
//  TVBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVConnection;
@class TVBrowser;
@class TVBrowserViewController;


/**
 * The TVBrowserDelegate Protocol informs the TVBrowser's delegate when TVs
 * post their connection information in the form of an NSNetService
 * to the local network and informs the delegate when a connection
 * between the iOS device and the TV is made.
 */

@protocol TVBrowserDelegate <NSObject>

@required
- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service;
- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service;

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)isNewConnection;
- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service;

@end


/**
 * The TVBrowser class automatically searches for possible TVs to connect to.
 * The TVs are represented by NSNetService objects. The TVBrowser's delegate
 * receives calls when TVs advertise their connection information over the
 * local network. Calling:
 * - (void)connectToService:(NSNetService *)service will tell the TVBrowser
 * to attempt to connect to the NSNetService object "service" provided that the
 * the service is broadcasted from a Trickplay enabled TV. If the connection is
 * established, a TVConnection object is passed back to the delegate in a message,
 * else, the same NSNetService that the TVBrowser failed to connect to is passed to
 * the delegate.
 *
 * The TVBrowser automatically begins searching for TVs when initialized.
 *
 * The TVBrowser allows the owner to call - connectToService: multiple times
 * for multiple different connections. It is up to the owner to manage the 
 * TVConnection objects passed to the delegate. Releasing TVConnection objects
 * automatically disconnects the connection when - dealloc is called on
 * the TVConnection object.
 *
 * The owner of the TVBrowser may create a TVBrowserViewController which
 * provides an automatically updated UI for its host TVBrowser.
 * The TVBrowserViewController retains its TVBrowser, so the owner may release
 * the TVBrowser after creation. However, The caller to - getNewTVBrowserViewController
 * does not own the returned TVBrowserViewController; the caller must retain
 * the returned TVBrowserViewController if it is intended for long term use.
 *
 * When the TVBrowser is searching for TVs it may slow down all connected
 * TVConnection objects, thus slowing down communication between already established
 * connections to local TVs. Therefore, the owner should call
 * - (void)stopSearchForServices when the TVBrowser is not needed, in order to
 * not bog down any active connections.
 */

@interface TVBrowser : NSObject

// Exposed instance variables
@property (assign) id <TVBrowserDelegate> delegate;

// initialization
- (id)initWithDelegate:(id <TVBrowserDelegate>)delegate;
// Creates and returns an autorelased TVBrowserViewController.
- (TVBrowserViewController *)getNewTVBrowserViewController;
// Returns an array of all NSNetServices that represent possible connections
// to TVs over the local network.
- (NSArray *)getAllServices;
// Returns all NSNetService objects that an active TVConnection object
// maintains a conneciton to. This implies a TVConnection object exists for each one of the
// NSNetService objects in this array.
- (NSArray *)getConnectedServices;
// Returns an array of all NSNetService objects the TVBrowser is attempting
// to form a connection with.
- (NSArray *)getConnectingServices;
// Starts the TVBrowser.
- (void)startSearchForServices;
// Stops the TVBrowser.
- (void)stopSearchForServices;
// Clears the cashe of TV services and attempts to reload available TVs.
// Re-Starts the TVBrowser if already started, else starts the TVBrowser
- (void)refreshServices;
// The TVBrowser attempts to connect to the NSNetService object provided
// that the NSNetService object represents a connection to a Trickplay
// enabled TV.
- (void)connectToService:(NSNetService *)service;

@end
