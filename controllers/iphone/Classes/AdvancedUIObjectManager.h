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

@interface AdvancedUIObjectManager : NSObject <AdvancedUIDelegate> {
    NSMutableDictionary *rectangles;
    NSMutableDictionary *images;
    NSMutableDictionary *textFields;
    NSMutableDictionary *groups;
    
    UIView *view;
}

@property (nonatomic, retain) NSMutableDictionary *rectangles;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *textFields;
@property (nonatomic, retain) NSMutableDictionary *groups;

- (id)initWithView:(UIView *)aView;

- (void)createObject:(NSString *)JSON_String;

@end
