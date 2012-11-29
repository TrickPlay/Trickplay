//
//  NetServiceManager.h
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetServiceManagerDelegate

@required
- (void)serviceResolved:(NSNetService *)service;
- (void)didNotResolveService:(NSNetService *)service;
- (void)didStopService:(NSNetService *)service;
- (void)didFindService:(NSNetService *)service;
- (void)didRemoveService:(NSNetService *)service;

@end



@interface NetServiceManager : NSObject <NSNetServiceBrowserDelegate,
NSNetServiceDelegate> {
    // private
    NSNetServiceBrowser *netServiceBrowser;
    
    // public
    NSMutableArray *connectingServices;
    NSMutableArray *services;
    
    id <NetServiceManagerDelegate> delegate;
}

- (id)initWithClientDelegate:(id <NetServiceManagerDelegate>)client;

- (void)stop;
- (void)start;
- (void)stopServices;

- (void)handleError:(NSNumber *)error domain:(NSString *)domain;

@property (retain) NSMutableArray *connectingServices;
@property (retain) NSMutableArray *services;
@property (nonatomic, assign) id <NetServiceManagerDelegate> delegate;

@end
