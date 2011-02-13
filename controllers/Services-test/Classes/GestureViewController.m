//
//  GestureViewController.m
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureViewController.h"


@implementation GestureViewController

@synthesize loadingIndicator;

-(void) startService:(NSInteger)port
            hostname:(NSString *)hostName
            thetitle:(NSString *)name {
    
    fprintf(stderr, "Service started name: %s host: %s port: %d\n", [name UTF8String], [hostName UTF8String], port);
    
    [loadingIndicator startAnimating];
    
    // Tell socket manager to create a socket and connect to the service selected
    socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                       port:port
                                                   delegate:self];
    
    // Made a connection, let the service know!
    //[self logInfo:FORMAT(@"Accepted client %@:%hu", host, port)]; //320x410
	//Get the actual width and height of the available area
    //*
	CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
	NSInteger height = mainframe.size.height;
	height = height - 45;  //subtract the height of navbar
	NSInteger width = mainframe.size.width;
	NSData *welcomeData = [[NSString stringWithFormat:@"ID\t2\t%@\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=%dx%d\tUS=%dx%d\n", [UIDevice currentDevice].name, width, height, width, height ] dataUsingEncoding:NSUTF8StringEncoding];
	
	
    [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
	[loadingIndicator stopAnimating];
    //*/
    
}

- (void)socketErrorOccurred {
    fprintf(stderr, "Socket Error Occurred\n");
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // If null then error connecting, back up to selecting services view
    if (!socketManager) {
        [self.navigationController popViewControllerAnimated:YES];
        [loadingIndicator stopAnimating];
    }
    
}
//*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [socketManager release];
    [loadingIndicator release];
    [super dealloc];
}


@end
