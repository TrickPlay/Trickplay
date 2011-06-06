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


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the View
    self.title = @"TV";
    self.view.tag = 1;
    
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAppBrowser:) name:@"PushAppBrowserNotification" object:nil];
    
    // Initialize the NSNetServiceBrowser stuff
    netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
    
    if (!currentTVIndicator) {
        currentTVIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 20.0)];
        currentTVIndicator.backgroundColor = [UIColor colorWithRed:1.0 green:168.0/255.0 blue:18.0/255.0 alpha:1.0];
        currentTVIndicator.layer.borderWidth = 3.0;
        currentTVIndicator.layer.borderColor = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0].CGColor;
        currentTVIndicator.layer.cornerRadius = currentTVIndicator.frame.size.height/2.0;
    }
        
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadData {
    [(UITableView *)self.view reloadData];
}

- (void)pushAppBrowser:(NSNotification *)notification {
    NSLog(@"Pushing App Browser");
    if (self.navigationController.visibleViewController != self) {
        return;
    }
    
    if ([appBrowserViewController hasRunningApp]) {
        [self.navigationController pushViewController:appBrowserViewController animated:NO];
        [appBrowserViewController pushApp];
    } else {
        [self.navigationController pushViewController:appBrowserViewController animated:YES];
        if ([appBrowserViewController fetchApps]) {
            [appBrowserViewController.theTableView reloadData];
        } else {
            [self.navigationController.view.layer removeAllAnimations];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)serviceResolved:(NSNetService *)service {
    NSLog(@"RootViewController serviceResolved");
    [netServiceManager stop];
    [appBrowserViewController setupService:[service port] hostname:[service hostName] thetitle:[service name]];
    currentTVName = [[service name] retain];
    // add mask and spinner
}

- (void)didNotResolveService {
    NSLog(@"RootViewController didNotResolveService");
    if (gestureViewController) {
        if (self.navigationController.visibleViewController == gestureViewController) {
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [gestureViewController release];
            gestureViewController = nil;
        }
    }
    if (appBrowserViewController) {
        if (self.navigationController.visibleViewController == appBrowserViewController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [appBrowserViewController release];
            appBrowserViewController = nil;
        }
    }
    [netServiceManager start];
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
        /*
        if (gestureViewController) {
            [gestureViewController release];
            gestureViewController = nil;
        }
        if (appBrowserViewController) {
            [appBrowserViewController release];
            appBrowserViewController = nil;
        }
        //*/
        [netServiceManager start];
    }
    // if popping back to app browser
    else if (viewController.view.tag == appBrowserViewController.view.tag) {
        if ([appBrowserViewController fetchApps]) {
            [appBrowserViewController.theTableView reloadData];
            appBrowserViewController.pushingViewController = NO;
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
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
    if ([cell.textLabel.text compare:currentTVName] == NSOrderedSame) {
        [cell addSubview:currentTVIndicator];
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
 * Override to support row selection in the table view.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected row %@\n", indexPath);
    
    NSMutableArray *services = netServiceManager.services;
    NSLog(@"services %@\n", services);
    NSLog(@"number of services %d\n", [services count]);
    
    if ([services count] == 0) { [self reloadData]; [netServiceManager start]; return; }
    
    if (!currentTVName || ([currentTVName compare:[[services objectAtIndex:indexPath.row] name]] != NSOrderedSame)) {
        if (gestureViewController) {
            [gestureViewController release];
            gestureViewController = nil;
        }
        if (appBrowserViewController) {
            [appBrowserViewController release];
        }
        appBrowserViewController = [[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:nil];
        if (currentTVName) {
            [currentTVName release];
            currentTVName = nil;
        }
        
        netServiceManager.currentService = [services objectAtIndex:indexPath.row];
        [netServiceManager.currentService setDelegate:netServiceManager];
    
        [netServiceManager.currentService resolveWithTimeout:0.0];
    } else {
        [self pushAppBrowser:nil];
    }
    
	
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
    if (currentTVIndicator) {
        [currentTVIndicator release];
        currentTVIndicator = nil;
    }
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
    if (currentTVIndicator) {
        [currentTVIndicator release];
        currentTVIndicator = nil;
    }
    if (currentTVName) {
        [currentTVName release];
        currentTVName = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


@end

