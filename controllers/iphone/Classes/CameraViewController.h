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
    UIButton *cameraButton;
    UIButton *imageLibraryButton;
    
    UIImagePickerController *imagePickerController;
    UIImageView *backgroundView;
    
    NSInteger port;
    NSString *host;
    NSString *path;
    
    NSMutableDictionary *connections;
    
    id <CameraViewControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *imageLibraryButton;
@property (assign) id <CameraViewControllerDelegate> delegate;

- (IBAction)startCamera:(id)sender;
- (IBAction)openLibrary:(id)sender;

- (void)setupService:(NSInteger)thePort host:(NSString *)theHost path:(NSString *)thePath delegate:theDelegate;

@end
