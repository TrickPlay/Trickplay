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
    id <NetServiceManagerDelegate> delegate;
    
    NSNetServiceBrowser *netServiceBrowser;
    NSMutableArray *connectingServices;
    NSMutableArray *services;
}

- (id)initWithDelegate:(id)client;

- (void)stop;
- (void)start;
- (void)stopServices;

- (void)handleError:(NSNumber *)error domain:(NSString *)domain;

@property (retain) NSMutableArray *connectingServices;
@property (retain) NSMutableArray *services;
@property (nonatomic, assign) id <NetServiceManagerDelegate> delegate;

@end
