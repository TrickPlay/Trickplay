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

@implementation TVConnection

@synthesize isConnected;
@synthesize port;
@synthesize http_port;
@synthesize hostName;
@synthesize TVName;
@synthesize connectedService;

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
        // Tell socket manager to create a socket and connect to the service selected
        socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                           port:port
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
        self.delegate = _delegate;
        
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
        NSData *welcomeData = [[NSString stringWithFormat:@"ID\t4.2\t%@\tKY\tAX\tTC\tMC\tSD\tUI\tUX\tVR\tTE%@\tIS=%dx%d\tUS=%dx%d\tID=%@\n", [UIDevice currentDevice].name, hasPictures, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, deviceID] dataUsingEncoding:NSUTF8StringEncoding];
        
        [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
        
        isConnected = YES;
    }
    
    return self;
}

- (void)handleSocketDisconnectAbruptly:(BOOL)abruptly {
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
    
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (socketManager) {
        [socketManager disconnect];
        socketManager.delegate = nil;
        [socketManager release];
        socketManager = nil;
    }
    
    isConnected = NO;
    
    [delegate tvConnectionDidDisconnect:self abruptly:abruptly];
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
#pragma mark Private Methods

- (SocketManager *)socketManager {
    return [[socketManager retain] autorelease];
}

- (void)setHttp_port:(NSUInteger)_port {
    http_port = _port;
}

- (void)setTVBrowser:(TVBrowser *)_tvBrowser {
    tvBrowser = _tvBrowser;
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    self.delegate = nil;
    
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
    
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (socketManager) {
        [socketManager disconnect];
        socketManager.delegate = nil;
        [socketManager release];
        socketManager = nil;
    }
}

@end
