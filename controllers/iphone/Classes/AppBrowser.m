//
//  AppBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowser.h"

@implementation AppBrowser

@synthesize appsAvailable;
@synthesize delegate;
@synthesize currentAppName;
@synthesize appViewController;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setupService:(NSUInteger)port hostName:(NSString *)hostName serviceName:(NSString *)serviceName {
    
}

- (BOOL)startService {
    return YES;
}

#pragma mark -
#pragma mark Retrieving App Info From Network

/**
 * Returns true if the AppBrowserViewController can confirm an app is running
 * on Trickplay by asking it over the network.
 */
- (BOOL)hasRunningApp {
    if (![appViewController hasConnection]) {
        return NO;
    }
    NSDictionary *currentAppInfo = [self getCurrentAppInfo];
    NSLog(@"Received JSON dictionary current app data = %@", currentAppInfo);
    if (!currentAppInfo) {
        return NO;
    }
    
    self.currentAppName = (NSString *)[currentAppInfo objectForKey:@"name"];
    
    
    if (currentAppName && ![currentAppName isEqualToString:@"Empty"]) {
        return YES;
    }
    
    return NO;
}

/**
 * Asks Trickplay for the currently running app and any information pertaining
 * to this app assembled in a JSON string. The method takes this JSON string reply
 * and returns it as an NSDictionary or nil on error.
 */
- (NSDictionary *)getCurrentAppInfo {
    NSLog(@"Getting Current App Info");
    if (![appViewController hasConnection]) {
        return nil;
    }
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", appViewController.socketManager.host, appViewController.socketManager.port];
    //NSLog(@"JSONString = %@", JSONString);
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    //NSLog(@"Received JSONData = %@", [NSString stringWithCharacters:[JSONData bytes] length:[JSONData length]]);
    //NSArray *JSONArray = [JSONData yajl_JSON];
    return (NSDictionary *)[JSONData yajl_JSON];
}

- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)theDelegate {
    NSLog(@"Fetching Apps");
    
    if (!theDelegate) {
        theDelegate = delegate;
    }
    
    currentAppDelegate = theDelegate;
    
    if (![appViewController hasConnection]) {
        self.currentAppName = nil;
        [theDelegate didReceiveCurrentAppInfo:nil];
        return;
    }
    
    if (currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
    }
    if (currentAppData) {
        [currentAppData release];
        currentAppData = nil;
    }
    
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", appViewController.socketManager.host, appViewController.socketManager.port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    currentAppInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!currentAppInfoConnection) {
        self.currentAppName = nil;
        [theDelegate didReceiveCurrentAppInfo:nil];
    }
}

/**
 * Asks Trickplay for the most up-to-date information of apps it has available.
 * Trickplay replies with a JSON string of up-to-date apps. The method then
 * composes an NSArray of NSDictioanry Objects with information on each app
 * available to the user on the TV, each individual NSDictionary Object referring
 * to one app, and returns this NSArray to the caller. The method also sets
 * appsAvailable to this NSArray which is later used to populate the TableView.
 *
 * Returns the NSArray passed to appsAvailable or nil on error.
 */
- (NSArray *)fetchApps {
    NSLog(@"Fetching Apps");
    if (![appViewController hasConnection]) {
        return nil;
    }
    
    //grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", appViewController.socketManager.host, appViewController.socketManager.port];
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    self.appsAvailable = [JSONData yajl_JSON];
    NSLog(@"Recieved JSON array app data = %@", appsAvailable);
    if (!appsAvailable) {
        return nil;
    }
    
    return appsAvailable;
}

- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserDelegate>)theDelegate {
    NSLog(@"Fetching Apps");
    
    if (!theDelegate) {
        theDelegate = delegate;
    }
    
    fetchAppsDelegate = theDelegate;
    
    if (![appViewController hasConnection]) {
        self.appsAvailable = nil;
        [theDelegate didReceiveAvailableAppsInfo:nil];
        return;
    }
    
    if (fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
    }
    if (fetchAppsData) {
        [fetchAppsData release];
        fetchAppsData = nil;
    }
    
    
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", appViewController.socketManager.host, appViewController.socketManager.port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    fetchAppsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!fetchAppsConnection) {
        self.appsAvailable = nil;
        [theDelegate didReceiveAvailableAppsInfo:nil];
    }
}

#pragma mark -
#pragma mark NSURLConnection Handling

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    if (connection == fetchAppsConnection) {
        if (!fetchAppsData) {
            fetchAppsData = [[NSMutableData alloc] initWithCapacity:10000];
        }
        
        [fetchAppsData appendData:incrementalData];
    } else if (connection == currentAppInfoConnection) {
        if (!currentAppData) {
            currentAppData = [[NSMutableData alloc] initWithCapacity:10000];
        }
        
        [currentAppData appendData:incrementalData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == fetchAppsDelegate) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        self.appsAvailable = [fetchAppsData yajl_JSON];
        NSLog(@"Received JSON array app data = %@", appsAvailable);
        [fetchAppsDelegate didReceiveAvailableAppsInfo:appsAvailable];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        NSDictionary *currentAppInfo = [currentAppData yajl_JSON];
        self.currentAppName = (NSString *)[currentAppInfo objectForKey:@"name"];
        if ([currentAppName isEqualToString:@"Empty"]) {
            self.currentAppName = nil;
        }
        [currentAppDelegate didReceiveCurrentAppInfo:currentAppInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        self.appsAvailable = nil;
        [fetchAppsDelegate didReceiveAvailableAppsInfo:nil];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        [currentAppDelegate didReceiveCurrentAppInfo:nil];
    }
}

#pragma mark -
#pragma mark Launching App View

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(NSDictionary *)appInfo {
    dispatch_queue_t launchApp_queue = dispatch_queue_create("launchAppQueue", NULL);
    dispatch_async(launchApp_queue, ^(void){
        NSString *appID = (NSString *)[appInfo objectForKey:@"id"];
        NSString *launchString = [NSString stringWithFormat:@"http://%@:%d/api/launch?id=%@", appViewController.socketManager.host, appViewController.socketManager.port, appID];
        NSLog(@"Launching app via url '%@'", launchString);
        NSURL *launchURL = [NSURL URLWithString:launchString];
        NSData *launchData = [NSData dataWithContentsOfURL:launchURL];
        NSLog(@"launch data = %@", launchData);
        
        self.currentAppName = (NSString *)[appInfo objectForKey:@"name"];
    });
    dispatch_release(launchApp_queue);
}

@end
