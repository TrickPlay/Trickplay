//
//  AppBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowser.h"
#import "AppBrowserViewController.h"
#import "TVConnection.h"
#import "JSONKit.h"
#import "Extensions.h"



@implementation AppInfo

@synthesize name;
@synthesize appID;
@synthesize version;
@synthesize releaseNumber;

- (id)init {
    return [self initWithAppDictionary:nil];
}

- (id)initWithAppDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        name = [(NSString *)[dictionary objectForKey:@"name"] retain];
        appID = [(NSString *)[dictionary objectForKey:@"id"] retain];
        version = [(NSString *)[dictionary objectForKey:@"version"] retain];
        releaseNumber = [(NSString *)[dictionary objectForKey:@"release"] retain];
    }
    
    return self;
}

- (BOOL)equals:(AppInfo *)appInfo {
    return ([self.name compare:appInfo.name] == NSOrderedSame) && ([self.appID compare:appInfo.appID] == NSOrderedSame) && ([self.version compare:appInfo.version] == NSOrderedSame) && ([self.releaseNumber compare:appInfo.releaseNumber] == NSOrderedSame);
}

- (void)dealloc {
    NSLog(@"AppInfo Dealloc");
    
    [name release];
    name = nil;
    [appID release];
    appID = nil;
    [version release];
    version = nil;
    [releaseNumber release];
    releaseNumber = nil;
    
    [super dealloc];
}

@end




@interface AppBrowserContext : AppBrowser {
    
@private
    /// Truly private properties
    NSMutableArray *viewControllers;
    
    // Asynchronous URL connections for populating the table with
    // available apps and fetching information on the current
    // running app
    NSURLConnection *fetchAppsConnection;
    NSURLConnection *currentAppInfoConnection;
    
    // The data buffers for the connections
    NSMutableData *fetchAppsData;
    NSMutableData *currentAppData;
    
    //// Publicly exposed properties:
    TVConnection *tvConnection;
    // The available apps on the TV
    NSMutableArray *availableApps;
    // The current app running on Trickplay
    AppInfo *currentApp;
    
    id <AppBrowserDelegate> delegate;
}

- (void)addViewController:(AppBrowserViewController *)viewController;
- (void)invalidateViewController:(AppBrowserViewController *)viewController;
- (void)viewControllersRefresh;

- (void)informOfCurrentApp:(AppInfo *)app;
- (void)informOfAvailableApps:(NSArray *)apps;

@end



@implementation AppBrowserContext

//@synthesize availableApps;
//@synthesize currentApp;
//@synthesize tvConnection;
//@synthesize delegate;

#pragma mark -
#pragma Setters/Getters

- (TVConnection *)tvConnection {
    TVConnection *retval = nil;
    @synchronized(self) {
        retval = [[tvConnection retain] autorelease];
    }
    return retval;
}

- (void)setTvConnection:(TVConnection *)_tvConnection {
    @synchronized(self) {
        [_tvConnection retain];
        [tvConnection release];
        tvConnection = _tvConnection;
    }
}

- (AppInfo *)currentApp {
    AppInfo *retval = nil;
    @synchronized(self) {
        retval = [[currentApp retain] autorelease];
    }
    return retval;
}

// hidden method prototype
- (void)setCurrentApp:(AppInfo *)_currentApp {
    @synchronized (self) {
        [_currentApp retain];
        [currentApp release];
        currentApp = _currentApp;
    }
}

- (NSArray *)availableApps {
    NSArray *retval = nil;
    @synchronized(self) {
        retval = [[availableApps retain] autorelease];
    }
    return retval;
}

// hidden method prototype
- (void)setAvailableApps:(NSMutableArray *)_availableApps {
    @synchronized (self) {
        [_availableApps retain];
        [availableApps release];
        availableApps = _availableApps;
    }
}

- (id <AppBrowserDelegate>)delegate {
    id <AppBrowserDelegate> val = nil;
    @synchronized(self) {
        val = delegate;
    }
    return val;
}

- (void)setDelegate:(id <AppBrowserDelegate>)_delegate {
    @synchronized(self) {
        delegate = _delegate;
    }
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithTVConnection:nil delegate:nil];
}

- (id)initWithTVConnection:(TVConnection *)_connection delegate:(id<AppBrowserDelegate>)_delegate {
    
    self = [super init];
    if (self) {
        
        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        
        self.tvConnection = _connection;
        [self.tvConnection setAppBrowser:self];
        
        availableApps = [[NSMutableArray alloc] initWithCapacity:10];
        currentApp = nil;
        
        // Asynchronous URL connections for populating the table with
        // available apps and fetching information on the current
        // running app
        fetchAppsConnection = nil;
        currentAppInfoConnection = nil;
        
        // The data buffers for the connections
        fetchAppsData = nil;
        currentAppData = nil;
        
        self.delegate = _delegate;
        
        //*
        // Can't do this automatically for now
        if (self.delegate) {
            [self refreshCurrentApp];
            [self refreshAvailableApps];
        }
        //*/
    }
    
    return self;
}

#pragma mark -
#pragma mark AppBrowserViewController

- (AppBrowserViewController *)getNewAppBrowserViewController {
    NSBundle *myBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/TakeControl.framework"]];
    
    AppBrowserViewController *viewController = [[[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:myBundle appBrowser:self] autorelease];
    
    return viewController;
}

- (void)addViewController:(AppBrowserViewController *)viewController {
    [viewControllers addObject:[NSValue valueWithPointer:viewController]];
}

- (void)invalidateViewController:(AppBrowserViewController *)viewController {
    NSUInteger i;
    for (i = 0; i < viewControllers.count; i++) {
        AppBrowserViewController *_viewController = [[viewControllers objectAtIndex:i] pointerValue];
        if (viewController == _viewController) {
            break;
        }
    }
    
    if (viewControllers.count > i && viewController == [[viewControllers objectAtIndex:i] pointerValue]) {
        [viewControllers removeObjectAtIndex:i];
    } else {
        NSLog(@"WARNING: invalidated an AppBrowserViewController that was not registered");
    }
}

- (void)viewControllersRefresh {
    for (unsigned int i = 0; i < viewControllers.count; i++) {
        AppBrowserViewController *viewController = [[viewControllers objectAtIndex:i] pointerValue];
        
        [viewController.tableView reloadData];
    }
}

#pragma mark -
#pragma Retrieving App Info from Network

- (void)refresh {
    [self refreshAvailableApps];
    [self refreshCurrentApp];
}

- (void)matchCurrentAppToAvailableApps {
    if (currentApp && availableApps) {
        for (AppInfo *app in availableApps) {
            if ([currentApp.name compare:app.name] == NSOrderedSame) {
                self.currentApp = app;
                break;
            }
        }
    }
}

// TODO: if either currentapp or availableApps have no match this
// could cause problems
- (void)matchAvailableAppsToCurrentApp {
    if (currentApp && availableApps) {
        NSUInteger i;
        for (i = 0; i < availableApps.count; i++) {
            AppInfo *app = [availableApps objectAtIndex:i];
            if ([currentApp.name compare:app.name] == NSOrderedSame) {
                break;
            }
        }
        
        if (availableApps.count > i && currentApp.name == ((AppInfo *)[availableApps objectAtIndex:i]).name) {
            [availableApps replaceObjectAtIndex:i withObject:currentApp];
        }
    }
}

- (void)informOfCurrentApp:(AppInfo *)app {
    @synchronized (self) {
        self.currentApp = app;
        if ([[self.currentApp name] isEqualToString:@"Empty"]) {
            self.currentApp = nil;
        }
        
        [self matchCurrentAppToAvailableApps];
    }
    NSLog(@"current app: %@", self.currentApp);
    [delegate appBrowser:self didReceiveCurrentApp:self.currentApp];
    [self viewControllersRefresh];
}

- (void)informOfAvailableApps:(NSArray *)apps {
    @synchronized (self) {
        [availableApps removeAllObjects];
        if (apps) {
            for (NSUInteger i = 0; i < apps.count; i++) {
                [availableApps addObject:[[[AppInfo alloc] initWithAppDictionary:[apps objectAtIndex:i]] autorelease]];
            }
        }
        [self matchAvailableAppsToCurrentApp];
    }
    [delegate appBrowser:self didReceiveAvailableApps:self.availableApps];
    [self viewControllersRefresh];
}

- (void)refreshCurrentApp {
    NSLog(@"Fetching Current App");
    
    if (!self.tvConnection || !self.tvConnection.hostName) {
        self.currentApp = nil;
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", self.tvConnection.hostName, self.tvConnection.http_port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    currentAppInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!currentAppInfoConnection) {
        [self performSelectorOnMainThread:@selector(informOfCurrentApp:) withObject:nil waitUntilDone:NO];
    }
}

- (void)refreshAvailableApps {
    NSLog(@"Fetching Available Apps");
    
    if (!self.tvConnection || !self.tvConnection.hostName) {
        [(NSMutableArray *)self.availableApps removeAllObjects];
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", self.tvConnection.hostName, self.tvConnection.http_port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    fetchAppsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!fetchAppsConnection) {
        [self performSelectorOnMainThread:@selector(informOfAvailableApps:) withObject:nil waitUntilDone:NO];
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
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        JSONDecoder *decoder = [JSONDecoder decoder];
        NSMutableArray *apps = [decoder mutableObjectWithData:fetchAppsData];
        NSLog(@"Received JSON array available apps = %@", apps);
        
        [self informOfAvailableApps:apps];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        JSONDecoder *decoder = [JSONDecoder decoder];
        NSLog(@"Current app: %@", [decoder objectWithData:currentAppData]);
        AppInfo *app = [[[AppInfo alloc] initWithAppDictionary:[decoder objectWithData:currentAppData]] autorelease];
        
        [self informOfCurrentApp:app];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        if (error) {
            NSLog(@"Did fail fetching available apps with error: %@", error);
        }
        [self informOfAvailableApps:nil];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        if (error) {
            NSLog(@"Did fail fetching current app with error: %@", error);
        }
        [self informOfCurrentApp:nil];
    }
}

- (void)cancelRefresh {
    if (fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
    }
    if (currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
    }
    if (fetchAppsData) {
        [fetchAppsData release];
        fetchAppsData = nil;
    }
    if (currentAppData) {
        [currentAppData release];
        currentAppData = nil;
    }
}

#pragma mark -
#pragma mark Launching App

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(AppInfo *)app {
    if (!tvConnection || !tvConnection.hostName || !app || ![app isKindOfClass:[AppInfo class]] || !availableApps || ![availableApps containsObject:app]) {
        return;
    }
    
    NSString *launchString = [NSString stringWithFormat:@"http://%@:%d/api/launch?id=%@", tvConnection.hostName, tvConnection.http_port, app.appID];
    dispatch_queue_t launchApp_queue = dispatch_queue_create("launchAppQueue", NULL);
    dispatch_async(launchApp_queue, ^(void) {
        
        NSLog(@"Launching app via url '%@'", launchString);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:launchString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSHTTPURLResponse *response;
        NSData *launchData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
        // Failure to launch
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate appBrowser:self newAppLaunched:app successfully:NO];
                [self viewControllersRefresh];
            });
        } else {  // Successful launch
            self.currentApp = app;
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate appBrowser:self newAppLaunched:app successfully:YES];
                [self viewControllersRefresh];
            });
        }
    });
    dispatch_release(launchApp_queue);
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"AppBrowser dealloc");
    
    [viewControllers release];
    
    [self.tvConnection setAppBrowser:nil];
    self.tvConnection = nil;
    
    [self cancelRefresh];
    
    self.currentApp = nil;
    self.availableApps = nil;
    
    delegate = nil;
    
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



@implementation AppBrowser

#pragma mark -
#pragma mark Allocation

+ (id)alloc {
    if ([self isEqual:[AppBrowser class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [AppBrowserContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[AppBrowser class]]) {
        return [AppBrowserContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTVConnection:(TVConnection *)_connection delegate:(id<AppBrowserDelegate>)_delegate {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark -
#pragma Setters/Getters

- (void)setCurrentApp:(AppInfo *)_currentApp {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setAvailableApps:(NSMutableArray *)_availableApps {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray *)availableApps {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (AppInfo *)currentApp {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTvConnection:(TVConnection *)tvConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (TVConnection *)tvConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id <AppBrowserDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <AppBrowserDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark AppBrowserViewController

- (AppBrowserViewController *)getNewAppBrowserViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)addViewController:(AppBrowserViewController *)viewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)invalidateViewController:(AppBrowserViewController *)viewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)viewControllersRefresh {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Retrieving App Info From Network

- (void)refresh {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)refreshCurrentApp {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)refreshAvailableApps {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Launching App

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(AppInfo *)app {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Deallocation

- (void)cancelRefresh {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/*
- (void)dealloc {
    NSLog(@"AppBrowser Dealloc");
    
    [super dealloc];
}
*/

@end
