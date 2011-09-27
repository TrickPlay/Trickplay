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
 * The TVBrowserDelegate Protocol informs the delegate of a TVBrowser object
 * of when TVs post their connection information in the form of an mDNS broadcast
 * to the network and informs the delegate when a connection between the iOS
 * device and the TV is made.
 */

@protocol TVBrowserDelegate <NSObject>

@required
- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service;
- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service;

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)new;
- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service;

@end


/**
 * The TVBrowser class automatically searches for possible TVs to connect to.
 * The TVBrowser's delegate recieves calls when TVs advertise their connection
 * information over the local network. Calling:
 * - (void)connectToService:(NSNetService *)service will tell the TVBrowser
 * to attempt to connect to the NSNetService object "service" provided that it is
 * broadcasted from at Trickplay enabled TV. Whether or not the connection
 * is established is passed back to the delegate as a message containing either
 * the TVConnection (that was established) or the NSNetService that the TVBrowser
 * failed to connect to.
 *
 * The TVBrowser automatically begins searching for TVs when initialized.
 *
 * The TVBrowser does allow the owner to call - connectToService: multiple times
 * for multiple different connections. It is up to the owner to manage the 
 * TVConnection objects passed to the delegate. Releasing TVConnection objects
 * automatically disconnects the connection when the TVConnection object calls
 * dealloc on itself.
 *
 * The owner of the TVBrowser may create a TVBrowserViewController which
 * provides an automatically updated UI for its host TVBrowser.
 * The TVBrowserViewController retains its TVBrowser, so the owner may release
 * the TVBrowser after creation. The caller to - createTVBrowserViewController
 * owns the returned TVBrowserViewController; the owner must release the returned
 * TVBrowserViewController when it is no longer in use.
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
// Creates and returns a TVBrowserViewController with a retain count of 1.
// The caller owns the returned TVBrowserViewController.
- (TVBrowserViewController *)createTVBrowserViewController;
// Returns an array of all NSNetServices that represent possible connections
// to TVs over the local network.
- (NSArray *)getAllServices;
// Returns all NSNetService objects that there are currently active connections
// to. This implies a TVConnection object exists for each one of the
// NSNetService objects in this array.
- (NSArray *)getConnectedServices;
// Returns an array of all NSNetService objects the TVBrowser is attempting
// to form a connection with.
- (NSArray *)getConnectingServices;
// Starts the TVBrowser.
- (void)startSearchForServices;
// Stops the TVBrowser.
- (void)stopSearchForServices;
// Re-Starts the TVBrowser if already started, else starts the TVBrowser
- (void)refreshServices;
// The TVBrowser attempts to connect to the NSNetService object provided
// that the NSNetService object represents a connection to a Trickplay
// enabled TV.
- (void)connectToService:(NSNetService *)service;

@end
