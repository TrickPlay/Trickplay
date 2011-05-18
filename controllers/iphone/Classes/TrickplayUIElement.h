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

@interface TrickplayUIElement : UIView {
    BOOL is_scaled;
    NSArray *clip;
    
    NSString *ID;
    NSString *name;
    
    UIView *view;
}

@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *clip;
@property (nonatomic, retain) UIView *view;

- (id)initWithID:(NSString *)theID;

// Some new protocol stuff
- (id)callMethod:(NSString *)method withArgs:(NSArray *)args;

- (CGRect)getFrameFromArgs:(NSDictionary *)args;
//** TODO refactor all this code to use method dispatching
//** from a dictionary by mapping methods to property names
- (void)setPostionFromArgs:(NSDictionary *)args;
- (void)setSizeFromArgs:(NSDictionary *)args;
- (void)setAnchorPointFromArgs:(NSDictionary *)args;
- (void)setScaleFromArgs:(NSDictionary *)args;
- (void)setRotationsFromArgs:(NSDictionary *)args;
- (void)setOpacityFromArgs:(NSDictionary *)args;

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)args;
- (void)setValuesFromArgs:(NSDictionary *)args;

// Exposed function calls
- (id)do_raise_to_top:(NSArray *)args;
- (id)do_lower_to_bottom:(NSArray *)args;

@end
