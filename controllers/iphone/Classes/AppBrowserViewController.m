//
//  AppBrowserViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowserViewController.h"


@implementation AppBrowserViewController

@synthesize theTableView;
@synthesize appsAvailable;
@synthesize currentAppName;
@synthesize pushingViewController;
@synthesize socketDelegate;

/*
@synthesize appShopButton;
@synthesize showcaseButton;
@synthesize toolBar;
*/
 

- (IBAction)showcaseButtonClick {
}

- (IBAction)appShopButtonClick {
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/**
 * Called by RootViewController after a service is resolved. Creates a
 * GestureViewController and sends GestureViewController the host and port
 * it will use for establishing the socket it will use for an initial
 * connection with Trickplay and communicating with Trickplay asynchronously.
 */
- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n {
    
    NSLog(@"AppBrowser Service Setup: %@ host: %@ port: %d", n, h, p);
    
    viewDidAppear = NO;
    
    [self createGestureViewWithPort:p hostName:h];
}

/**
 * Pushes the GestureViewController to the top of the navigation stack making it
 * the visible view controller.
 */
- (void)pushApp {
    pushingViewController = YES;

    if (self.navigationController.visibleViewController != self) {
        [self.navigationController pushViewController:self animated:NO];
    }
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Apps List" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    
    [self.navigationController pushViewController:gestureViewController animated:YES];
}

#pragma mark -
#pragma mark Retrieving App Info From Network

/**
 * Returns true if the AppBrowserViewController can confirm an app is running
 * on Trickplay by asking it over the network.
 */
- (BOOL)hasRunningApp {
    if (![gestureViewController hasConnection]) {
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
 *
 * TODO: might want to make this call asynchronous and add a time-to-live, otherwise
 * future changes to TakeControl could lead to deadlock scenerios since AdvancedUI
 * is synchronous.
 */
- (NSDictionary *)getCurrentAppInfo {
    NSLog(@"Getting Current App Info");
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", gestureViewController.socketManager.host, gestureViewController.socketManager.port];
    //NSLog(@"JSONString = %@", JSONString);
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    //NSLog(@"Received JSONData = %@", [NSString stringWithCharacters:[JSONData bytes] length:[JSONData length]]);
    //NSArray *JSONArray = [JSONData yajl_JSON];
    return (NSDictionary *)[JSONData yajl_JSON];
}

- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)delegate {
    NSLog(@"Fetching Apps");
    currentAppDelegate = delegate;
    
    if (![gestureViewController hasConnection]) {
        self.currentAppName = nil;
        [delegate didRecieveCurrentAppInfo:nil];
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", gestureViewController.socketManager.host, gestureViewController.socketManager.port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    currentAppInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!currentAppInfoConnection) {
        self.currentAppName = nil;
        [delegate didRecieveCurrentAppInfo:nil];
    }
}

/**
 * Asks Trickplay for the most up-to-date information of apps it has available.
 * Trickplay replies with a JSON string of up-to-date apps. The method then
 * composes an NSDictionary with this information and sets appsAvailable to
 * this Dictionary which will later populate the TableView.
 *
 * TODO: might want to make this call asynchronous and add a time-to-live, otherwise
 * future changes to TakeControl could lead to deadlock scenerios since AdvancedUI
 * is synchronous.
 */
- (BOOL)fetchApps {
    NSLog(@"Fetching Apps");
    if (![gestureViewController hasConnection]) {
        return NO;
    }
    
    //grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", gestureViewController.socketManager.host, gestureViewController.socketManager.port];
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    self.appsAvailable = [JSONData yajl_JSON];
    NSLog(@"Recieved JSON array app data = %@", appsAvailable);
    if (!appsAvailable) {
        return NO;
    }
    
    return YES;
}

- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserDelegate>)delegate {
    NSLog(@"Fetching Apps");
    fetchAppsDelegate = delegate;
    
    if (![gestureViewController hasConnection]) {
        self.appsAvailable = nil;
        [delegate didRecieveAvailableAppsInfo:nil];
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
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", gestureViewController.socketManager.host, gestureViewController.socketManager.port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    fetchAppsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!fetchAppsConnection) {
        self.appsAvailable = nil;
        [delegate didRecieveAvailableAppsInfo:nil];
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
        [fetchAppsDelegate didRecieveAvailableAppsInfo:appsAvailable];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        NSDictionary *currentAppInfo = [currentAppData yajl_JSON];
        self.currentAppName = (NSString *)[currentAppInfo objectForKey:@"name"];
        if ([currentAppName isEqualToString:@"Empty"]) {
            self.currentAppName = nil;
        }
        [currentAppDelegate didRecieveCurrentAppInfo:currentAppInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        self.appsAvailable = nil;
        [fetchAppsDelegate didRecieveAvailableAppsInfo:nil];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        [currentAppDelegate didRecieveCurrentAppInfo:nil];
    }
}

#pragma mark -
#pragma mark Launching App View

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(NSDictionary *)appInfo {
    NSString *appID = (NSString *)[appInfo objectForKey:@"id"];
    NSString *launchString = [NSString stringWithFormat:@"http://%@:%d/api/launch?id=%@", gestureViewController.socketManager.host, gestureViewController.socketManager.port, appID];
    NSLog(@"Launching app via url '%@'", launchString);
    NSURL *launchURL = [NSURL URLWithString:launchString];
    NSData *launchData = [NSData dataWithContentsOfURL:launchURL];
    NSLog(@"launch data = %@", launchData);
    
    self.currentAppName = (NSString *)[appInfo objectForKey:@"name"];
}

/**
 * Creates the GestureViewController, gives it a port and host name to establish
 * a connection to a service, and tells it to establish this connection.
 */
- (void)createGestureViewWithPort:(NSInteger)port hostName:(NSString *)hostName {
    gestureViewController = [[GestureViewController alloc] initWithNibName:@"GestureViewController" bundle:nil];
    
    gestureViewController.socketDelegate = self;
    
    CGFloat
    x = self.view.frame.origin.x,
    y = self.view.frame.origin.y,
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    gestureViewController.view.frame = CGRectMake(x, y, width, height);
    [gestureViewController setupService:port hostname:hostName thetitle:@"Current Service"];
    if (![gestureViewController startService]) {
        [gestureViewController release];
        gestureViewController = nil;
    }
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"AppBrowserView Loaded!");
    // Initialize the orange indicator for the current running app
    if (!currentAppIndicator) {
        currentAppIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 20.0)];
        currentAppIndicator.backgroundColor = [UIColor colorWithRed:1.0 green:168.0/255.0 blue:18.0/255.0 alpha:1.0];
        currentAppIndicator.layer.borderWidth = 3.0;
        currentAppIndicator.layer.borderColor = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0].CGColor;
        currentAppIndicator.layer.cornerRadius = currentAppIndicator.frame.size.height/2.0;
    }
    
    // Initialize the loadingSpinner if it does not exist
    if (!loadingSpinner) {
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    // Set the delegate for the table which holds the app info
    [theTableView setDelegate:self];
}
//*/

- (void)viewDidAppear:(BOOL)animated {
    if (self.navigationController.visibleViewController == self && (!gestureViewController || !gestureViewController.socketManager)) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    viewDidAppear = YES;
    pushingViewController = NO;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark GestureViewControllerSocketDelegate stuff

/**
 * Called when a socket error occurs.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in AppBrowser");

    if (socketDelegate) {
        [socketDelegate socketErrorOccurred];
    }
}

/**
 * Called when a socket closes.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in AppBrowser");
    
    if (socketDelegate) {
        [socketDelegate streamEndEncountered];
    }
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/**
 * Customize the number of rows in the table view. The number of rows is equlivalent
 * to the number of apps available. If Trickplay has no apps then one row is
 * still created which will be populated with a string informing the user there
 * are no available apps.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!appsAvailable || [appsAvailable count] == 0) {
        return 1;
    }
    return [appsAvailable count];
}

/**
 * Customize the appearance of table view cells. Each cell will contain the name
 * of an app available on Trickplay. Selecting an app will launch the app on
 * Trickplay.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableCellIdentifier = @"UITableViewCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}

    if (!appsAvailable || [appsAvailable count] == 0) {
        cell.textLabel.text = @"Loading Data...";
        cell.accessoryView = loadingSpinner;
        [loadingSpinner startAnimating];
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    [loadingSpinner stopAnimating];
    [loadingSpinner removeFromSuperview];
    cell.accessoryView = nil;
    
    cell.textLabel.text = (NSString *)[(NSDictionary *)[appsAvailable objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.textColor = [UIColor blackColor];
    if (currentAppName && [cell.textLabel.text compare:currentAppName] == NSOrderedSame) {
        [cell addSubview:currentAppIndicator];
        cell.textLabel.text = [NSString stringWithFormat:@"     %@", cell.textLabel.text];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

/**
 * Override to support row selection in the table view. Selecting a row tells
 * Trickplay to launch the app populated by that row.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected row %@\n", indexPath);
    
    if (!appsAvailable || [appsAvailable count] == 0 || pushingViewController) {
        return;
    }
    
    if (!currentAppName || [(NSString *)[(NSDictionary *)[appsAvailable objectAtIndex:indexPath.row] objectForKey:@"name"] compare:currentAppName] !=  NSOrderedSame) {
        [gestureViewController clean];
        [self launchApp:(NSDictionary *)[appsAvailable objectAtIndex:indexPath.row]];
    }
    
    [self pushApp];   
    
	NSIndexPath *indexPath2 = [tableView indexPathForSelectedRow];
	if (indexPath2 != nil)
	{
		[tableView deselectRowAtIndexPath:indexPath2 animated:YES];
	}
	
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    NSLog(@"AppBrowserController Unload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (theTableView) {
        [theTableView release];
        theTableView = nil;
    }
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
}


- (void)dealloc {
    NSLog(@"AppBrowserViewController dealloc");
    if (theTableView) {
        [theTableView release];
        theTableView = nil;
    }
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
    if (appsAvailable) {
        [appsAvailable release];
    }
    if (gestureViewController) {
        gestureViewController.socketDelegate = nil;
        [gestureViewController release];
        gestureViewController = nil;
    }
    if (currentAppName) {
        [currentAppName release];
    }
    if (currentAppIndicator) {
        [currentAppIndicator release];
    }
    socketDelegate = nil;
    
    [super dealloc];
}


@end
