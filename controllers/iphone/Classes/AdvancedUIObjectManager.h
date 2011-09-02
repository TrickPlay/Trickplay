//
//  AdvancedUIObjectManager.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>
#import "TPAppViewController.h"
#import "TrickplayTimeline.h"

@class TrickplayUIElement;
@class TrickplayGroup;

@interface AdvancedUIObjectManager : NSObject <AdvancedUIDelegate, SocketManagerDelegate, CommandInterpreterAdvancedUIDelegate> {
    NSMutableDictionary *rectangles;
    NSMutableDictionary *images;
    NSMutableDictionary *textFields;
    NSMutableDictionary *webTexts;
    NSMutableDictionary *groups;
    NSUInteger currentID;
    
    ResourceManager *resourceManager;
    SocketManager *socketManager;
    
    TrickplayTimeline *timeLine;
    
    NSString *hostName;
    NSInteger port;
    
    TrickplayGroup *view;
    
    TPAppViewController *appViewController;
}

@property (nonatomic, retain) NSMutableDictionary *rectangles;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *textFields;
@property (nonatomic, retain) NSMutableDictionary *webTexts;
@property (nonatomic, retain) NSMutableDictionary *groups;

@property (nonatomic, retain) ResourceManager *resourceManager;

@property (assign) TPAppViewController *appViewController;

- (id)initWithView:(TrickplayGroup *)aView resourceManager:(ResourceManager *)aResourceManager;

- (void)setupServiceWithPort:(NSInteger)p
                    hostname:(NSString *)h;
- (BOOL)startServiceWithID:(NSString *)ID;

- (void)storeObject:(TrickplayUIElement *)object;

- (void)clean;

// New protocol
- (TrickplayUIElement *)findObjectForID:(NSString *)ID;

@end
