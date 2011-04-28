//
//  CameraViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@protocol CameraViewControllerDelegate <NSObject>

@required
- (void)finishedPickingImage;
- (void)finishedSendingImage;
- (void)canceledPickingImage;

@end

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIImagePickerController *imagePickerController;
    UIPopoverController *popOverController;
    
    NSInteger port;
    NSString *host;
    NSString *path;
    
    NSMutableArray *connections;
    
    id <CameraViewControllerDelegate> delegate;
}

@property (assign) id <CameraViewControllerDelegate> delegate;

- (id)initWithView:(UIView *)aView;

- (void)startCamera;
- (void)openLibrary;

- (void)setupService:(NSInteger)thePort host:(NSString *)theHost path:(NSString *)thePath delegate:theDelegate;

@end
