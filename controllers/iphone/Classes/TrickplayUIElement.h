//
//  TrickplayUIElement.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransform3D.h>
#import <YAJLiOS/YAJL.h>
#import "AdvancedUIObjectManager.h"

@class AdvancedUIObjectManager;

@interface TrickplayUIElement : UIView {
    BOOL is_scaled;
    NSArray *clip;
    
    NSString *ID;
    NSString *name;
    
    AdvancedUIObjectManager *manager;
    
    UIView *view;
}

@property (nonatomic, assign) AdvancedUIObjectManager *manager;
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *clip;
@property (nonatomic, retain) UIView *view;

- (id)initWithID:(NSString *)theID objectManager:(AdvancedUIObjectManager *)objectManager;

// Some new protocol stuff
- (id)callMethod:(NSString *)method withArgs:(NSArray *)args;

- (CGRect)getFrameFromArgs:(NSDictionary *)args;

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)args;
- (void)setValuesFromArgs:(NSDictionary *)args;

// Exposed function calls
- (id)do_raise_to_top:(NSArray *)args;
- (id)do_lower_to_bottom:(NSArray *)args;

@end


/**
 * List of completed properties, functions, etc.
 */

/** setters
- (void)set_name:(NSDictionary *)args;
- (void)set_x:(NSDictionary *)args;
- (void)set_y:(NSDictionary *)args;
- (void)set_z:(NSDictionary *)args;
- (void)set_depth:(NSDictionary *)args;
- (void)set_w:(NSDictionary *)args;
- (void)set_h:(NSDictionary *)args;
- (void)set_width:(NSDictionary *)args;
- (void)set_height:(NSDictionary *)args;
- (void)set_position:(NSDictionary *)args; 
- (void)set_size:(NSDictionary *)args; 
- (void)set_anchor_point:(NSDictionary *)args;
- (void)set_scale:(NSDictionary *)args;
- (void)set_x_rotation:(NSDictionary *)args;
- (void)set_y_rotation:(NSDictionary *)args;
- (void)set_z_rotation:(NSDictionary *)args;
- (void)set_opacity:(NSDictionary *)args;
- (void)set_clip:(NSDictionary *)args;
**/

/** getters
- (void)get_name:(NSMutableDictionary *)dictionary;
- (void)get_position:(NSMutableDictionary *)dictionary;
- (void)get_x:(NSMutableDictionary *)dictionary;
- (void)get_y:(NSMutableDictionary *)dictionary;
- (void)get_z:(NSMutableDictionary *)dictionary;
- (void)get_size:(NSMutableDictionary *)dictionary;
- (void)get_w:(NSMutableDictionary *)dictionary;
- (void)get_width:(NSMutableDictionary *)dictionary;
- (void)get_h:(NSMutableDictionary *)dictionary;
- (void)get_height:(NSMutableDictionary *)dictionary;
- (void)get_anchor_point:(NSMutableDictionary *)dictionary;
- (void)get_scale:(NSMutableDictionary *)dictionary;
- (void)get_x_rotation:(NSMutableDictionary *)dictionary;
- (void)get_y_rotation:(NSMutableDictionary *)dictionary;
- (void)get_z_rotation:(NSMutableDictionary *)dictionary;
- (void)get_opacity:(NSMutableDictionary *)dictionary;
- (void)get_clip:(NSMutableDictionary *)dictionary;
- (void)get_parent:(NSMutableDictionary *)dictionary;
- (void)get_center:(NSMutableDictionary *)dictionary;
**/

/** functions
- (id)do_set:(NSArray *)args;
- (id)do_hide:(NSArray *)args;
- (id)do_hide_all:(NSArray *)args;
- (id)do_show:(NSArray *)args;
- (id)do_show_all:(NSArray *)args;
- (id)do_move_by:(NSArray *)args;
- (id)do_unparent:(NSArray *)args;
- (id)do_raise:(NSArray *)args;
- (id)do_raise_to_top:(NSArray *)args;
- (id)do_lower:(NSArray *)args;
- (id)do_lower_to_bottom:(NSArray *)args;
- (id)do_move_anchor_point:(NSArray *)args;
- (id)do_transform_point:(NSArray *)args;
**/


