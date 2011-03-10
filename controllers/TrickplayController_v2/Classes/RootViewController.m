//
//  RootViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController

@synthesize window;
//@synthesize navigationController;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the View
    self.title = @"TV";
    self.view.tag = 1;
    
    self.navigationController.delegate = self;
    
    // Initialize the NSNetServiceBrowser stuff
    netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
        
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadData {
    [(UITableView *)self.view reloadData];
}

- (void)serviceResolved:(NSNetService *)service {
    /*
    if (gestureViewController == nil)
	{
		gestureViewController = [[GestureViewController alloc] initWithNibName:@"GestureViewController" bundle:nil];
	}
    
	[gestureViewController setupService:[service port] hostname:[service hostName] thetitle:[service name]];

	[self.navigationController pushViewController:gestureViewController animated:YES];
	//[[self navigationController] presentModalViewController:gestureViewController animated:YES];
	//self.title = @"Disconnect"; 
     //*/
    
    /*
    [gestureViewController setupService:[service port] hostname:[service hostName] thetitle:[service name]];
    [gestureViewController startService];
    */
    
    [netServiceManager stop];
    [appBrowserViewController setupService:[service port] hostname:[service hostName] thetitle:[service name]];
    if ([appBrowserViewController fetchApps]) {
        [appBrowserViewController.theTableView reloadData];
    }
}

- (void)didNotResolveService {
    if (gestureViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (appBrowserViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self reloadData];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Navigation Controller Delegate methods

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {
    NSLog(@"navigation controller tag = %d", viewController.view.tag);

    // if popping back to self, release everything else
    if (viewController.view.tag == self.view.tag) {
        if (gestureViewController) {
            [gestureViewController release];
            gestureViewController = nil;
        }
        if (appBrowserViewController) {
            [appBrowserViewController release];
            appBrowserViewController = nil;
        }
        [netServiceManager start];
    }
    // if popping back to app browser
    else if (viewController.view.tag == appBrowserViewController.view.tag) {
        [appBrowserViewController fetchApps];
        [appBrowserViewController.theTableView reloadData];
        appBrowserViewController.pushingViewController = NO;
    }
    
    [self reloadData];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
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
    NSLog(@"number of services = %d", count);
	if (count == 0) {
        // If there are no services and searchingForServicesString is set, show one row explaining that to the user.
        cell.textLabel.text = @"Searching for services...";
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
 * Override to support row selection in the table view.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected row %@\n", indexPath);
    
    NSMutableArray *services = netServiceManager.services;
    NSLog(@"services %@\n", services);
    NSLog(@"count %d\n", [services count]);
    
    if ([services count] == 0) return;
    
    /*
    //NSLog(@"pushing gestureViewController = %@\n", gestureViewController);
    if (gestureViewController == nil) {
		gestureViewController = [[GestureViewController alloc] initWithNibName:@"GestureViewController" bundle:nil];
	}
    
	[self.navigationController pushViewController:gestureViewController animated:YES];    
    */
    //NSLog(@"pushing appBrowserViewController = %@", appBrowserViewController);
    if (appBrowserViewController == nil) {
        appBrowserViewController = [[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:appBrowserViewController animated:YES];
    
	netServiceManager.currentService = [services objectAtIndex:indexPath.row];
	[netServiceManager.currentService setDelegate:netServiceManager];
    
	[netServiceManager.currentService resolveWithTimeout:0.0];
    
	
	NSIndexPath *indexPath2 = [tableView indexPathForSelectedRow];
	if (indexPath2 != nil)
	{
		[tableView deselectRowAtIndexPath:indexPath2 animated:YES];
	}
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    NSLog(@"RootViewController dealloc");
    [netServiceManager release];
    if (gestureViewController) {
        [gestureViewController release];
    }
    if (appBrowserViewController) {
        [appBrowserViewController release];
    }

    [super dealloc];
}


@end

