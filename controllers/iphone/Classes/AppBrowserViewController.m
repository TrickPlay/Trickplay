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
@synthesize delegate;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        appBrowser = [[AppBrowser alloc] init];
    }
    return self;
}

/**
 * Called by RootViewController after a service is resolved. Creates a
 * TPAppViewController and sends TPAppViewController the host and port
 * it will use for establishing the socket it will use for an initial
 * connection with Trickplay and communicating with Trickplay asynchronously.
 */
- (void)setupService:(NSUInteger)port
            hostName:(NSString *)hostName
         serviceName:(NSString *)serviceName {
        
    [appBrowser setupService:port hostName:hostName serviceName:serviceName];
}

#pragma mark -
#pragma mark View lifecycle

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

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark Retrieving App Info From Network

/**
 * Returns true if the AppBrowserViewController can confirm an app is running
 * on Trickplay by asking it over the network.
 */
- (BOOL)hasRunningApp {
    if (!appBrowser) {
        return NO;
    }
    /*
    if (![appViewController hasConnection]) {
        return NO;
    }
    */
    
    NSLog(@"\n\appBrowser: %@\n\n", appBrowser);
    return [appBrowser hasRunningApp];
}

/**
 * Asks Trickplay for the currently running app and any information pertaining
 * to this app assembled in a JSON string. The method takes this JSON string reply
 * and returns it as an NSDictionary or nil on error.
 */
- (NSDictionary *)getCurrentAppInfo {
    if (!appBrowser) {
        return nil;
    }
    /*
    if (![appViewController hasConnection]) {
        return nil;
    }
    */
    
    return [appBrowser getCurrentAppInfo];
}

- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)theDelegate {
    NSLog(@"Fetching Apps");
    
    if (!theDelegate) {
        theDelegate = delegate;
    }
    if (!appBrowser) {
        if (theDelegate) {
            [theDelegate didReceiveCurrentAppInfo:nil];
        }
        return;
    }
    /*
    if (![appViewController hasConnection]) {
        appBrowser.currentAppName = nil;
        if (theDelegate) {
            [theDelegate didReceiveCurrentAppInfo:nil];
        }
        return;
    }
    */
    
    [appBrowser getCurrentAppInfoWithDelegate:theDelegate];
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
    
    if (!appBrowser) {
        return nil;
    }
    /*
    if (![appViewController hasConnection]) {
        return nil;
    }
    */
    
    return [appBrowser fetchApps];
}

- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserDelegate>)theDelegate {
    NSLog(@"Fetching Apps");
    
    if (!theDelegate) {
        theDelegate = delegate;
    }
    
    if (!appBrowser) {
        if (theDelegate) {
            [theDelegate didReceiveAvailableAppsInfo:nil];
        }
        return;
    }
    
    /*
    if (![appViewController hasConnection]) {
        appBrowser.currentAppName = nil;
        if (theDelegate) {
            [theDelegate didReceiveAvailableAppsInfo:nil];
        }
        return;
    }
    */
    
    [appBrowser getAvailableAppsInfoWithDelegate:theDelegate];
}

- (void)didReceiveAvailableAppsInfo:(NSArray *)info {
    if (delegate) {
        [delegate didReceiveAvailableAppsInfo:info];
    }
}
- (void)didReceiveCurrentAppInfo:(NSDictionary *)info {
    if (delegate) {
        [delegate didReceiveCurrentAppInfo:info];
    }
}

#pragma mark -
#pragma mark Launching App View

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(NSDictionary *)appInfo {
    if (!appBrowser) {
        return;
    }
    
    [appBrowser launchApp:appInfo];
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
	if (!appBrowser || !appBrowser.appsAvailable || [appBrowser.appsAvailable count] == 0) {
        return 1;
    }
    return [appBrowser.appsAvailable count];
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

    if (!appBrowser.appsAvailable || [appBrowser.appsAvailable count] == 0) {
        cell.textLabel.text = @"Loading Data...";
        cell.accessoryView = loadingSpinner;
        [loadingSpinner startAnimating];
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    cell.userInteractionEnabled = YES;
    
    [loadingSpinner stopAnimating];
    [loadingSpinner removeFromSuperview];
    cell.accessoryView = nil;
    
    cell.textLabel.text = (NSString *)[(NSDictionary *)[appBrowser.appsAvailable objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.textColor = [UIColor blackColor];
    if (appBrowser.currentAppName && [cell.textLabel.text compare:appBrowser.currentAppName] == NSOrderedSame) {
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
        
    if (!appBrowser.appsAvailable || [appBrowser.appsAvailable count] == 0) {// TODO: || pushingViewController) {
        // just don't do anything
    } else if (!appBrowser.currentAppName || [(NSString *)[(NSDictionary *)[appBrowser.appsAvailable objectAtIndex:indexPath.row] objectForKey:@"name"] compare:appBrowser.currentAppName] !=  NSOrderedSame) {
        
        [self launchApp:(NSDictionary *)[appBrowser.appsAvailable objectAtIndex:indexPath.row]];
        [delegate didSelectAppWithInfo:(NSDictionary *)[appBrowser.appsAvailable objectAtIndex:indexPath.row] isCurrentApp:NO];
    } else {
        [delegate didSelectAppWithInfo:(NSDictionary *)[appBrowser.appsAvailable objectAtIndex:indexPath.row] isCurrentApp:YES];
    }
    
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
    if (currentAppIndicator) {
        [currentAppIndicator release];
    }
    appBrowser.delegate = nil;
    [appBrowser release];
    appBrowser = nil;
    
    [super dealloc];
}


@end
