//
//  AdvancedUIObjectManager.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>
#import "GestureViewController.h"

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
    
    NSString *hostName;
    NSInteger port;
    
    TrickplayGroup *view;
    
    GestureViewController *gestureViewController;
}

@property (nonatomic, retain) NSMutableDictionary *rectangles;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *textFields;
@property (nonatomic, retain) NSMutableDictionary *webTexts;
@property (nonatomic, retain) NSMutableDictionary *groups;

@property (nonatomic, retain) ResourceManager *resourceManager;

@property (assign) GestureViewController *gestureViewController;

- (id)initWithView:(TrickplayGroup *)aView resourceManager:(ResourceManager *)aResourceManager;

- (void)setupServiceWithPort:(NSInteger)p
                    hostname:(NSString *)h;
- (BOOL)startServiceWithID:(NSString *)ID;

- (void)storeObject:(TrickplayUIElement *)object;

- (void)clean;

// New protocol
- (TrickplayUIElement *)findObjectForID:(NSString *)ID;

@end
