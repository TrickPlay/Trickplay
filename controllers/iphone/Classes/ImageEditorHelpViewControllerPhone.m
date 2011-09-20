//
//  ImageEditorHelpViewControllerPhone.m
//  TrickplayController
//
//  Created by Rex Fenley on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageEditorHelpViewControllerPhone.h"

@implementation ImageEditorHelpViewControllerPhone

//@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Help"];
    navItem.rightBarButtonItem = doneButton;
    [navBar pushNavigationItem:navItem animated:YES];
    [doneButton release];
    [navItem release];
    //*/
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //self.navBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)donePressed:(id)sender {
    NSLog(@"WTF");
    if (self.parentViewController) {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    //self.navBar = nil;
    
    [super dealloc];
}

@end
