//
//  TVBrowserViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowserViewController.h"
#import "TVBrowser.h"
#import "Extensions.h"

@interface ConnectedTVIndicator : UIImageView

@end

@implementation ConnectedTVIndicator

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:168.0/255.0 blue:18.0/255.0 alpha:1.0];
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0].CGColor;
        self.layer.cornerRadius = self.frame.size.height/2.0;
    }
    
    return self;
}

@end



@interface TVBrowserViewControllerContext : TVBrowserViewController  {
@private
    // Orange dot that displays next to the current service
    // UIView *currentTVIndicator;
    // Spins while a service is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    
    // Refreshes the list of services
    UIBarButtonItem *refreshButton;
    
    TVBrowser *tvBrowser;
    
    id <TVBrowserViewControllerDelegate> delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvBrowser:(TVBrowser *)browser;


@end



@implementation TVBrowserViewControllerContext

@synthesize tvBrowser;
@synthesize delegate;

- (id)init {
    return [self initWithNibName:@"TVBrowserViewController" bundle:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        delegate = nil;
        tvBrowser = [[TVBrowser alloc] initWithDelegate:nil];
        [tvBrowser addViewController:self];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil tvBrowser:[[[TVBrowser alloc] initWithDelegate:nil] autorelease]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvBrowser:(TVBrowser *)browser {
    if (!browser || ![browser isKindOfClass:[TVBrowser class]] || !nibNameOrNil || [nibNameOrNil compare:@"TVBrowserViewController"] != NSOrderedSame || nibBundleOrNil) {
        
        [self release];
        return nil;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
        tvBrowser = [browser retain];
        [tvBrowser addViewController:self];
    }
    
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)refresh {
    if (tvBrowser) {
        [tvBrowser refreshServices];
    }
}

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
    
    // Add a button to the navigation bar that refreshes the list of advertised
    // services.
    refreshButton = [[UIBarButtonItem alloc] initWithTitle: @"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    [[self navigationItem] setRightBarButtonItem:refreshButton];
    
    // Initialize the currentTVIndicator if it does not exist
    /*
     if (!currentTVIndicator) {
     currentTVIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 20.0)];
     currentTVIndicator.backgroundColor = [UIColor colorWithRed:1.0 green:168.0/255.0 blue:18.0/255.0 alpha:1.0];
     currentTVIndicator.layer.borderWidth = 3.0;
     currentTVIndicator.layer.borderColor = [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0].CGColor;
     currentTVIndicator.layer.cornerRadius = currentTVIndicator.frame.size.height/2.0;
     }
     */
    
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
    /*
     if (currentTVIndicator) {
     [currentTVIndicator release];
     currentTVIndicator = nil;
     }
     */
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
    if (refreshButton) {
        [refreshButton release];
        refreshButton = nil;
    }
    
    self.tableView.tableFooterView = nil;
}

#pragma mark -
#pragma mark - Managing Broadcasted Services

/**
 * Reloads the data in the UITableView which lists the advertised services.
 */
- (void)reloadData {
    [(UITableView *)self.view reloadData];
}

- (void)invalidate {
    [tvBrowser invalidateViewController:self];
    [tvBrowser release];
    tvBrowser = nil;
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
	
	NSUInteger count = [[tvBrowser getAllServices] count];
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
    
    for (UIView *subview in cell.subviews) {
        if ([subview isKindOfClass:[ConnectedTVIndicator class]]) {
            [subview removeFromSuperview];
        }
    }
    
    NSArray *services = [tvBrowser getAllServices];
	NSUInteger count = services.count;
    NSLog(@"number of services = %d", count);
    // If no service advertisements have been received then a single cell will
    // display "Searching for services..."
	if (count == 0) {
        //[currentTVIndicator removeFromSuperview];
        [loadingSpinner removeFromSuperview];
        cell.textLabel.text = @"Searching for services...";
        // Remove a lingering activity indicator from a previously active
        // service.
        cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
        
		return cell;
	}
	
	// Set up the text for the cell to display the name of the service
	NSNetService *service = [services objectAtIndex:indexPath.row];
	cell.textLabel.text = [service name];
	cell.textLabel.textColor = [UIColor blackColor];
    
    NSArray *connectedServices = [tvBrowser getConnectedServices];
    // If the controller is currently connected to this service then
    // display an orange indicator dot. (Be sure to remove the loadingSpinner
    // in case the service had only just loaded)
    if ([connectedServices containsObject:service]) {
        [loadingSpinner removeFromSuperview];
        [loadingSpinner stopAnimating];
        
        ConnectedTVIndicator *connectedTVIndicator = [[[ConnectedTVIndicator alloc] initWithFrame:CGRectMake(10.0, 10.0, 20.0, 20.0)] autorelease];
        
        [cell addSubview:connectedTVIndicator];
        cell.textLabel.text = [NSString stringWithFormat:@"     %@", cell.textLabel.text];
    } else {
        // Remove the current TV indicator
        if (cell.accessoryView != loadingSpinner) {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    // If the NetServiceManager is currently establishing a connection to a
    // service selected by the user display a loadingSpinner for the indicator
    // and disable the user from selecting the service a second time (this
    // would unnecessarily restart the connection process).
    NSArray *connectingServices = [tvBrowser getConnectingServices];
    if ([connectingServices containsObject:service]) {
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
    
    NSArray *services = [tvBrowser getAllServices];
	NSUInteger count = services ? [services count] : 0;
    NSLog(@"services %@\n", services);
    NSLog(@"number of services %d\n", count);
    
    if (count == 0 || indexPath.row >= count) {
        if (tvBrowser) {
            [tvBrowser refreshServices];
        }
    } else {
        if (tvBrowser && ![[tvBrowser getConnectingServices] containsObject:[services objectAtIndex:indexPath.row]]) {
            [delegate tvBrowserViewController:self didSelectService:[services objectAtIndex:indexPath.row]];
            
            [tvBrowser connectToService:[services objectAtIndex:indexPath.row]];
        }
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
    
    [self invalidate];
    
    /*
     if (currentTVIndicator) {
     [currentTVIndicator release];
     currentTVIndicator = nil;
     }
     */
    if (loadingSpinner) {
        [loadingSpinner stopAnimating];
        [loadingSpinner release];
        loadingSpinner = nil;
    }
    
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


@implementation TVBrowserViewController

#pragma mark -
#pragma mark Allocation

+ (id)alloc {
    if ([self isEqual:[TVBrowserViewController class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [TVBrowserViewControllerContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[TVBrowserViewController class]]) {
        return [TVBrowserViewControllerContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvBrowser:(TVBrowser *)browser {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma Virtual Getters/Setters

- (id <TVBrowserViewControllerDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <TVBrowserViewControllerDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (TVBrowser *)tvBrowser {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark View lifecycle

- (void)refresh {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark - Managing Broadcasted Services

/**
 * Reloads the data in the UITableView which lists the advertised services.
 */
- (void)reloadData {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)invalidate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Table view data source

/**
 * Customize the number of sections in the table view. Currently only the single
 * section which displays the advertised services.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


/**
 * Customize the number of rows in the table view. Either matches the number of
 * services or if 0 services there is one table which will state "Searching
 * for services..."
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/**
 * Customize the appearance of table view cells. Cells will display the services
 * advertised over the network. If a service is currently connected to the
 * controller then this service will have an orange dot next to the service
 * name. If a service is loading and/or trying to establish a connection
 * to the controller then this service will have a spinner as an indicator.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

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
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Memory management


/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    NSLog(@"TVBrowserViewController dealloc");
    
    [super dealloc];
}
*/

@end
