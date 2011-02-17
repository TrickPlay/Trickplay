//
//  GestureViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureViewController.h"
#import "TouchController.h"


@implementation GestureViewController

@synthesize loadingIndicator;
@synthesize backgroundView;
@synthesize touchDelegate;

-(void) setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n {
    
    NSLog(@"Service Setup: %@ host: %@ port: %d", n, h, p);
    
    port = p;
    if (hostName) {
        [hostName release];
    }
    hostName = [h retain];
}

-(void) startService {
    // Tell socket manager to create a socket and connect to the service selected
    socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                       port:port
                                                   delegate:self];
    
    if (!socketManager) {
        // If null then error connecting, back up to selecting services view
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Could Not Establish Connection");
        return;
    }
    
    // Made a connection, let the service know!
	// Get the actual width and height of the available are
	CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
	NSInteger height = mainframe.size.height;
	height = height - 45;  //subtract the height of navbar
	NSInteger width = mainframe.size.width;
	NSData *welcomeData = [[NSString stringWithFormat:@"ID\t2\t%@\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=%dx%d\tUS=%dx%d\n", [UIDevice currentDevice].name, width, height, width, height ] dataUsingEncoding:NSUTF8StringEncoding];
	
    
    resourceNames = [[NSMutableDictionary alloc] initWithCapacity:40];
	
    touchDelegate = [[TouchController alloc] initWithView:self.view socketManager:socketManager];
    [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
    
    //[loadingIndicator stopAnimating];
}

- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred");
    [socketManager release];
    [(TouchController *)touchDelegate release];
    [self clearUI];
    [loadingIndicator stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount
{
	if (socketManager)
	{
	    int index;	
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", thekey];
        
		for (index = 1; index <= thecount; index++) {
			[socketManager sendData:[sentData UTF8String]  numberOfBytes:[sentData length]];
		}
    }
}

- (void)exitTrickplayApp:(id)sender {
    //Send Escape key to exit whatever app is currently running
	[self sendKeyToTrickplay:@"FF1B" thecount:1];
}


//------------------- Handling Commands From Server ------------------


- (void)do_DR:(NSArray *)args {
    NSLog(@"Declaring Resource");
    [args retain];
    
    [resourceNames setObject:[
                              NSMutableDictionary dictionaryWithObjectsAndKeys:[args objectAtIndex:0], @"name", [args objectAtIndex:1], @"link", @"", @"scale", nil
                              ]
                      forKey:[args objectAtIndex:0]
     ];
    
    [args release];
}

- (void)do_UB:(NSArray *)args {
    NSLog(@"Updating Background");
    [args retain];
    
    NSString *key = [args objectAtIndex:0];
    // If resource has been declared
    if ([resourceNames objectForKey:key]) {
        // If resource has not been pulled, then pull it
        NSString *imageURLString = [[resourceNames objectForKey:key] objectForKey:@"link"];
        UIImage *tempImage;
        if ([imageURLString hasPrefix:@"http:"] || [imageURLString hasPrefix:@"https:"]) {
            tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]] autorelease];
        } else {
            //Use the hostname and port to construct the url
            NSURL *imageurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [socketManager host], [socketManager port], imageURLString]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageurl];
            tempImage = [[[UIImage alloc] initWithData:imageData] autorelease];
        }

        [loadingIndicator stopAnimating];

        backgroundView.image = tempImage;
    }
    
    [args release];
}


- (void)do_UG:(NSArray *)args {
    NSLog(@"Updating Graphics");
    [args retain];
    
    NSString *key = [args objectAtIndex:0];
    // If resource has been declared
    if ([resourceNames objectForKey:key]) {
        // TODO: if resource has not been pulled, then pull it
        NSString *imageURLString = [[resourceNames objectForKey:key] objectForKey:@"link"];
        UIImage *tempImage;
        if ([imageURLString hasPrefix:@"http:"] || [imageURLString hasPrefix:@"https:"]) {
            tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]] autorelease];
        } else {
            //Use the hostname and port to construct the url
            NSURL *imageurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [socketManager host], [socketManager port], imageURLString]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageurl];
            tempImage = [[[UIImage alloc] initWithData:imageData] autorelease];
        }
        
        // Now we have the image, we need to draw it
        CGFloat
        x = [[args objectAtIndex:1] floatValue],
        y = [[args objectAtIndex:2] floatValue],
        width = [[args objectAtIndex:3] floatValue],
        height = [[args	objectAtIndex:4] floatValue];
        
        UIImageView *newImageView = [[UIImageView alloc] initWithImage:tempImage];
        newImageView.frame = CGRectMake(x, y, width, height);
        [self.view addSubview:newImageView];
        [newImageView release];
        
        /*
        UIGraphicsBeginImageContext(CGSizeMake(backgroundView.bounds.size.width, backgroundView.bounds.size.height));		
        // get context
        //
        CGContextRef context = UIGraphicsGetCurrentContext();		
        
        // push context to make it current 
        // (need to do this manually because we are not drawing in a UIView)
        //
        UIGraphicsPushContext(context);								
        
        // drawing code comes here- look at CGContext reference
        // for available operations
        //
        // this example draws the inputImage into the context
        //
        [backgroundView.image drawInRect:CGRectMake(0,0,backgroundView.bounds.size.width, backgroundView.bounds.size.height)];
        [tempImage drawInRect:CGRectMake(x, y, width, height)];
        
        // pop context 
        //
        UIGraphicsPopContext();								
        
        // get a UIImage from the image context- enjoy!!!
        //
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // clean up drawing environment
        //
        UIGraphicsEndImageContext();
        
        backgroundView.image = outputImage;
        //*/
    }
    
    [args release];
}

// TODO: Reset all modules to the initial state
- (void)do_RT:(NSArray *)args {
    [self clearUI];
}

- (void)do_CU {
    [self clearUI];
}


//------------------ Stuff passed to TouchController --------------------
// TODO: Change this design pattern to use Categories/Class-Extensions

- (void)do_SC {
    [touchDelegate startClicks];
}
- (void)do_PC {
    [touchDelegate stopClicks];
}
- (void)do_ST {
    [touchDelegate startTouches];
}
- (void)do_PT {
    [touchDelegate stopTouches];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesCancelled:touches withEvent:event];
}

//-------------------- Other View stuff ------------------------

- (void)clearUI {
    NSLog(@"Clearing the UI");
    CGFloat
    x = self.view.frame.origin.x,
    y = self.view.frame.origin.y,
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    newImageView.frame = CGRectMake(x, y, width, height);
    [backgroundView removeFromSuperview];
    self.backgroundView = newImageView;
    [self.view addSubview:backgroundView];
    [newImageView release];
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
    NSLog(@"View loaded!");
    
    loadingIndicator.hidesWhenStopped = YES;
    [loadingIndicator startAnimating];
    
    backgroundView.image = [UIImage imageNamed:@"background.png"];
    
    UIBarButtonItem *exitItem = [[[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"Exit", @"")
								  style:UIBarButtonItemStyleBordered
								  target:self action:@selector(exitTrickplayApp:)] autorelease]; 
	self.navigationItem.rightBarButtonItem = exitItem;
    
    //[self startService];
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
    if (hostName) {
        [hostName release];
    }
    if (socketManager) {
        [socketManager release];
    }
    if (touchDelegate) {
        [(TouchController *)touchDelegate release];
    }
    [loadingIndicator release];
    [backgroundView release];
    [super dealloc];
}


@end
