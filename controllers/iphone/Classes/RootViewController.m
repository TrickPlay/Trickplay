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
@synthesize navigationController;
@synthesize tvBrowserViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        pushingAppViewController = NO;
        pushingAppBrowser = NO;
        refreshCount = 0;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Customize the View
    self.title = @"TV";

    self.navigationController.delegate = self;
    
    // After selecting a service the controller will try to make a connection
    // to the said service. Once the service is connected this notification is
    // called to RootViewController to push the AppBrowserController
    // to the UINavigationController
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAppBrowser:) name:@"ConnectionEstablishedNotification" object:nil];
    
    tvBrowserViewController.delegate = self;
    tvBrowserViewController.tvBrowser.delegate = self;
    
    refreshCount = 0;
    
    [self.view addSubview:navigationController.view];
}

- (void)viewDidAppear:(BOOL)animated {
    pushingAppBrowser = NO;
    [navigationController viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    pushingAppBrowser = NO;
    [navigationController viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    NSLog(@"RootViewController Unload");
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [self destroyTPAppViewController];
    [self destroyAppBrowserViewController];
    self.navigationController = nil;
    if (tvBrowserViewController) {
        tvBrowserViewController.delegate = nil;
        self.tvBrowserViewController = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [navigationController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [navigationController viewWillDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark TVBrowserDelegate Methods

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)new {
    
    if (new) {
        connection.delegate = self;
    
        [self destroyAppBrowserViewController];
        AppBrowser *appBrowser = [[[AppBrowser alloc] initWithConnection:connection delegate:self] autorelease];
        appBrowserViewController = [appBrowser createAppBrowserViewController];
        appBrowserViewController.delegate = self;
    
        [self createTPAppViewControllerWithConnection:connection];
    } else {
        [appBrowserViewController.appBrowser refresh];
    }
}

- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service {
    if (appViewController) {
        if (self.navigationController.visibleViewController == appViewController) {
            [self.navigationController popViewControllerAnimated:NO];
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
    refreshCount++;
    if (navigationController.visibleViewController == tvBrowserViewController && refreshCount > 1) {
        [self pushAppBrowser:nil];
    }
}

- (void)appBrowser:(AppBrowser *)appBrowser didReceiveCurrentApp:(AppInfo *)app {
    refreshCount++;
    if (navigationController.visibleViewController == tvBrowserViewController && refreshCount > 1) {
        [self pushAppBrowser:nil];
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
        [appViewController clean];
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
    appViewController = [[TPAppViewController alloc] initWithTVConnection:tvConnection delegate:self];
    
    assert(appViewController);
    if (!appViewController) {
        return;
    }
        
    CGFloat
    x = self.view.frame.origin.x,
    y = self.view.frame.origin.y,
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    appViewController.view.frame = CGRectMake(x, y, width, height);
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
- (void)pushAppBrowser:(NSNotification *)notification {
    NSLog(@"Pushing App Browser");
    // If self is not the visible view controller then it has no authority
    // to push another view controller to the top of the view controller stack.
    NSLog(@"visible view controller: %@", self.navigationController.visibleViewController);
    if (self.navigationController.visibleViewController != tvBrowserViewController || pushingAppBrowser) {
        return;
    }
    
    pushingAppBrowser = YES;
    
    // If Trickplay is running an app and the AppBrowserViewController is aware
    // that this app is running then push the AppBrowser to the top of the stack
    // and then push the app to the top of the stack. Meanwhile stop the
    // NetServiceManager from searching for advertised services to prevent
    // the network from bogging down.
    if (appBrowserViewController && appBrowserViewController.appBrowser && appBrowserViewController.appBrowser.currentApp) {
            // TODO: Socket may close before this executes and cause inconsistancy
            [self.navigationController pushViewController:appBrowserViewController animated:NO];
            [self pushTPAppViewController];
            [tvBrowserViewController.tvBrowser stopSearchForServices];
    } else {
        // AppBrowserViewController is not aware of any currently running app
        // on Trickplay, thus, fetch the apps this service provides.
        if (appBrowserViewController && appBrowserViewController.appBrowser && appBrowserViewController.appBrowser.availableApps) {
            // If there are apps available, push the AppBrowser to the top of the
            // stack and stop searching for service advertisements.
                // TODO: Socket may close before this executes and cause inconsistancy
            [self.navigationController pushViewController:appBrowserViewController animated:YES];
            [appBrowserViewController.tableView reloadData];
            [tvBrowserViewController.tvBrowser stopSearchForServices];
        } else {
            // Either this service does not provide any of the functionality capable
            // of running this controller or there was an error gathering data over
            // the network; remain in the RootViewController and continue to search
            // for services.
            [self.navigationController.view.layer removeAllAnimations];
            [self.navigationController popToRootViewControllerAnimated:NO];
            pushingAppBrowser = NO;
            //[appBrowserViewController release];
            //appBrowserViewController = nil;
            [self destroyAppBrowserViewController];
            [self destroyTPAppViewController];
            [tvBrowserViewController refresh];
            refreshCount = 0;
        }
    }
}

/**
 * Pushes the TPAppViewController to the top of the navigation stack making it
 * the visible view controller.
 */
- (void)pushTPAppViewController {
    pushingAppViewController = YES;
    
    if (self.navigationController.visibleViewController != appBrowserViewController) {
        [self.navigationController pushViewController:appBrowserViewController animated:NO];
    }
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Apps List" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[appBrowserViewController navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    
    [self.navigationController pushViewController:appViewController animated:YES];
}

#pragma mark -
#pragma mark Navigation Controller Delegate methods

- (void)resetViewControllers {
    if (navigationController.visibleViewController == tvBrowserViewController) {
        if (appViewController && ![appViewController hasConnection]) {
            if (appBrowserViewController) {
                [self destroyAppBrowserViewController];
            }
            
            [self destroyTPAppViewController];            
        }
        [tvBrowserViewController.tvBrowser startSearchForServices];
    }
    // if popping back to app browser
    else if (navigationController.visibleViewController == appBrowserViewController) {
        if (appBrowserViewController.appBrowser.availableApps.count >  0 || appBrowserViewController.appBrowser.currentApp) {
            // do nothing
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [tvBrowserViewController refresh];
        }
        [appBrowserViewController.tableView reloadData];
    }
    // if app
    else if (navigationController.visibleViewController == appViewController) {
        if (![appViewController hasConnection]) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
    [tvBrowserViewController.tableView reloadData];
    refreshCount = 0;
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
    refreshCount = 0;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    pushingAppViewController = YES;
    if (viewController == tvBrowserViewController) {
        [tvBrowserViewController.tvBrowser startSearchForServices];
    } else {
        [tvBrowserViewController.tvBrowser stopSearchForServices];
    }
}

#pragma mark -
#pragma mark TPAppViewControllerDelegate methods

- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController {
    [self resetViewControllers];
}

#pragma mark -
#pragma mark TVConnectionDelegate stuff

- (void)tvConnectionDidDisconnect:(TVConnection *)connection abruptly:(BOOL)abrupt {
    if (pushingAppBrowser || pushingAppViewController) {
        return;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self destroyAppBrowserViewController];
    [self destroyTPAppViewController];
    
    [tvBrowserViewController.tvBrowser refreshServices];
}

/**
 * Generic operations to perform when the network fails. Includes deallocating
 * other view controllers and their resources and restarting the NetServiceManager
 * which will then begin browsing for advertised services.
 */
- (void)handleSocketProblems {
    if (pushingAppBrowser || pushingAppViewController) {
        return;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self destroyTPAppViewController];
    [self destroyAppBrowserViewController];
    
    [tvBrowserViewController refresh];
}

/**
 * TPAppViewControllerSocketDelegate callback called from AppBrowserViewController
 * when an error occurs over the network.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in Root");
        
    [self handleSocketProblems];
}

/**
 * TPAppViewControllerSocketDelegate callback called from AppBrowserViewController
 * when the stream socket closes.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in Root");
    
    [self handleSocketProblems];
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
    
    self.navigationController = nil;
    
    // Remove the "PushAppBrowserNotification" from the default NSNotificationCenter.
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


@end

