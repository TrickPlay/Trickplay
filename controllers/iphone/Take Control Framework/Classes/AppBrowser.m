//
//  AppBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowser.h"
#import "AppBrowserViewController.h"
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
        version = [(NSNumber *)[dictionary objectForKey:@"version"] retain];
        releaseNumber = [(NSNumber *)[dictionary objectForKey:@"release"] retain];
    }
    
    return self;
}

- (void)dealloc {
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




@interface AppBrowserContext : NSObject {
    
@private
    AppBrowser *appBrowser;
    NSMutableArray *viewControllers;
    
    TVConnection *tvConnection;
    // The available apps on the TV
    NSMutableArray *availableApps;
    // The current app running on Trickplay
    AppInfo *currentApp;
    
    // Asynchronous URL connections for populating the table with
    // available apps and fetching information on the current
    // running app
    NSURLConnection *fetchAppsConnection;
    NSURLConnection *currentAppInfoConnection;
    
    // The data buffers for the connections
    NSMutableData *fetchAppsData;
    NSMutableData *currentAppData;
}

@property (retain) NSArray *availableApps;
@property (retain) AppInfo *currentApp;
@property (retain) TVConnection *tvConnection;

- (id)initWithAppBrowser:(AppBrowser *)appBrowser tvConnection:(TVConnection *)connection;

- (void)addViewController:(AppBrowserViewController *)viewController;
- (void)invalidateViewController:(AppBrowserViewController *)viewController;
- (void)viewControllersRefresh;

- (void)informOfCurrentApp:(AppInfo *)app;
- (void)informOfAvailableApps:(NSArray *)apps;
- (void)refreshCurrentApp;
- (void)refreshAvailableApps;
- (void)cancelRefresh;

@end



@implementation AppBrowserContext

@synthesize availableApps;
@synthesize currentApp;
@synthesize tvConnection;

- (id)init {
    return [self initWithAppBrowser:nil tvConnection:nil];
}

- (id)initWithAppBrowser:(AppBrowser *)_appBrowser tvConnection:(TVConnection *)_connection {
    if (!_appBrowser) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        appBrowser = _appBrowser;
        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        
        self.tvConnection = _connection;
        [self.tvConnection setAppBrowser:appBrowser];
        
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
    }
    
    return self;
}

#pragma mark -
#pragma mark AppBrowserViewController

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
    
    if (viewController == [[viewControllers objectAtIndex:i] pointerValue]) {
        [viewControllers removeObjectAtIndex:i];
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
        
        if (currentApp.name == ((AppInfo *)[availableApps objectAtIndex:i]).name) {
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
    [appBrowser.delegate appBrowser:appBrowser didReceiveCurrentApp:self.currentApp];
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
    [appBrowser.delegate appBrowser:appBrowser didReceiveAvailableApps:self.availableApps];
    [self viewControllersRefresh];
}

- (void)refreshCurrentApp {
    NSLog(@"Fetching Current App");
    
    if (!appBrowser.tvConnection || !appBrowser.tvConnection.hostName) {
        appBrowser.currentApp = nil;
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", appBrowser.tvConnection.hostName, appBrowser.tvConnection.http_port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    currentAppInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!currentAppInfoConnection) {
        [self performSelectorOnMainThread:@selector(informOfCurrentApp:) withObject:nil waitUntilDone:NO];
    }
}

- (void)refreshAvailableApps {
    NSLog(@"Fetching Available Apps");
    
    if (!appBrowser.tvConnection || !appBrowser.tvConnection.hostName) {
        [(NSMutableArray *)appBrowser.availableApps removeAllObjects];
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", appBrowser.tvConnection.hostName, appBrowser.tvConnection.http_port];
    
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
        
        NSMutableArray *apps = [fetchAppsData yajl_JSON];
        NSLog(@"Received JSON array available apps = %@", apps);
        
        [self informOfAvailableApps:apps];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        NSLog(@"Current app: %@", [currentAppData yajl_JSON]);
        AppInfo *app = [[[AppInfo alloc] initWithAppDictionary:[currentAppData yajl_JSON]] autorelease];
        
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
    if (!tvConnection || !tvConnection.hostName || !app || ![app isKindOfClass:[AppBrowser class]]) {
        return;
    }
    
    NSString *launchString = [NSString stringWithFormat:@"http://%@:%d/api/launch?id=%@", tvConnection.hostName, tvConnection.http_port, app.appID];
    dispatch_queue_t launchApp_queue = dispatch_queue_create("launchAppQueue", NULL);
    dispatch_async(launchApp_queue, ^(void){
        
        NSLog(@"Launching app via url '%@'", launchString);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:launchString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSHTTPURLResponse *response;
        NSData *launchData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        NSLog(@"launch data = %@", launchData);
        
        // Failure to launch
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [appBrowser.delegate appBrowser:appBrowser newAppLaunched:app successfully:NO];
                [self viewControllersRefresh];
            });
        } else {  // Successful launch
            self.currentApp = app;
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [appBrowser.delegate appBrowser:appBrowser newAppLaunched:app successfully:YES];
                [self viewControllersRefresh];
            });
        }
    });
    dispatch_release(launchApp_queue);
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    [viewControllers release];
    
    [self.tvConnection setAppBrowser:nil];
    self.tvConnection = nil;
    
    [self cancelRefresh];
    
    self.currentApp = nil;
    self.availableApps = nil;
    
    appBrowser = nil;
    
    [super dealloc];
}

@end





@implementation AppBrowser

@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    return [self initWithConnection:nil delegate:nil];
}

- (id)initWithDelegate:(id <AppBrowserDelegate>)_delegate {
    return [self initWithConnection:nil delegate:_delegate];
}

- (id)initWithConnection:(TVConnection *)_connection delegate:(id<AppBrowserDelegate>)_delegate {
    
    self = [super init];
    if (self) {
        context = [[AppBrowserContext alloc] initWithAppBrowser:self tvConnection:_connection];
        if (!context) {
            [self release];
            return nil;
        }
        
        self.delegate = _delegate;
        
        /**
        // Can't do this automatically for now
        if (self.delegate) {
            [self refreshCurrentApp];
            [self refreshAvailableApps];
        }
        **/
    }
    
    return self;
}


#pragma mark -
#pragma Setters/Getters

- (void)setCurrentApp:(AppInfo *)_currentApp {
    ((AppBrowserContext *)context).currentApp = _currentApp;
}

- (void)setAvailableApps:(NSMutableArray *)_availableApps {
    ((AppBrowserContext *)context).availableApps = _availableApps;
}

- (NSArray *)availableApps {
    return ((AppBrowserContext *)context).availableApps;
}

- (AppInfo *)currentApp {
    return ((AppBrowserContext *)context).currentApp;
}

- (void)setTvConnection:(TVConnection *)tvConnection {
    ((AppBrowserContext *)context).tvConnection = tvConnection;
}

- (TVConnection *)tvConnection {
    return ((AppBrowserContext *)context).tvConnection;
}

#pragma mark -
#pragma mark AppBrowserViewController

- (AppBrowserViewController *)createAppBrowserViewController {
    AppBrowserViewController *viewController = [[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:nil appBrowser:self];
    
    return viewController;
}

- (void)addViewController:(AppBrowserViewController *)viewController {
    [((AppBrowserContext *)context) addViewController:viewController];
}

- (void)invalidateViewController:(AppBrowserViewController *)viewController {
    [((AppBrowserContext *)context) invalidateViewController:viewController];
}

- (void)viewControllersRefresh {
    [((AppBrowserContext *)context) viewControllersRefresh];
}

#pragma mark -
#pragma mark Retrieving App Info From Network

- (void)refresh {
    [self refreshAvailableApps];
    [self refreshCurrentApp];
}

- (void)refreshCurrentApp {
    [((AppBrowserContext *)context) refreshCurrentApp];
}

- (void)refreshAvailableApps {
    [((AppBrowserContext *)context) refreshAvailableApps];
}

#pragma mark -
#pragma mark Launching App

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(AppInfo *)app {
    [(AppBrowserContext *)context launchApp:app];
}

#pragma mark -
#pragma mark Deallocation

- (void)cancelRefresh {
    [((AppBrowserContext *)context) cancelRefresh];
}

- (void)dealloc {
    NSLog(@"AppBrowser Dealloc");
    
    self.delegate = nil;
    
    [self cancelRefresh];
    
    [context release];
    context = nil;
        
    [super dealloc];
}

@end
