//
//  RootViewController.m
//  TrickplayRemote
//
//  Created by Kenny Ham on 1/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"

#import "AppDelegate.h"

@implementation RootViewController


@synthesize currentResolve;
@synthesize netServiceBrowser;
@synthesize services;
@synthesize gestureViewController;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Remote Services";
	self.view.tag = 1;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	NSNetServiceBrowser *aNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!aNetServiceBrowser) {
        // The NSNetServiceBrowser couldn't be allocated and initialized.
		return;
	}
	self.services = [[NSMutableArray alloc] init];
    self.navigationController.delegate = self;
	aNetServiceBrowser.delegate = self;
	self.netServiceBrowser = aNetServiceBrowser;
	[aNetServiceBrowser release];
	[self.netServiceBrowser searchForServicesOfType:@"_tp-remote._tcp" inDomain:@""];
	//For my personal one I need to use this:
	//_http._tcp:local
	//[self.netServiceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@""];
	
	
	[self.tableView reloadData];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSUInteger count = [self.services count];
	if (count == 0 )
		return 1;
	
	return count;
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableCellIdentifier = @"UITableViewCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier] autorelease];
	}
	
	NSUInteger count = [self.services count];
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
	NSNetService* service = [self.services objectAtIndex:indexPath.row];
	cell.textLabel.text = [service name];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
	
	return cell;
	
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.services count] == 0) return;
    
	self.currentResolve = [self.services objectAtIndex:indexPath.row];
	[self.currentResolve setDelegate:self];
	if (gestureViewController == nil)
	{
		gestureViewController = [[GestureView alloc] initWithNibName:@"GestureView" bundle:nil];
	}
		
	[self.currentResolve resolveWithTimeout:0.0];
	
	NSIndexPath *indexPath2 = [tableView indexPathForSelectedRow];
	if (indexPath2 != nil)
	{
		[tableView deselectRowAtIndexPath:indexPath2 animated:YES];
	}
	
}


- (void)stopCurrentResolve {
	//self.needsActivityIndicator = NO;
	//self.timer = nil;
	
	[self.currentResolve stop];
	self.currentResolve = nil;
}


//--------------  NSNetServiceBrowser delegate methods  -----------------------------------------------
- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
	// If a service went away, stop resolving it if it's currently being resolved,
	// remove it from the list and update the table view if no more events are queued.
	if (self.currentResolve && [service isEqual:self.currentResolve]) {
		[self stopCurrentResolve];
	}
	[self.services removeObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
	if (!moreComing) {
		[self.tableView reloadData];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	// If a service came online, add it to the list and update the table view if no more events are queued.
	[self.services addObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
	if (!moreComing) {
		[self.tableView reloadData];
	}
}	


// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	[self stopCurrentResolve];
	[self.tableView reloadData];
}


- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == self.currentResolve);
	
	[service retain];
	[self stopCurrentResolve];
	
	//[self.delegate browserViewController:self didResolveInstance:service];
	
	
	NSInteger theport = [service port];
	NSLog(@"Did resolve address");
	
	[gestureViewController setTheParent:self];
	[self.navigationController pushViewController:gestureViewController animated:YES];
	//[[self navigationController] presentModalViewController:gestureViewController animated:YES];
	self.title = @"Disconnect"; 
	
	[gestureViewController setupService:theport hostname:[service hostName] thetitle:[service name]];
	
	[service release];
	
	//Socket examples:
	//http://www.iphonedevsdk.com/forum/iphone-sdk-development/2998-how-socket-connection.html
	//http://www.mobileorchard.com/tutorial-networking-and-bonjour-on-iphone/
	//http://stackoverflow.com/questions/1083017/iphone-socket-program
	//http://code.google.com/p/cocoaasyncsocket/
}

- (void)removeTheChildview
{
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSLog([NSString stringWithFormat:@"navcontroller tag=%d",viewController.view.tag] );
	if (viewController.view.tag == 1)
	{
		if (gestureViewController != nil)
		{
			[gestureViewController removeServiceFromCollection];
		}
		self.title = @"Remote Services";
	}
    
	
	
	
}


//---------------------------------------------------------------------------------------



- (void)dealloc {
	[self stopCurrentResolve];
	self.services = nil;
	[self.netServiceBrowser stop];
	self.netServiceBrowser = nil;
    [super dealloc];
}


@end

