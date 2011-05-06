//
//  CameraViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"


@implementation CameraViewController

@synthesize editable;
@synthesize delegate;

- (id)initWithView:(UIView *)aView targetWidth:(CGFloat)width targetHeight:(CGFloat)height editable:(BOOL)is_editable mask:(UIImageView *)aMask {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.view = [[[UIView alloc] initWithFrame:aView.frame] autorelease];
        [aView addSubview:self.view];
        
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        //imagePickerController.cameraOverlayView = mask;
        
        mask = [aMask retain];
        targetWidth = width;
        targetHeight = height;
        editable = is_editable;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    
    NSURL *postURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", host, port, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-type"];
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
    
    [delegate finishedSendingImage];
}


#pragma mark -
#pragma mark Presenting and dissmissing the camera

- (void)presentTheCamera {
    NSLog(@"Presenting the Camera");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:NO];
            [popOverController release];
        }
        popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        CGRect frame = CGRectMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0, 20.0, 20.0);

        [popOverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentModalViewController:imagePickerController animated:YES];
    }
}

- (void)dismissTheCamera:(UIImagePickerController *)picker {
    NSLog(@"Dismissing the Camera");
    if (!picker) {
        picker = imagePickerController;
    }
    
    /*if (imageEditor) {
        [imagePickerController dismissModalViewControllerAnimated:NO];
        [imageEditor release];
        imageEditor = nil;
    }*/
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:NO];
            [popOverController release];
            popOverController = nil;
        }
    } else if (picker.parentViewController) {
        [picker.parentViewController dismissModalViewControllerAnimated:NO];
    }
    
    //[self.view removeFromSuperview];
}

- (void)dismissImageEditor {
    if (imageEditor) {
        [imageEditor.parentViewController dismissModalViewControllerAnimated:NO];
        [imageEditor release];
        imageEditor = nil;
    }
}

#pragma mark -
#pragma mark Image Editing

- (void)doneEditing:(UIImage *)imageToUse {
    [self dismissImageEditor];
    [self sendImage:imageToUse];
    //[delegate finishedPickingImage:imageToUse];

    //[self dismissTheCamera:nil];
}

- (void)cancelEditing {
    [self dismissImageEditor];
    [self.delegate canceledPickingImage];
    //[self dismissTheCamera:nil];
}

- (void)editImage:(UIImage *)image {
    if (imageEditor) {
        [imageEditor release];
    }
    imageEditor = [[ImageEditorViewController alloc] initWithNibName:@"ImageEditorViewController" bundle:nil];
    imageEditor.imageEditorDelegate = self;
    
    imageEditor.imageToEdit = image;
    imageEditor.targetWidth = targetWidth;
    imageEditor.targetHeight = targetHeight;
    imageEditor.mask = mask;
    
    UINavigationController *cntrl = [[UINavigationController alloc] initWithRootViewController:imageEditor];
    
    [self presentModalViewController:cntrl animated:YES];
    [cntrl release];
}

#pragma mark -
#pragma mark Image Data Handling

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        if (editable) {
            [self dismissTheCamera:picker];
            [self editImage:imageToUse];
        } else {
            [self sendImage:imageToUse];
            [self dismissTheCamera:picker];
        }
    } else if (CFStringCompare((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
    }
    
    [delegate finishedPickingImage:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissTheCamera:picker];
    
    [delegate canceledPickingImage];
}

#pragma mark -
#pragma mark Button press handlers

- (void)startCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"mask: %@", mask);
    imagePickerController.cameraOverlayView = mask;
    
    // Displays camera
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // Controls iOS standard image manipulation
    imagePickerController.allowsEditing = NO;
    
    [self presentTheCamera];
}

- (void)openLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        return;
    }
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    // Displays saved pictures and movies, if both are available
    imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Controls iOS standard image manipulation
    imagePickerController.allowsEditing = NO;
    
    [self presentTheCamera];
}

#pragma mark -
#pragma mark View controls

- (void)setMask:(UIImageView *)aMask {
    mask = aMask;
    [self.view addSubview:mask];
}

- (void)dealloc {
    NSLog(@"CameraViewController dealloc");
    
    [self dismissImageEditor];
    [self dismissTheCamera:imagePickerController];
    
    [imagePickerController release];
    imagePickerController = nil;
    
    if (mask) {
        [mask release];
    }
    
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
    
    [super dealloc];
}

@end
