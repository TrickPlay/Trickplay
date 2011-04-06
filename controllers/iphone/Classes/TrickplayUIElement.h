//
//  TrickplayUIElement.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrickplayUIElement : UIView {
    CGFloat x, y, width, height;
    NSArray *scale;
    BOOL is_scaled;
    
    UIView *view;
}

@property (nonatomic, retain) NSArray *scale;
@property (nonatomic, retain) UIView *view;

- (CGRect)getFrameFromArgs:(NSDictionary *)args;
- (void)setValuesWithArgs:(NSDictionary *)args;

@end
