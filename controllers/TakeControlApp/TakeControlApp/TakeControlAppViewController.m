//
//  TakeControlAppViewController.m
//  TakeControlApp
//
//  Created by Rex Fenley on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TakeControlAppViewController.h"

@implementation TakeControlAppViewController

@synthesize navController;
@synthesize tvBrowserViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        pushingAppBrowser = NO;
        pushingAppViewController = NO;
        appsRefresh = NO;
        currentAppRefresh = NO;
        // TODO: check if this is needed: [TVBrowserViewController class];
    }
    
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"TV";
    
    tvBrowserViewController = [[TVBrowserViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:tvBrowserViewController];
    
    self.view.window.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.navController.delegate = self;
    
    tvBrowserViewController.delegate = self;
    tvBrowserViewController.tvBrowser.delegate = self;
    
    appsRefresh = NO;
    currentAppRefresh = NO;
    
    [self.view addSubview:navController.view];
}

- (void)viewDidUnload
{
    NSLog(@"RootViewController Unload");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self destroyTPAppViewController];
    [self destroyAppBrowserViewController];
    self.navController = nil;
    if (tvBrowserViewController) {
        tvBrowserViewController.delegate = nil;
        self.tvBrowserViewController = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navController viewWillAppear:animated];
    //[self.navigationController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [navController viewWillDisappear:animated];
    //[self.navigationController viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    pushingAppBrowser = NO;
    [navController viewDidAppear:animated];
    /*
    if (!self.modalViewController) {
        [self presentModalViewController:navController animated:NO];
    }
     */
    //[self.navigationController viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    pushingAppBrowser = NO;
    [navController viewDidDisappear:animated];
    //[self dismissModalViewControllerAnimated:NO];
    //[self.navigationController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark TVBrowserDelegate Methods

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)new {
    
    if (new) {
        connection.delegate = self;
        
        [self destroyTPAppViewController];
        [self destroyAppBrowserViewController];
        AppBrowser *appBrowser = [[[AppBrowser alloc] initWithTVConnection:connection delegate:self] autorelease];
        appBrowserViewController = [[appBrowser getNewAppBrowserViewController] retain];
        appBrowserViewController.delegate = self;
        
        [self createTPAppViewControllerWithConnection:connection];
    } else {
        [appBrowserViewController.appBrowser refresh];
    }
}

- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service {
    if (appViewController) {
        if (self.navController.visibleViewController == appViewController) {
            [self.navController popViewControllerAnimated:NO];
        }
    }
    if (appBrowserViewController) {
        if (self.navController.visibleViewController == appBrowserViewController) {
            [self.navController popViewControllerAnimated:YES];
        } else {
            [appBrowserViewController release];
            appBrowserViewController = nil;
        }
    }
}

- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service {
    
}

- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service {
    
}

#pragma mark -
#pragma mark TVBrowserViewControllerDelegate Methods

- (void)tvBrowserViewController:(TVBrowserViewController *)_tvBrowserViewController didSelectService:(NSNetService *)service {
    if (![[_tvBrowserViewController.tvBrowser getConnectedServices] containsObject:service] && ![[_tvBrowserViewController.tvBrowser getConnectingServices] containsObject:service]) {
        [self destroyAppBrowserViewController];
        [self destroyTPAppViewController];
    } else {
        [appBrowserViewController refresh];
    }
}

#pragma mark -
#pragma mark AppBrowserDelegate methods

- (void)appBrowser:(AppBrowser *)appBrowser didReceiveAvailableApps:(NSArray *)apps {
    appsRefresh = YES;
    if (navController.visibleViewController == tvBrowserViewController && currentAppRefresh) {
        [self pushAppBrowser];
    }
}

- (void)appBrowser:(AppBrowser *)appBrowser didReceiveCurrentApp:(AppInfo *)app {
    currentAppRefresh = YES;
    if (navController.visibleViewController == tvBrowserViewController && appsRefresh) {
        [self pushAppBrowser];
    }
}

- (void)appBrowser:(AppBrowser *)appBrowser
    newAppLaunched:(AppInfo *)app
      successfully:(BOOL)success {
    
    
}

#pragma mark -
#pragma mark AppBrowserViewControllerDelegate methods

- (void)appBrowserViewController:(AppBrowserViewController *)appBrowserViewController 
                    didSelectApp:(AppInfo *)app 
                    isCurrentApp:(BOOL)isCurrentApp {
    
    if (!isCurrentApp) {
        [appViewController cleanViewController];
    }
    [self pushTPAppViewController];
}

#pragma mark -
#pragma mark Managing ViewControllers

/**
 * Creates the TPAppViewController, gives it a port and host name to establish
 * a connection to a service, and tells it to establish this connection.
 */
- (void)createTPAppViewControllerWithConnection:(TVConnection *)tvConnection {
    CGFloat
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    
    appViewController = [[TPAppViewController alloc] initWithTVConnection:tvConnection size:CGSizeMake(width, height - 44.0) delegate:self];
    
    if (!appViewController) {
        return;
    }
}

- (void)destroyTPAppViewController {
    if (appViewController) {
        appViewController.delegate = nil;
        [appViewController release];
        appViewController = nil;
    }
}

- (void)destroyAppBrowserViewController {
    if (appBrowserViewController) {
        appBrowserViewController.delegate = nil;
        [appBrowserViewController release];
        appBrowserViewController = nil;
    }
}

/**
 * Pushes the AppBrowserViewController to the top of the UINavigationController
 * stack. This makes the AppBrowserViewController's view visible pushing the
 * RootViewController's view off screen.
 *
 * This method may be called via the Apps default NSNotificationCenter with the
 * notification named "ConnectionEstablishedNotification" usually under the circumstances
 * that a connection to a service has been established. (Connections managed
 * in classes other than this one).
 */
- (void)pushAppBrowser {
    NSLog(@"Pushing App Browser");
    // If self is not the visible view controller then it has no authority
    // to push another view controller to the top of the view controller stack.
    NSLog(@"visible view controller: %@", self.navController.visibleViewController);
    if (self.navController.visibleViewController != tvBrowserViewController || pushingAppBrowser) {
        return;
    }
    
    pushingAppBrowser = YES;
    
    // If Trickplay is running an app and the AppBrowserViewController is aware
    // that this app is running then push the AppBrowser to the top of the stack
    // and then push the app to the top of the stack. Meanwhile stop the
    // NetServiceManager from searching for advertised services to prevent
    // the network from bogging down.
    if (appBrowserViewController && appBrowserViewController.appBrowser && appBrowserViewController.appBrowser.currentApp) {
        [self.navController pushViewController:appBrowserViewController animated:NO];
        [self pushTPAppViewController];
        [tvBrowserViewController.tvBrowser stopSearchForServices];
    } else {
        // AppBrowserViewController is not aware of any currently running app
        // on Trickplay, thus, fetch the apps this service provides.
        if (appBrowserViewController && appBrowserViewController.appBrowser && appBrowserViewController.appBrowser.availableApps) {
            // If there are apps available, push the AppBrowser to the top of the
            // stack and stop searching for service advertisements.
            [self.navController pushViewController:appBrowserViewController animated:YES];
            [appBrowserViewController.tableView reloadData];
            [tvBrowserViewController.tvBrowser stopSearchForServices];
        } else {
            // Either this service does not provide any of the functionality capable
            // of running this controller or there was an error gathering data over
            // the network; remain in the RootViewController and continue to search
            // for services.
            [self.navController.view.layer removeAllAnimations];
            [self.navController popToRootViewControllerAnimated:NO];
            pushingAppBrowser = NO;
            //[appBrowserViewController release];
            //appBrowserViewController = nil;
            [self destroyAppBrowserViewController];
            [self destroyTPAppViewController];
            [tvBrowserViewController refresh];
            appsRefresh = NO;
            currentAppRefresh = NO;
        }
    }
}

/**
 * Pushes the TPAppViewController to the top of the navigation stack making it
 * the visible view controller.
 */
- (void)pushTPAppViewController {
    pushingAppViewController = YES;
    
    if (self.navController.visibleViewController != appBrowserViewController) {
        [self.navController pushViewController:appBrowserViewController animated:NO];
    }
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Apps List" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[appBrowserViewController navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    
    [self.navController pushViewController:appViewController animated:YES];
}

#pragma mark -
#pragma mark Navigation Controller Delegate methods

- (void)resetViewControllers {
    if (navController.visibleViewController == tvBrowserViewController) {
        if (appViewController && ![appViewController hasConnection]) {
            if (appBrowserViewController) {
                [self destroyAppBrowserViewController];
            }
            
            [self destroyTPAppViewController];            
        }
        [tvBrowserViewController.tvBrowser startSearchForServices];
    }
    // if popping back to app browser
    else if (navController.visibleViewController == appBrowserViewController) {
        if (appBrowserViewController.appBrowser.availableApps.count >  0 || appBrowserViewController.appBrowser.currentApp) {
            // do nothing
        } else {
            [self.navController popToRootViewControllerAnimated:YES];
            [tvBrowserViewController refresh];
        }
        [appBrowserViewController.tableView reloadData];
    }
    // if app
    else if (navController.visibleViewController == appViewController) {
        if (![appViewController hasConnection]) {
            [self.navController popViewControllerAnimated:NO];
        }
    }
    
    [tvBrowserViewController.tableView reloadData];
    currentAppRefresh = NO;
    appsRefresh = NO;
}

/**
 * UINavigationController delegate callback called whenever a view controller
 * is about to be pushed or popped from the navigation controller.
 *
 * Callback is used to properly deallocate other view controllers when popping
 * back to the RootViewController or to fetch usable apps from Trickplay to display
 * in the AppBrowserViewController when the AppBrowser is about to be displayed.
 */
- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {
    //[viewController viewDidAppear:animated];
    
    pushingAppBrowser = NO;
    pushingAppViewController = NO;
    // if popping back to self
    if (viewController == tvBrowserViewController) {
        if (appViewController && ![appViewController hasConnection]) {
            if (appBrowserViewController) {
                [self destroyAppBrowserViewController];
            }
            
            [self destroyTPAppViewController];            
        }
        [tvBrowserViewController.tvBrowser startSearchForServices];
    }
    // if popping back to app browser
    else if (viewController == appBrowserViewController) {
        if (appBrowserViewController.appBrowser.availableApps.count > 0 || appBrowserViewController.appBrowser.currentApp) {
            // do nothing
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [tvBrowserViewController refresh];
        }
        [appBrowserViewController.tableView reloadData];
    }
    // if app
    else if (viewController == appViewController) {
        if (![appViewController hasConnection]) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
    [tvBrowserViewController.tableView reloadData];
    appsRefresh = NO;
    currentAppRefresh = NO;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    //[viewController viewWillAppear:animated];
    
    pushingAppViewController = YES;
    if (viewController == tvBrowserViewController) {
        //[tvBrowserViewController.tvBrowser startSearchForServices];
    } else if (viewController == appBrowserViewController) {
        [appBrowserViewController refresh];
    } else {
        [tvBrowserViewController.tvBrowser stopSearchForServices];
    }
}

#pragma mark -
#pragma mark TPAppViewControllerDelegate methods

- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController {
    [self resetViewControllers];
}

- (void)tpAppViewController:(TPAppViewController *)tpAppViewController wantsToPresentCamera:(UIViewController *)camera {
    [self presentViewController:camera animated:YES completion:nil];
}

- (void)tpAppViewControllerWillAppear:(TPAppViewController *)tpAppViewController {
    
}

#pragma mark -
#pragma mark TVConnectionDelegate stuff

- (void)tvConnectionDidDisconnect:(TVConnection *)connection abruptly:(BOOL)abrupt {
    if (pushingAppBrowser || pushingAppViewController) {
        return;
    }
    
    [self.navController popToRootViewControllerAnimated:YES];
    
    [self destroyAppBrowserViewController];
    [self destroyTPAppViewController];
    
    [tvBrowserViewController.tvBrowser refreshServices];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    NSLog(@"RootViewController dealloc");
    
    [self destroyTPAppViewController];
    
    [self destroyAppBrowserViewController];
    
    if (tvBrowserViewController) {
        tvBrowserViewController.delegate = nil;
        [tvBrowserViewController release];
    }
    
    self.navController = nil;
    
    [super dealloc];
}

@end