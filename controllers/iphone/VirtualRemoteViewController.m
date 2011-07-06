//
//  VirtualRemoteViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VirtualRemoteViewController.h"

@implementation VirtualRemoteViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *clickSound = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"mp3"];
        clickSoundRef = (CFURLRef)[clickSound retain];
        AudioServicesCreateSystemSoundID(clickSoundRef, &audioClick);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark -
#pragma mark Button Click Handlers

- (void)playClick {
    fprintf(stderr, "click\n");
    //[[UIDevice currentDevice] playInputClick];
    
    AudioServicesPlaySystemSound(audioClick);
}

- (IBAction)rightPressed:(id)sender {
    NSLog(@"right button press");
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF53" thecount:1];
}

- (IBAction)leftPressed:(id)sender {
    NSLog(@"left button press");
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF51" thecount:1];
}

- (IBAction)downPressed:(id)sender {
    NSLog(@"down button press");
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF54" thecount:1];
}

- (IBAction)upPressed:(id)sender {
    NSLog(@"up button press");
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF52" thecount:1];
}

- (IBAction)OKPressed:(id)sender {
    NSLog(@"OK button press");
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF0D" thecount:1];
}

- (IBAction)backPressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"10000014" thecount:1];
}

- (IBAction)exitPressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"FF1B" thecount:1];
}

- (IBAction)redPressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"10000001" thecount:1];
}

- (IBAction)greenPressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"10000002" thecount:1];
}

- (IBAction)bluePressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"10000004" thecount:1];
}

- (IBAction)yellowPressed:(id)sender {
    [self playClick];
    [delegate sendKeyToTrickplay:@"10000003" thecount:1];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    NSLog(@"VirtualRemote dealloc");
    
    AudioServicesDisposeSystemSoundID(audioClick);
    CFRelease(clickSoundRef);
    delegate = nil;
    [super dealloc];
}

@end
