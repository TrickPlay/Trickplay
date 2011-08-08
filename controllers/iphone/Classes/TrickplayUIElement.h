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
#import "TrickplayAnimation.h"

@class AdvancedUIObjectManager;

@interface TrickplayUIElement : UIView <TrickplayAnimationDelegate> {
    CFMutableDictionaryRef activeTouches;
    NSUInteger touchNumber;
    
    /*
     NSNumber *x_scale;
     NSNumber *y_scale;
     NSNumber *z_scale;
     NSNumber *x_rotation;
     NSNumber *y_rotation;
     NSNumber *z_rotation;
    */
    
    CFAbsoluteTime start;
    
    CGFloat x_position;
    CGFloat y_position;
    CGFloat z_position;
    CGFloat w_size;
    CGFloat h_size;
    CGFloat x_scale;
    CGFloat y_scale;
    CGFloat z_scale;
    CGFloat x_rotation;
    CGFloat y_rotation;
    CGFloat z_rotation;
    CGFloat x_rot_point;
    CGFloat y_rot_point;
    CGFloat z_rot_point;
    CGFloat opacity;
    
    NSArray *clip;
    
    NSString *ID;
    NSString *name;
    
    // Needed for .is_animating property
    NSMutableDictionary *animations;
    
    AdvancedUIObjectManager *manager;
    
    UIView *view;
}

/*
@property (retain) NSNumber *x_scale;
@property (retain) NSNumber *y_scale;
@property (retain) NSNumber *z_scale;
@property (retain) NSNumber *x_rotation;
@property (retain) NSNumber *y_rotation;
@property (retain) NSNumber *z_rotation;
*/
 
@property (nonatomic, assign) AdvancedUIObjectManager *manager;
@property (retain) NSString *ID;
@property (retain) NSString *name;
@property (retain) NSArray *clip;
@property (retain) UIView *view;

@property (assign) CGFloat x_position;
@property (assign) CGFloat y_position;
@property (assign) CGFloat z_position;
@property (assign) CGFloat w_size;
@property (assign) CGFloat h_size;
@property (assign) CGFloat x_scale;
@property (assign) CGFloat y_scale;
@property (assign) CGFloat z_scale;
@property (assign) CGFloat x_rotation;
@property (assign) CGFloat y_rotation;
@property (assign) CGFloat z_rotation;
@property (assign) CGFloat x_rot_point;
@property (assign) CGFloat y_rot_point;
@property (assign) CGFloat z_rot_point;
@property (assign) CGFloat opacity;

- (id)initWithID:(NSString *)theID objectManager:(AdvancedUIObjectManager *)objectManager;

- (NSMutableDictionary *)createObjectJSONFromObject:(TrickplayUIElement *)object;

// Some new protocol stuff
- (id)callMethod:(NSString *)method withArgs:(NSArray *)args;

- (CGRect)getFrameFromArgs:(NSDictionary *)args;

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)args;
- (void)setValuesFromArgs:(NSDictionary *)args;
- (void)deleteValuesFromArgs:(NSDictionary *)args;

// Exposed function calls
- (id)do_raise_to_top:(NSArray *)args;
- (id)do_lower_to_bottom:(NSArray *)args;
- (id)do_unparent:(NSArray *)args;

- (void)addTouch:(UITouch *)touch;
- (void)removeTouch:(UITouch *)touch;
- (void)sendTouches:(NSArray *)touches withState:(NSString *)state;

- (void)handleTouchesBegan:(NSSet *)touches;
- (void)handleTouchesMoved:(NSSet *)touches;
- (void)handleTouchesEnded:(NSSet *)touches;
- (void)handleTouchesCancelled:(NSSet *)touches;

// Math stuff
- (CGFloat)get_x_prime;
- (CGFloat)get_x_prime_half:(CGFloat)z_rot_initial;
- (CGFloat)get_y_prime;
- (CGFloat)get_y_prime_half:(CGFloat)z_rot_initial;
- (CGFloat)get_bezier_middle_point_x:(CGFloat)x_initial :(CGFloat)z_rot_initial;
- (CGFloat)get_bezier_middle_point_y:(CGFloat)y_initial :(CGFloat)z_rot_initial;

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


