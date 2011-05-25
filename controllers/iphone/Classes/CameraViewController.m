//
//  CameraViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"


@implementation CameraViewController

@synthesize cameraButton;
@synthesize imageLibraryButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        backgroundView = nil;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark - Networking stuff


- (void)setupService:(NSInteger)thePort host:(NSString *)theHost path:(NSString *)thePath delegate:theDelegate {
    port = thePort;
    host = [theHost retain];
    path = [thePath retain];
    delegate = theDelegate;
    
    connections = [[NSMutableArray alloc] initWithCapacity:20];
}

- (void)sendImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSURL *postURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", host, port, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"image/png" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d", [imageData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:imageData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"Connection to URL %@ could not be established", postURL);
        return;
    }
    
    [connections addObject:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    NSLog(@"Received Data: %@", incrementalData);
    /** the data isn't necessary for now
    BOOL dataCreated = NO;
    int i;
    for (i = 0; [connections count]; i++) {
        if ([connections objectAtIndex:i] == connection) {
            dataCreated = YES;
        }
    }
    if (!dataCreated) {
        NSMutableData *data = [[[NSMutableData alloc] initWithCapacity:10000] autorelease];
        [connections setObject:data forKey:connection];
    }
    
    [(NSMutableData *)[connections objectForKey:connection] appendData:incrementalData];
     //*/ 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Camera finished posting image for connection: %@", connection);
    [connection cancel];
    
    [connections removeObject:connection];
    
    [delegate finishedSendingImage];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Camera POST fail with error: %@", error);
    [connection cancel];
    
    [connections removeObject:connection];
}


#pragma mark - View lifecycle

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

#pragma mark -
#pragma mark Presenting and dissmissing the camera

- (void)presentTheCamera {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:NO];
            [popOverController release];
        }
        popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        CGRect frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        [popOverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentModalViewController:imagePickerController animated:YES];
    }
}

- (void)dismissTheCamera:(UIImagePickerController *)picker {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:NO];
            [popOverController release];
            popOverController = nil;
        }
    } else {
        [[picker parentViewController] dismissModalViewControllerAnimated:NO];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Image Data Handling

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked form a photo album
    if (CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        if (backgroundView) {
            [backgroundView removeFromSuperview];
            [backgroundView release];
        }
        
        /**for Testing
        CGFloat
        x = self.view.frame.origin.x,
        y = self.view.frame.origin.y,
        width = self.view.frame.size.width,
        height = self.view.frame.size.height;
        
        backgroundView = [[UIImageView alloc] initWithImage:imageToUse];
        backgroundView.frame = CGRectMake(x, y, width, height);
        [self.view addSubview:backgroundView];
        [self.view sendSubviewToBack:backgroundView];
        //*/
        
        [self sendImage:imageToUse];
    } else if (CFStringCompare((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
    }
    
    [self dismissTheCamera:picker];
    
    [delegate finishedPickingImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissTheCamera:picker];
    
    [delegate canceledPickingImage];
}

#pragma mark - Button press handlers
#pragma mark --

- (IBAction)startCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //Displays camera
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    //Hides the controls for image manipulation for now
    imagePickerController.allowsEditing = NO;
    
    [self presentTheCamera];
}

- (IBAction)openLibrary:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        return;
    }
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hids the controls for image manipulation for now
    imagePickerController.allowsEditing = NO;
    
    [self presentTheCamera];
}



- (void)dealloc {
    NSLog(@"CameraViewController dealloc");
    
    [self dismissTheCamera:imagePickerController];
    
    [imagePickerController release];
    imagePickerController = nil;
    self.imageLibraryButton = nil;
    self.cameraButton = nil;
    if (backgroundView) {
        [backgroundView release];
    }
    backgroundView = nil;
    
    if (host) {
        [host release];
    }
    host = nil;
    if (path) {
        [path release];
    }
    path = nil;
    
    if (connections) {
        for (NSURLConnection *connection in connections) {
            [connection cancel];
        }
        [connections release];
    }
    if (popOverController) {
        [popOverController dismissPopoverAnimated:NO];
        [popOverController release];
    }
    
    [super dealloc];
}

@end
