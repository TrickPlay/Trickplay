//
//  TVConnection.h
//  TrickplayController
//
//  Created by Rex Fenley on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVConnection;
@class TVBrowser;
@class AppBrowser;

@protocol TVConnectionDelegate <NSObject>

@required
- (void)tvConnectionDidDisconnect:(TVConnection *)connection abruptly:(BOOL)abruptly;

@end


/**
 * The TVConnection class contains all the connection information
 * as well as the connection to a Trickplay enabled TV. TVConnection
 * objects can only be created via a TVBrowser object and is forwarded
 * to the owner by the TVBrowser object's delegate.
 */

@interface TVConnection : NSObject

@property (readonly) BOOL isConnected;
@property (readonly) NSUInteger port;
@property (readonly) NSUInteger http_port;
@property (readonly) NSString *hostName;
@property (readonly) NSString *TVName;
@property (readonly) NSNetService *connectedService;

@property (assign) id <TVConnectionDelegate> delegate;

// Disconnects this TVConnection. Any AppBrowser, TVBrowser, or
// TPAppViewController associated with this TVConnection will be
// informed of this disconnect. The TVConnection can not be
// reconnected and should be properly released and discarded after
// the call to this method.
- (void)disconnect;

@end
