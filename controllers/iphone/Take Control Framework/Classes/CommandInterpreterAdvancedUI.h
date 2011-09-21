//
//  CommandInterpreterAdvancedUI.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandInterpreter.h"
#import <YAJLiOS/YAJL.h>


@protocol CommandInterpreterAdvancedUIDelegate <NSObject>

@optional
- (void)respondInstantly;

@required
- (void)createObject:(NSDictionary *)object;
- (void)setValuesForObject:(NSDictionary *)object;
- (void)getValuesForObject:(NSDictionary *)object;
- (void)callMethodOnObject:(NSDictionary *)object;
- (void)deleteValuesForObject:(NSDictionary *)object;
- (void)destroyObject:(NSDictionary *)object;

@end


@interface CommandInterpreterAdvancedUI : CommandInterpreter {
    id <CommandInterpreterAdvancedUIDelegate> delegate;
}

@property (nonatomic, assign) id <CommandInterpreterAdvancedUIDelegate> delegate;

@end
