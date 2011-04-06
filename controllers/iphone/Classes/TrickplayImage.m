//
//  TrickplayImage.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayImage.h"


@implementation TrickplayImage

- (id)initWithID:(NSString *)imageID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager {
    if ((self = [super init])) {
        CGRect frame = [self getFrameFromArgs:args];
        
        self.view = [resourceManager fetchImageViewUsingResource:imageID frame:frame];
    }
        
    return self;
}

- (void)dealloc {
    NSLog(@"TrickplayImage dealloc");
    
    [super dealloc];
}

@end
