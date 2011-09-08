//
//  NetServiceManager.h
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetServiceManagerDelegate

@optional
- (void)serviceResolved:(NSNetService *)service;
- (void)didNotResolveService;
- (void)didFindService:(NSNetService *)service;
- (void)didRemoveService:(NSNetService *)service;

@end



@interface NetServiceManager : NSObject <NSNetServiceBrowserDelegate,
NSNetServiceDelegate> {
    id <NetServiceManagerDelegate> delegate;
    
    NSNetServiceBrowser *netServiceBrowser;
    NSNetService *currentService;
    NSMutableArray *services;
}

- (id)initWithDelegate:(id)client;

- (void)stop;
- (void)start;
- (void)stopCurrentService;

- (void)handleError:(NSNumber *)error domain:(NSString *)domain;

@property (retain) NSNetService *currentService;
@property (retain) NSMutableArray *services;
@property (nonatomic, assign) id <NetServiceManagerDelegate> delegate;

@end
