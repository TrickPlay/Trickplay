//
//  Services_testAppDelegate.m
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Services_testAppDelegate.h"

@implementation Services_testAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize aTableView;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    netServiceManager = [[NetServiceManager alloc] init:aTableView delegate:self];
    
    aTableView.dataSource = self;
    
    [window addSubview:[navigationController view]];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)serviceResolved:(NSNetService *)service {
    if (gestureViewController == nil)
	{
		gestureViewController = [[GestureViewController alloc] initWithNibName:@"GestureViewController" bundle:nil];
	}
    
	[navigationController pushViewController:gestureViewController animated:YES];
	[[self navigationController] presentModalViewController:gestureViewController animated:YES];
	//self.title = @"Disconnect"; 
	
	[gestureViewController startService:[service port] hostname:[service hostName] thetitle:[service name]];
}



//------------------- TableViewDelegate Stuff -----------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/**
 * Customize the number of rows in the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSUInteger count = [netServiceManager.services count];
	if (count == 0) {
		return 1;
	}
    
	return count;
}


/**
 * Override to support row selection in the table view.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    fprintf(stderr, "Selected row %d\n", indexPath.row);
    
    NSMutableArray *services = netServiceManager.services;
    
    if ([services count] == 0) return;
    
	netServiceManager.currentService = [services objectAtIndex:indexPath.row];
	[netServiceManager.currentService setDelegate:netServiceManager];
    
	[netServiceManager.currentService resolveWithTimeout:0.0];
    
	
	NSIndexPath *indexPath2 = [tableView indexPathForSelectedRow];
	if (indexPath2 != nil)
	{
		[tableView deselectRowAtIndexPath:indexPath2 animated:YES];
	}
	
}


/**
 * Customize the appearance of table view cells.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *tableCellIdentifier = @"UITableViewCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}

    NSMutableArray *services = netServiceManager.services;
	NSUInteger count = [services count];
    
	if (count == 0) {
        // If there are no services and searchingForServicesString is set, show one row explaining that to the user.
        cell.textLabel.text = @"Searching for services...";
		//cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		cell.accessoryType = UITableViewCellAccessoryNone;
		// Make sure to get rid of the activity indicator that may be showing if we were resolving cell zero but
		// then got didRemoveService callbacks for all services (e.g. the network connection went down).
		if (cell.accessoryView)
			cell.accessoryView = nil;
		return cell;
	}
	
	// Set up the text for the cell
	NSNetService* service = [services objectAtIndex:indexPath.row];
	cell.textLabel.text = [service name];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
	
	return cell;
	
}


//--------------------- Other application stuff --------------



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [netServiceManager release];
    //[gestureViewController release];
    [navigationController release];
    [aTableView release];
    [window release];
    [super dealloc];
}


@end
