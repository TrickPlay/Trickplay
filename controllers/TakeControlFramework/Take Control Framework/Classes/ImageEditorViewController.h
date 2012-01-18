//
//  ImageEditorViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureImageView.h"

@protocol ImageEditorDelegate <NSObject>

@required
- (void)doneEditing:(UIImage *)imageToUse;
- (void)cancelEditing;

@end

@interface ImageEditorViewController : UIViewController <UINavigationControllerDelegate, GestureImageViewDelegate> {
    UIImage *imageToEdit;
    CGFloat targetWidth;
    CGFloat targetHeight;
    UIView *mask;
    
    GestureImageView *imageView;
    UINavigationBar *navBar;
    UIToolbar *toolbar;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *helpButton;
    NSString *cancelButtonTitle;
    
    UIPopoverController *helpPopover;
    
    id <ImageEditorDelegate> imageEditorDelegate;
}

@property (retain) UIImage *imageToEdit;
@property (assign) CGFloat targetWidth;
@property (assign) CGFloat targetHeight;
@property (retain) UIView *mask;

@property (retain) IBOutlet UINavigationBar *navBar;
@property (retain) IBOutlet UIToolbar *toolbar;
@property (retain) IBOutlet UIBarButtonItem *cancelButton;
@property (retain) IBOutlet UIBarButtonItem *helpButton;

@property (assign) id <ImageEditorDelegate> imageEditorDelegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)title cancelLabel:(NSString *)cancelLabel;

- (void)editImage:(UIImage *)image;

- (void)adjustImageOrientation;

- (IBAction)doneEditing;
- (IBAction)cancelEditing;
- (IBAction)help:(id)sender;

@end
