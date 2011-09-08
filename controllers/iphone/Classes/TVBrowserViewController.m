//
//  TVBrowserViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowserViewController.h"

@implementation TVBrowserViewController

@synthesize tvBrowser;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];   
    
    UILabel *version_label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    version_label.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    // Colors and font
    version_label.backgroundColor = [UIColor clearColor];
    version_label.font = [UIFont systemFontOfSize:11];
    version_label.textColor = [UIColor lightGrayColor];
    // Automatic word wrap
    version_label.lineBreakMode = UILineBreakModeHeadTruncation;
    version_label.textAlignment = UITextAlignmentCenter;
    version_label.numberOfLines = 0;
    // Autosize
    [version_label sizeToFit];
    // Add the UILabel to the tableview
    self.tableView.tableFooterView = version_label;
    
    // Customize the View
    self.title = @"TV";
    self.view.tag = 1;
        
    // After selecting a service the controller will try to make a connection
    // to the said service. Once the service is connected this notification is
    // called to RootViewController to push the AppBrowserController
    // to the UINavigationController
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAppBrowser:) name:@"ConnectionEstablishedNotification" object:nil];
    
    // Add a button to the navigation bar that refreshes the list of advertised
    // services.
    refreshButton = [[UIBarButtonItem alloc] initWithTitle: @"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    [[self navigationItem] setRightBarButtonItem:refreshButton];
    
    if (!tvBrowser) {
        tvBrowser = [[TVBrowser alloc] initWithDelegate:self];
    }
    
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
    self.tableView.tableFooterView = nil;
}

#pragma mark -
#pragma mark Current TV Name Getter/Setter

- (NSString *)currentTVName {
    NSString *_currentTVName = nil;
    @synchronized(self) {
        if (tvBrowser) {
            _currentTVName = [[tvBrowser.currentTVName retain] autorelease];
        } else {
            _currentTVName = [[currentTVName retain] autorelease];
        }
    }
    NSLog(@"_currentTVName: %@", _currentTVName);
    return _currentTVName;
}

// TODO: Check that this is being called properly
- (void)setCurrentTVName:(NSString *)_currentTVName {
    @synchronized(self) {
        [_currentTVName retain];
        [currentTVName release];
        currentTVName = _currentTVName;
    }
    
    if (tvBrowser) {
        tvBrowser.currentTVName = currentTVName;
    }
    NSLog(@"_currentTVName: %@, currentTVName: %@", _currentTVName, tvBrowser.currentTVName);
}

#pragma mark -
#pragma mark - AppBrowserDelegate methods

- (void)didReceiveCurrentAppInfo:(NSDictionary *)info {
    
}

- (void)didReceiveAvailableAppsInfo:(NSArray *)info {
    
}

#pragma mark -
#pragma mark - Managing Broadcasted Services

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
    [tvBrowser refreshServices]; [self reloadData];
}

- (void)startSearchForServices {
    [tvBrowser startSearchForServices];
}
- (void)stopSearchForServices {
    [tvBrowser stopSearchForServices];
}

/**
 * NetServiceManager delegate callback. Called when a connection may be established
 * to a service after the user selects a service they wish to connect to. Sends
 * the connection information to the AppBrowser which will pass said information
 * to classes to create a stream socket. Additionally, stores the service name
 * to the currentTVName.
 */
- (void)serviceResolved:(NSNetService *)service {
    NSLog(@"TVBrowserViewController serviceResolved");
    [tvBrowser stopSearchForServices];
    self.currentTVName = [[service name] retain];
    if (delegate) {
        [delegate serviceResolved:service];
    }
}

/**
 * NetServiceManager delegate callback. Called when establishing a stream
 * socket to the service the user selected fails. Based on which ViewController
 * is at the top of the UINavigationController view controller stack it will
 * properly pop and deallocate these resources as the system regresses back
 * to the RootViewController.
 */
- (void)didNotResolveService {
    NSLog(@"TVBrowserViewController didNotResolveService");
    
    [self refresh];
    if (delegate) {
        [delegate didNotResolveService];
    }
}

- (void)didFindServices {
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
	
	NSUInteger count = [[tvBrowser getServices] count];
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
    
    NSArray *services = [tvBrowser getServices];
	NSUInteger count = [services count];
    NSLog(@"number of services = %d", count);
    // If no service advertisements have been received then a single cell will
    // display "Searching for services..."
	if (count == 0) {
        [currentTVIndicator removeFromSuperview];
        [loadingSpinner removeFromSuperview];
        if ([self.navigationController visibleViewController] == self) {
            self.currentTVName = nil;
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
    NSLog(@"currentTVName: %@", currentTVName);
    if ([cell.textLabel.text compare:currentTVName] == NSOrderedSame) {
        [loadingSpinner removeFromSuperview];
        [loadingSpinner stopAnimating];
        [cell addSubview:currentTVIndicator];
        cell.textLabel.text = [NSString stringWithFormat:@"     %@", cell.textLabel.text];
    } else {
        // Remove the current TV indicator
        if (currentTVIndicator.superview == cell) {
            [currentTVIndicator removeFromSuperview];
        }
    }
    
    // If the NetServiceManager is currently establishing a connection to a
    // service selected by the user display a loadingSpinner for the indicator
    // and disable the user from selecting the service a second time (this
    // would unnecessarily restart the connection process).
    if ([tvBrowser getCurrentService] == service) {
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
    
    NSArray *services = [tvBrowser getServices];
    NSLog(@"services %@\n", services);
    NSLog(@"number of services %d\n", [services count]);
    
    if ([services count] == 0 || indexPath.row >= [services count]) {
        [self refresh];
    } else if (!currentTVName || ([currentTVName compare:[[services objectAtIndex:indexPath.row] name]] != NSOrderedSame)) {
        self.currentTVName = nil;
        
        [delegate didSelectService:[services objectAtIndex:indexPath.row] isCurrentService:NO];
        
        [tvBrowser resolveServiceAtIndex:indexPath.row];
    } else {
        [delegate didSelectService:[services objectAtIndex:indexPath.row] isCurrentService:YES];
    }
    
	
	NSIndexPath *indexPath2 = [tableView indexPathForSelectedRow];
	if (indexPath2 != nil)
	{
		[tableView deselectRowAtIndexPath:indexPath2 animated:YES];
	}
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark AutoRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    NSLog(@"TVBrowserViewController dealloc");
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
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
