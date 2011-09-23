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
- (void)tvConnectionDidDisconnect:(TVConnection *)connection abruptly:(BOOL)abrupt;

@end




@interface TVConnection : NSObject {

@protected
    id <TVConnectionDelegate> delegate;
    id context;
}

@property (readonly) BOOL isConnected;
@property (readonly) NSUInteger port;
@property (readonly) NSUInteger http_port;
@property (readonly) NSString *hostName;
@property (readonly) NSString *TVName;
@property (readonly) NSNetService *connectedService;

@property (assign) id <TVConnectionDelegate> delegate;

- (id)initWithService:(NSNetService *)service delegate:(id<TVConnectionDelegate>)_delegate;

- (void)disconnect;

@end
