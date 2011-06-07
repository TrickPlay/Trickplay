//
//  CommandInterpreterAdvancedUI.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommandInterpreterAdvancedUI.h"


@implementation CommandInterpreterAdvancedUI

@synthesize delegate;

- (id)init:(id)theDelegate {
    if ((self = [super init])) {
        commandLine = [[NSMutableString alloc] initWithCapacity:40];
        
        delegate = (id <CommandInterpreterAdvancedUIDelegate>)theDelegate;
        
        //[self createCommandDictionary];
    }
    
    return self;
}

- (void)interpretCommand:(NSString *)command {
    if (!delegate) {
        return;
    }
    
    NSLog(@"AdvancedUI Command received: %@", command);
    NSDictionary *JSON_Object = [command yajl_JSON];
    NSLog(@"object: %@", JSON_Object);
    
    NSString *method = [JSON_Object objectForKey:@"method"];
    NSLog(@"method: %@", method);
    if ([method compare:@"create"] == NSOrderedSame) {
        [delegate createObject:JSON_Object];
    } else if ([method compare:@"set"] == NSOrderedSame) {
        [delegate setValuesForObject:JSON_Object];
    } else if ([method compare:@"get"] == NSOrderedSame) {
        [delegate getValuesForObject:JSON_Object];
    } else if ([method compare:@"call"] == NSOrderedSame) {
        [delegate callMethodOnObject:JSON_Object];
    } else if ([method compare:@"delete"] == NSOrderedSame) {
        [delegate deleteValuesForObject:JSON_Object];
    } else {
        NSLog(@"AdvancedUI Command not recognized");
    }
}

- (void)executeCommand:(NSString *)command args:(NSArray *)args {
    
}

- (void)dealloc {
    NSLog(@"Command Interpreter for Advanced UI dealloc");
    self.delegate = nil;
    [super dealloc];
}

@end
