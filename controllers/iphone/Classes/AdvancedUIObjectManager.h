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

@interface AdvancedUIObjectManager : NSObject <AdvancedUIDelegate, SocketManagerDelegate, CommandInterpreterAdvancedUIDelegate> {
    NSMutableDictionary *rectangles;
    NSMutableDictionary *images;
    NSMutableDictionary *textFields;
    NSMutableDictionary *groups;
    NSUInteger currentID;
    
    ResourceManager *resourceManager;
    SocketManager *socketManager;
    
    NSString *hostName;
    NSInteger port;
    
    UIView *view;
}

@property (nonatomic, retain) NSMutableDictionary *rectangles;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *textFields;
@property (nonatomic, retain) NSMutableDictionary *groups;

@property (nonatomic, retain) ResourceManager *resourceManager;

- (id)initWithView:(UIView *)aView resourceManager:(ResourceManager *)aResourceManager;

- (void)setupServiceWithPort:(NSInteger)p
                    hostname:(NSString *)h;
- (BOOL)startServiceWithID:(NSString *)ID;

- (void)clean;

- (void)createObjects:(NSArray *)JSON_Array;
- (void)destroyObjects:(NSArray *)JSON_Array;
- (void)setValuesForObjects:(NSArray *)JSON_Array;

// New protocol
- (TrickplayUIElement *)findObjectForID:(NSString *)ID;

@end
