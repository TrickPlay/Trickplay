//
//  CommandInterpreterAdvancedUI.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>
#import "CommandInterpreter.h"


@protocol CommandInterpreterAdvancedUIDelegate <NSObject>

@required
- (void)createObject:(NSDictionary *)object;
- (void)setValuesForObject:(NSDictionary *)object;
- (void)callMethodOnObject:(NSDictionary *)object;

@end


@interface CommandInterpreterAdvancedUI : CommandInterpreter {
    id <CommandInterpreterAdvancedUIDelegate> delegate;
}

@property (nonatomic, assign) id <CommandInterpreterAdvancedUIDelegate> delegate;

@end
