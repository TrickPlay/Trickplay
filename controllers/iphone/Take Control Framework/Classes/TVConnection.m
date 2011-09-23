//
//  TVConnection.m
//  TrickplayController
//
//  Created by Rex Fenley on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVConnection.h"
#import "Extensions.h"

#import <uuid/uuid.h>


@interface TVConnectionContext : NSObject <SocketManagerDelegate> {
    
@private
    TVConnection *tvConnection;
    SocketManager *socketManager;
    TVBrowser *tvBrowser;
    AppBrowser *appBrowser;
    
    BOOL isConnected;
    
    NSUInteger port;
    NSUInteger http_port;
    NSString *hostName;
    NSString *TVName;
    
    NSNetService *connectedService;
}

@property (readonly) BOOL isConnected;
@property (readonly) NSUInteger port;
@property (readonly) NSUInteger http_port;
@property (readonly) NSString *hostName;
@property (readonly) NSString *TVName;
@property (readonly) NSNetService *connectedService;

@property (nonatomic, readonly) SocketManager *socketManager;

- (id)initWithTVConnection:(TVConnection *)tvConnection service:(NSNetService *)service;

@end


@implementation TVConnectionContext

@synthesize isConnected;
@synthesize port;
@synthesize http_port;
@synthesize hostName;
@synthesize TVName;
@synthesize connectedService;

@synthesize socketManager;

- (id)init {
    return [self initWithTVConnection:nil service:nil];
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection service:(NSNetService *)service{
    if (!_tvConnection) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        // Tell socket manager to create a socket and connect to the service selected
        socketManager = [[SocketManager alloc] initSocketStream:service.hostName
                                                           port:service.port
                                                       delegate:self
                                                       protocol:APP_PROTOCOL];
        
        if (![socketManager isFunctional]) {
            NSLog(@"Could Not Establish Connection");
            socketManager.delegate = nil;
            [socketManager release];
            socketManager = nil;
            
            [self release];
            return nil;
        }
        
        hostName = [[service hostName] retain];
        port = [service port];
        TVName = [[service name] retain];
        connectedService = [service retain];
        
        // Made a connection, let the service know!
        // Get the actual width and height of the available area
        CGFloat backgroundWidth, backgroundHeight;
        
        CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
        backgroundHeight = mainframe.size.height;
        backgroundHeight = backgroundHeight - 44;  //subtract the height of navbar
        backgroundWidth = mainframe.size.width;
        
        // Figure out if the device can use pcitures
        NSString *hasPictures = @"";
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            hasPictures = @"\tPS";
        }
        
        // Retrieve the UUID or make a new one and save it
        NSString *deviceID;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *savedData = [userDefaults dataForKey:@"TakeControlID"];
        if (savedData) {
            deviceID = [[[NSString alloc] initWithBytes:[savedData bytes] length:[savedData length] encoding:NSUTF8StringEncoding] autorelease];
        } else {
            uuid_t generated_id;
            uuid_generate(generated_id);
            deviceID = [[[NSString alloc] initWithBytes:generated_id length:16 encoding:NSUTF8StringEncoding] autorelease];
            [userDefaults setObject:deviceID forKey:@"TakeControlID"];
        }
        
        // Tell the service what this device is capable of
        NSData *welcomeData = [[NSString stringWithFormat:@"ID\t4.3\t%@\tKY\tAX\tTC\tMC\tSD\tUI\tUX\tVR\tTE%@\tIS=%dx%d\tUS=%dx%d\tID=%@\n", [UIDevice currentDevice].name, hasPictures, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, deviceID] dataUsingEncoding:NSUTF8StringEncoding];
        
        [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
        
        isConnected = YES;
        
        tvBrowser = nil;
        appBrowser = nil;
        
        tvConnection = _tvConnection;
    }
    
    return self;
}

#pragma mark -
#pragma mark SocketManagerDelegate methods

- (void)handleSocketDisconnectAbruptly:(BOOL)abruptly {
    
    isConnected = NO;
    
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (appBrowser) {
        [appBrowser refresh];
        appBrowser = nil;
    }
    
    if (tvBrowser) {
        [tvBrowser invalidateTVConnection:tvConnection];
        tvBrowser = nil;
    }
    
    if (connectedService) {
        [connectedService release];
        connectedService = nil;
    }
    
    if (TVName) {
        [TVName release];
        TVName = nil;
    }
    
    if (socketManager) {
        socketManager.delegate = nil;
        [socketManager release];
        socketManager = nil;
    }
    
    [tvConnection.delegate tvConnectionDidDisconnect:tvConnection abruptly:abruptly];
}

- (void)socketErrorOccurred {
    [self handleSocketDisconnectAbruptly:YES];
}

- (void)streamEndEncountered {
    [self handleSocketDisconnectAbruptly:NO];
}

- (void)disconnect {
    [socketManager disconnect];
}

#pragma mark -
#pragma mark Getters/Setters

- (void)setHttp_port:(NSUInteger)_port {
    http_port = _port;
    if (appBrowser) {
        [appBrowser refresh];
    }
}

- (void)setAppBrowser:(AppBrowser *)_appBrowser {
    appBrowser = _appBrowser;
}

- (void)setTVBrowser:(TVBrowser *)_tvBrowser {
    tvBrowser = _tvBrowser;
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    isConnected = NO;
    
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (appBrowser) {
        appBrowser = nil;
    }
    
    if (tvBrowser) {
        [tvBrowser invalidateTVConnection:tvConnection];
        tvBrowser = nil;
    }
    
    if (connectedService) {
        [connectedService release];
        connectedService = nil;
    }
    
    if (TVName) {
        [TVName release];
        TVName = nil;
    }
    
    if (socketManager) {
        [socketManager disconnect];
        socketManager.delegate = nil;
        [socketManager release];
        socketManager = nil;
    }
    
    tvConnection = nil;
    
    [super dealloc];
}

@end






@implementation TVConnection

@synthesize delegate;

// TODO: test this init
- (id)init
{
    return [self initWithService:nil delegate:nil];
}

- (id)initWithService:(NSNetService *)service
             delegate:(id<TVConnectionDelegate>)_delegate {
    
    if (!service) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        context = [[TVConnectionContext alloc] initWithTVConnection:self service:service];
        if (!context) {
            [self release];
            return nil;
        }
        
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark -
#pragma mark Private Methods

- (SocketManager *)socketManager {
    return [[((TVConnectionContext *)context).socketManager retain] autorelease];
}

- (void)setHttp_port:(NSUInteger)_port {
    [(TVConnectionContext *)context setHttp_port:_port];
}

- (void)setAppBrowser:(AppBrowser *)_appBrowser {
    [(TVConnectionContext *)context setAppBrowser:_appBrowser];
}

- (void)setTVBrowser:(TVBrowser *)_tvBrowser {
    [(TVConnectionContext *)context setTVBrowser:_tvBrowser];
}

- (BOOL)isConnected {
    return ((TVConnectionContext *)context).isConnected;
}

- (NSUInteger)port {
    return ((TVConnectionContext *)context).port;
}

- (NSUInteger)http_port {
    return ((TVConnectionContext *)context).http_port;
}

- (NSString *)hostName {
    return ((TVConnectionContext *)context).hostName;
}

- (NSString *)TVName {
    return ((TVConnectionContext *)context).TVName;
}

- (NSNetService *)connectedService {
    return ((TVConnectionContext *)context).connectedService;
}

#pragma mark -
#pragma mark Deallocation

- (void)disconnect {
    [(TVConnectionContext *)context disconnect];
}

- (void)dealloc {
    NSLog(@"TVConnection Dealloc");
    
    self.delegate = nil;
    [(TVConnectionContext *)context release];
    context = nil;
    
    [super dealloc];
}

@end
