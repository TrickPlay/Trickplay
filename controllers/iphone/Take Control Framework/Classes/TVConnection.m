//
//  TVConnection.m
//  TrickplayController
//
//  Created by Rex Fenley on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVConnection.h"
#import "Extensions.h"
#import "SocketManager.h"

#import <uuid/uuid.h>


@interface TVConnectionContext : TVConnection <SocketManagerDelegate> {
    
@private
    SocketManager *socketManager;
    TVBrowser *tvBrowser;
    AppBrowser *appBrowser;
    
    BOOL isConnected;
    
    NSUInteger port;
    NSUInteger http_port;
    NSString *hostName;
    NSString *TVName;
    
    NSNetService *connectedService;
    
    id <TVConnectionDelegate> delegate;
}

@property (readonly) BOOL isConnected;
@property (readonly) NSUInteger port;
@property (readonly) NSUInteger http_port;
@property (readonly) NSString *hostName;
@property (readonly) NSString *TVName;
@property (readonly) NSNetService *connectedService;

@property (nonatomic, readonly) SocketManager *socketManager;

- (id)initWithService:(NSNetService *)service delegate:(id<TVConnectionDelegate>)delegate;

@end


@implementation TVConnectionContext

@synthesize isConnected;
@synthesize port;
@synthesize http_port;
@synthesize hostName;
@synthesize TVName;
@synthesize connectedService;
@synthesize delegate;
@synthesize socketManager;

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithService:nil delegate:nil];
}

- (id)initWithService:(NSNetService *)service delegate:(id<TVConnectionDelegate>)_delegate {
    
    if (!service) {
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
        [tvBrowser invalidateTVConnection:self];
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
    
    [self.delegate tvConnectionDidDisconnect:self abruptly:abruptly];
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
        [tvBrowser invalidateTVConnection:self];
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
        
    [super dealloc];
}

@end


#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -



@implementation TVConnection

#pragma mark -
#pragma mark Allocation

+ (id)alloc {
    if ([self isEqual:[TVConnection class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [TVConnectionContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[TVConnection class]]) {
        return [TVConnectionContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

#pragma mark -
#pragma mark Initialization

- (id)initWithService:(NSNetService *)service delegate:(id<TVConnectionDelegate>)_delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Private Methods

- (id <TVConnectionDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <TVConnectionDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (SocketManager *)socketManager {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setHttp_port:(NSUInteger)_port {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setAppBrowser:(AppBrowser *)_appBrowser {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTVBrowser:(TVBrowser *)_tvBrowser {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)isConnected {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSUInteger)port {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSUInteger)http_port {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)hostName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)TVName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSNetService *)connectedService {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Deallocation

- (void)disconnect {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/*
- (void)dealloc {
    NSLog(@"TVConnection Dealloc");
    
    [super dealloc];
}
*/

@end
