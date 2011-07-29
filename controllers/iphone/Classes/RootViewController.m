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
@synthesize currentTVName;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the View
    self.title = @"TV";
    self.view.tag = 1;
    
    self.navigationController.delegate = self;
    
    // After selecting a service the controller will try to make a connection
    // to the said service. Once the service is connected this notification is
    // called to RootViewController to push the AppBrowserController
    // to the UINavigationController
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAppBrowser:) name:@"PushAppBrowserNotification" object:nil];
    
    // Initialize the NSNetServiceBrowser stuff
    // The netServiceManager manages advertisements from service broadcasts
    if (!netServiceManager) {
        netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
    }
    
    // Add a button to the navigation bar that refreshes the list of advertised
    // services.
    refreshButton = [[UIBarButtonItem alloc] initWithTitle: @"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    [[self navigationItem] setRightBarButtonItem:refreshButton];
    
    // Initialize the currentTVIndicator if it does not exist
    if (!currentTVIndicator) {
        currentTVIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 20.0)];
        currentTVIndicator.backgroundColor = [UIColor colorWithRed:1.0 green:168.0/255.0 blue:18.0/255.0 alpha:1.0];
        currentTVIndicator.layer.borderWidth = 3.0;
        currentTVIndicator.layer.borderColor = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0].CGColor;
        currentTVIndicator.layer.cornerRadius = currentTVIndicator.frame.size.height/2.0;
    }
    
    // Initialize the loadingSpinner if it does not exist
    if (!loadingSpinner) {
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
}

/**
 * Reloads the data in the UITableView which lists the advertised services.
 */
- (void)reloadData {
    [(UITableView *)self.view reloadData];
}

/**
 * Refreshes the list of advertised services.
 */
- (void)refresh {
    [netServiceManager start]; [self reloadData];
}

/**
 * Pushes the AppBrowserViewController to the top of the UINavigationController
 * stack. This makes the AppBrowserViewController's view visible pushing the
 * RootViewController's view off screen.
 *
 * This method may be called via the Apps default NSNotificationCenter with the
 * notification named "PushAppBrowserNotification" usually under the circumstances
 * that a connection to a service has been established. (Connections managed
 * in classes other than this one).
 */
- (void)pushAppBrowser:(NSNotification *)notification {
    NSLog(@"Pushing App Browser");
    // If self is not the visible view controller then it has no authority
    // to push anther view controller to the top of the view controller stack.
    if (self.navigationController.visibleViewController != self) {
        return;
    }
    
    // If Trickplay is running an app and the AppBrowserViewController is aware
    // that this app is running then push the AppBrowser to the top of the stack
    // and then push the app to the top of the stack. Meanwhile stop the
    // NetServiceManager from searching for advertised services to prevent
    // the network from bogging down.
    if ([appBrowserViewController hasRunningApp]) {
        [self.navigationController pushViewController:appBrowserViewController animated:NO];
        [appBrowserViewController pushApp];
        [netServiceManager stop];
    } else {
        // AppBrowserViewController is not aware of any currently running app
        // on Trickplay, thus, fetch the apps this service provides.
        if ([appBrowserViewController fetchApps]) {
            // If there are apps available, push the AppBrowser to the top of the
            // stack and stop searching for service advertisements.
            [self.navigationController pushViewController:appBrowserViewController animated:YES];
            [appBrowserViewController.theTableView reloadData];
            [netServiceManager stop];
        } else {
            // Either this service does not provide any of the functionality capable
            // of running this controller or there was an error gathering data over
            // the network; remain in the RootViewController and continue to search
            // for services.
            [self.navigationController.view.layer removeAllAnimations];
            [self.navigationController popToRootViewControllerAnimated:YES];
            self.currentTVName = nil;
            [appBrowserViewController release];
            appBrowserViewController = nil;
            [self refresh];
        }
    }
}


/**
 * NetServiceManager delegate callback. Called when a connection may be established
 * to a service after the user selects a service they wish to connect to. Sends
 * the connection information to the AppBrowser which will pass said information
 * to classes to create a stream socket. Additionally, stores the service name
 * to the currentTVName.
 */
- (void)serviceResolved:(NSNetService *)service {
    NSLog(@"RootViewController serviceResolved");
    [netServiceManager stop];
    [appBrowserViewController setupService:[service port] hostname:[service hostName] thetitle:[service name]];
    currentTVName = [[service name] retain];
    // add mask and spinner
}

/**
 * NetServiceManager delegate callback. Called when establishing a stream
 * socket to the service the user selected fails. Based on which ViewController
 * is at the top of the UINavigationController view controller stack it will
 * properly pop and deallocate these resources as the system regresses back
 * to the RootViewController.
 */
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
    [self refresh];
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

/**
 * UINavigationController delegate callback called whenever a view controller
 * is about to be pushed or popped from the navigation controller.
 *
 * Callback is used to properly deallocate other view controllers when popping
 * back to the RootViewController or to fetch usable apps from Trickplay to display
 * in the AppBrowserViewController when the AppBrowser is about to be displayed.
 */
- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {

    // if popping back to self
    if (viewController == self) {
        if (appBrowserViewController && ![appBrowserViewController hasRunningApp]) {
            if (gestureViewController) {
                [gestureViewController release];
                gestureViewController = nil;
            }
            [appBrowserViewController release];
            appBrowserViewController = nil;
            [currentTVName release];
            currentTVName = nil;
            [currentTVIndicator removeFromSuperview];
        }
        
        [netServiceManager start];
    }
    // if popping back to app browser
    else if (viewController == appBrowserViewController) {
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
#pragma mark AppBrowserViewControllerSocketDelegate stuff

/**
 * Generic operations to perform when the network fails. Includes deallocating
 * other view controllers and their resources and restarting the NetServiceManager
 * which will then begin browsing for advertised services.
 */
- (void)handleSocketProblems {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if (appBrowserViewController) {
        if (gestureViewController) {
            [gestureViewController release];
            gestureViewController = nil;
        }
        [appBrowserViewController release];
        appBrowserViewController = nil;
        [currentTVName release];
        currentTVName = nil;
        [currentTVIndicator removeFromSuperview];
    }
    
    [netServiceManager start];
}

/**
 * GestureViewControllerSocketDelegate callback called from AppBrowserViewController
 * when an error occurs over the network.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in Root");
        
    [self handleSocketProblems];
}

/**
 * GestureViewControllerSocketDelegate callback called from AppBrowserViewController
 * when the stream socket closes.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in Root");
    
    [self handleSocketProblems];
}


#pragma mark -
#pragma mark Table view data source

/**
 * Customize the number of sections in the table view. Currently only the single
 * section which displays the advertised services.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/**
 * Customize the number of rows in the table view. Either matches the number of
 * services or if 0 services there is one table which will state "Searching
 * for services..."
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSUInteger count = [netServiceManager.services count];
	if (count == 0) {
		return 1;
	}
    
	return count;
}

/**
 * Customize the appearance of table view cells. Cells will display the services
 * advertised over the network. If a service is currently connected to the
 * controller then this service will have an orange dot next to the service
 * name. If a service is loading and/or trying to establish a connection
 * to the controller then this service will have a spinner as an indicator.
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
    // If no service advertisements have been received then a single cell will
    // display "Searching for services..."
	if (count == 0) {
        [currentTVIndicator removeFromSuperview];
        [loadingSpinner removeFromSuperview];
        if ([self.navigationController visibleViewController] == self) {
            [currentTVName release];
            currentTVName = nil;
        }
        cell.textLabel.text = @"Searching for services...";
		cell.accessoryType = UITableViewCellAccessoryNone;
		// Remove a lingering activity indicator from a previously active
        // service.
        cell.accessoryView = nil;
        
		return cell;
	}
	
	// Set up the text for the cell to display the name of the service
	NSNetService *service = [services objectAtIndex:indexPath.row];
	cell.textLabel.text = [service name];
	cell.textLabel.textColor = [UIColor blackColor];
    // If the controller is currently connected to this service then
    // display an orange indicator dot. (Be sure to remove the loadingSpinner
    // in case the service had only just loaded)
    if ([cell.textLabel.text compare:currentTVName] == NSOrderedSame) {
        [loadingSpinner removeFromSuperview];
        [loadingSpinner stopAnimating];
        [cell addSubview:currentTVIndicator];
        cell.textLabel.text = [NSString stringWithFormat:@"     %@", cell.textLabel.text];
    } else {
        // Remove the current TV indicator
        if (currentTVIndicator.superview) {
            [currentTVIndicator removeFromSuperview];
        }
    }
    
    // If the NetServiceManager is currently establishing a connection to a
    // service selected by the user display a loadingSpinner for the indicator
    // and disable the user from selecting the service a second time (this
    // would unnecessarily restart the connection process).
    if (netServiceManager.currentService == service) {
        cell.accessoryView = loadingSpinner;
        [loadingSpinner startAnimating];
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    cell.userInteractionEnabled = YES;
    cell.accessoryView = nil;
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
#pragma mark Table View delegate

/**
 * UITableViewDelegate callback called when a user selects a cell in the table.
 *
 * A cell selection from the RootViewController's UITableView would indicate
 * the user wants to establish a connection to the service listed in the
 * corresponding cell.
 *
 * This function checks to see if a service exists in that
 * cell. If so then it checks to see if a connection has already been established
 * which it would then push the AppBrowser for that service to the top of the
 * UINavigationViewController view controller stack.
 *
 * Otherwise, the method deallocates view controllers associated with any other
 * service that may have a connection established (in effect, destroying that
 * connection), creates a new AppBrowserViewController, and sends this new
 * AppBrowser connection information to connect to the new service.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected row %@\n", indexPath);
    
    NSMutableArray *services = netServiceManager.services;
    NSLog(@"services %@\n", services);
    NSLog(@"number of services %d\n", [services count]);
    
    if ([services count] == 0) { [self refresh]; return; }
    
    if (!currentTVName || ([currentTVName compare:[[services objectAtIndex:indexPath.row] name]] != NSOrderedSame)) {
        if (gestureViewController) {
            [gestureViewController release];
            gestureViewController = nil;
        }
        if (appBrowserViewController) {
            [appBrowserViewController release];
        }
        appBrowserViewController = [[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:nil];
        appBrowserViewController.socketDelegate = self;
        if (currentTVName) {
            [currentTVName release];
            currentTVName = nil;
        }
        
        netServiceManager.currentService = [services objectAtIndex:indexPath.row];
        [netServiceManager.currentService setDelegate:netServiceManager];
    
        [netServiceManager.currentService resolveWithTimeout:5.0];
        
        [tableView reloadData];
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
    //[super viewDidUnload];
    NSLog(@"RootViewController Unload");
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    if (currentTVIndicator) {
        [currentTVIndicator release];
        currentTVIndicator = nil;
    }
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
    if (refreshButton) {
        [refreshButton release];
        refreshButton = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    NSLog(@"RootViewController dealloc");
    [netServiceManager release];
    if (gestureViewController) {
        [gestureViewController release];
    }
    if (appBrowserViewController) {
        // Make sure to get rid of the AppBrowser's socket delegate
        // or a race condition may occur where the AppBrowser recieves
        // a call indicating that has a socket error and passes this
        // information to a deallocated RootViewController before the
        // RootViewController has a chance to deallocate the AppBrowser.
        appBrowserViewController.socketDelegate = nil;
        [appBrowserViewController release];
        appBrowserViewController = nil;
    }
    if (currentTVIndicator) {
        [currentTVIndicator release];
        currentTVIndicator = nil;
    }
    if (currentTVName) {
        [currentTVName release];
        currentTVName = nil;
    }
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
    // Remove the "PushAppBrowserNotification" from the default NSNotificationCenter.
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


@end

