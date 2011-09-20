//
//  TrickplayRectangle.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransform3D.h>
#import "TrickplayUIElement.h"

@interface TrickplayRectangle : TrickplayUIElement {

}

- (id)initWithID:(NSString *)rectID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager;

@end
