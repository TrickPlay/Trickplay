//
//  ImageEditorViewController.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageEditorViewController.h"
#import "ImageEditorHelpViewControllerPhone.h"

@implementation ImageEditorViewController

@synthesize imageToEdit;
@synthesize targetWidth;
@synthesize targetHeight;
@synthesize mask;
@synthesize navBar;
@synthesize toolbar;
@synthesize cancelButton;
@synthesize helpButton;
@synthesize imageEditorDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)title cancelLabel:(NSString *)cancelLabel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cancelButton.title = cancelLabel;
        cancelButtonTitle = [cancelLabel retain];
        helpPopover = nil;
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
#pragma mark Consume Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark -
#pragma mark Image Editing

- (void)editImage:(UIImage *)image {
    if (!image) {
        image = imageToEdit;
    }

    imageView = [[GestureImageView alloc] initWithImage:image];
    imageView.delegate = self;
    
    [self.view addSubview:imageView];
    
    if (mask) {
        mask.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:mask];
        mask.userInteractionEnabled = NO;
    }
    
    [toolbar.superview bringSubviewToFront:toolbar];
    [navBar.superview bringSubviewToFront:navBar];
    
    [self adjustImageOrientation];
}

- (UIImage*)imageByCropping:(GestureImageView *)imageViewToCrop toRect:(CGRect)rect {
    
    // Begin context and fill the cropping rectangle with black
    UIImage *imageToCrop = imageViewToCrop.image;
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor]);
    CGContextFillRect(context, rect);
    
    
    //*
    // Find normalization factors for scaling
    CGFloat imageAspectRatio = imageView.image.size.width / imageView.image.size.height;
    
    CGFloat viewAspectRatio = rect.size.width / rect.size.height;
    
    CGFloat widthScaleFactor = 1.0;
    CGFloat heightScaleFactor = 1.0;
    if (imageAspectRatio > viewAspectRatio) {  // width restricted
        CGFloat scaleFactor = rect.size.width / imageView.image.size.width;
        heightScaleFactor = scaleFactor * imageView.image.size.height / rect.size.height;
    } else {
        CGFloat scaleFactor = rect.size.height / imageView.image.size.height;
        widthScaleFactor = scaleFactor * imageView.image.size.width / rect.size.width;
    }
    ///////////////////////////////////////
    
    
    // Translate so center of image is at upper corner, Rotate, and Scale
    // then translate back.
    CGContextTranslateCTM(context, rect.size.width/2, rect.size.height/2);
    CGContextRotateCTM(context, imageViewToCrop.totalRotation);
    CGContextScaleCTM(context, imageViewToCrop.xScale * widthScaleFactor, imageViewToCrop.yScale * heightScaleFactor);
    CGContextTranslateCTM(context, -rect.size.width/2, -rect.size.height/2);
    
    
    // Translate the image
    CGFloat x = imageViewToCrop.xTranslation * rect.size.width/imageViewToCrop.frame.size.width;
    CGFloat y = imageViewToCrop.yTranslation * rect.size.height/imageViewToCrop.frame.size.height;
    
    // Correct for change of basis caused by a rotation if translating
    if (x || y) {
        CGFloat xScale = imageViewToCrop.xScale;
        CGFloat r = sqrtf(powf(x, 2.0) + powf(y, 2.0));
        CGFloat theta = !x ? M_PI/2 * y/fabs(y) : atanf(y/x);
        theta -= imageViewToCrop.totalRotation;
        CGFloat x_multiplier = 1.0;
        CGFloat y_multiplier = 1.0;
        // Correct for quadrant with consideration of inversed y-axis
        // 1st quadrant
        if (x * xScale/fabs(xScale) > 0.0 && y > 0.0) {
            // no change
        // 2nd quadrant
        } else if (x * xScale/fabs(xScale) < 0.0 && y > 0.0) {
            x_multiplier = -1.0;
            y_multiplier = -1.0;
        // 3rd
        } else if (x * xScale/fabs(xScale) < 0.0 && y < 0.0) {
            x_multiplier = -1.0;
            y_multiplier = -1.0;
        // 4th
        } else if (x * xScale/fabs(xScale) > 0.0 && y < 0.0) {
            // no change
        }
        x = r * cos(theta); // * x_multiplier;
        y = r * sin(theta); // * y_multiplier;
        
        x *= x_multiplier;
        y *= y_multiplier;
        y *= xScale/fabs(xScale);
    }
    //*/
    
    CGContextTranslateCTM(context, x, y);
    
    [imageToCrop drawInRect:rect];
    //*/
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (IBAction)doneEditing {
    //UIImage *croppedImage = [self imageByCropping:imageView toRect:CGRectMake(0.0, 0.0, (targetWidth > 0.0 ? targetWidth : imageView.image.size.width), (targetHeight > 0.0 ? targetHeight : imageView.image.size.height))];
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat viewWidth = screenFrame.size.width;
    CGFloat viewHeight = screenFrame.size.height;
    
    UIImage *croppedImage = [self imageByCropping:imageView toRect:CGRectMake(0.0, 0.0, (targetWidth > 0.0 ? targetWidth : viewWidth), (targetHeight > 0.0 ? targetHeight : viewHeight))];
    
    [imageEditorDelegate doneEditing:croppedImage];
}

- (IBAction)cancelEditing {
    [imageEditorDelegate cancelEditing];
}

#pragma mark -
#pragma mark Help

- (IBAction)help:(id)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (helpPopover) {
            [helpPopover dismissPopoverAnimated:NO];
            [helpPopover release];
            helpPopover = nil;
        }
        UIViewController *popoverContent = [[UIViewController alloc] initWithNibName:@"ImageEditorHelpViewPad" bundle:nil];
        popoverContent.contentSizeForViewInPopover = CGSizeMake(250, 180);
        helpPopover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        [helpPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        [popoverContent release];
    } else {
        NSBundle *myBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/TakeControl.framework"]];
        UIViewController *helpModal = [[ImageEditorHelpViewControllerPhone alloc] initWithNibName:@"ImageEditorHelpViewControllerPhone" bundle:myBundle];
        [self presentModalViewController:helpModal animated:YES];
        [helpModal release];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [helpPopover release];
    helpPopover = nil;
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    cancelButton.title = cancelButtonTitle;
    navBar.alpha = .75;
    // Do any additional setup after loading the view from its nib.
    [self editImage:imageToEdit];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self editImage:imageToEdit];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    self.toolbar = nil;
    self.cancelButton = nil;
    self.helpButton = nil;
    self.navBar = nil;
    self.mask = nil;
}

#pragma mark -
#pragma mark Orientation and Auto-Rotation

- (void)adjustImageOrientation {
    BOOL imageWasFlipped = (imageView.xScale < 0);
    [imageView resetImage];
    if (imageWasFlipped) {
        [imageView flipImage];
    }
    
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat viewWidth = screenFrame.size.width;
    CGFloat viewHeight = screenFrame.size.height;// - toolbar.frame.size.height;
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        viewWidth = screenFrame.size.height;
        viewHeight = screenFrame.size.width;// - toolbar.frame.size.height;
    }
    
    CGFloat imageAspectRatio = imageView.image.size.width / imageView.image.size.height;
    
    CGFloat viewAspectRatio = viewWidth / viewHeight;
    
    CGFloat scaleFactor = 1.0;
    if (imageAspectRatio > viewAspectRatio) {  // height restricted
        scaleFactor = viewWidth / imageView.image.size.width;
    } else {
        scaleFactor = viewHeight / imageView.image.size.height;
    }
    
    [imageView scaleImageTo:scaleFactor];
    [imageView setPositionTo:CGPointMake(viewWidth/2.0 - imageView.image.size.width/2.0, viewHeight/2.0 - imageView.image.size.height/2.0)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustImageOrientation];
    
    //////////
    // Help menu text alignment fix
    if (helpPopover) {
        [helpPopover dismissPopoverAnimated:NO];
        [self help:helpButton];
    }
}

#pragma mark -
#pragma mark GestureImageViewDelegate methods

- (void)gestureImageViewDidTripleTap:(GestureImageView *)gestureImageView {
    [self adjustImageOrientation];
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    if (toolbar) {
        [toolbar release];
        toolbar = nil;
    }
    if (navBar) {
        [navBar release];
        navBar = nil;
    }
    if (cancelButton) {
        [cancelButton release];
        cancelButton = nil;
    }
    self.mask = nil;
    if (imageToEdit) {
        [imageToEdit release];
    }
    if (imageView) {
        [imageView release];
    }
    if (cancelButtonTitle) {
        [cancelButtonTitle release];
        cancelButtonTitle = nil;
    }
    if (helpPopover) {
        [helpPopover dismissPopoverAnimated:YES];
        [helpPopover release];
        helpPopover = nil;
    }
    
    [super dealloc];
}

@end
