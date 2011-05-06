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

@interface ImageEditorViewController : UIViewController <UINavigationControllerDelegate> {
    UIImage *imageToEdit;
    CGFloat targetWidth;
    CGFloat targetHeight;
    UIImageView *mask;
    
    GestureImageView *imageView;
    UIToolbar *toolbar;
    UILabel *label;
    
    id <ImageEditorDelegate> imageEditorDelegate;
}

@property (retain) UIImage *imageToEdit;
@property (assign) CGFloat targetWidth;
@property (assign) CGFloat targetHeight;
@property (retain) UIImageView *mask;

@property (retain) IBOutlet UIToolbar *toolbar;
@property (retain) IBOutlet UILabel *label;

@property (assign) id <ImageEditorDelegate> imageEditorDelegate;


- (void)editImage:(UIImage *)image;

- (IBAction)doneEditing;
- (IBAction)cancelEditing;

@end
