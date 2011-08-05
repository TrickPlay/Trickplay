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
    /* for testing socket speed
    [delegate respondInstantly];
    if (YES) {
        return;
    }
    //*/
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();

    fprintf(stderr, "\n\nAdvancedUI Command received: %s\n\n", [command UTF8String]);
    NSDictionary *JSON_Object = [command yajl_JSON];
    //NSLog(@"object: %@", JSON_Object);
    
    CFAbsoluteTime beforecalltime = CFAbsoluteTimeGetCurrent();
    
    //NSLog(@"JSON parsing time = %lf", (beforecalltime - now)*1000.0);
    fprintf(stderr, "JSON parsing time = %lf\n", (beforecalltime - now)*1000.0);
    
    NSString *method = [JSON_Object objectForKey:@"method"];
    //NSLog(@"method: %@", method);
    if ([method compare:@"create"] == NSOrderedSame) {
        //CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

        [delegate createObject:JSON_Object];
        
        //CFAbsoluteTime stop = CFAbsoluteTimeGetCurrent();
        //CFAbsoluteTime start2 = CFAbsoluteTimeGetCurrent();

        //NSLog(@"Create Object Time = %lf", (stop - start)*1000.0);
        //CFAbsoluteTime stop2 = CFAbsoluteTimeGetCurrent();
        //NSLog(@"Create Object Time = %lf", (stop2 - start2)*1000.0);
    } else if ([method compare:@"set"] == NSOrderedSame) {
        [delegate setValuesForObject:JSON_Object];
    } else if ([method compare:@"get"] == NSOrderedSame) {
        [delegate getValuesForObject:JSON_Object];
    } else if ([method compare:@"call"] == NSOrderedSame) {
        [delegate callMethodOnObject:JSON_Object];
    } else if ([method compare:@"delete"] == NSOrderedSame) {
        [delegate deleteValuesForObject:JSON_Object];
    } else if ([method compare:@"destroy"] == NSOrderedSame) {
        [delegate destroyObject:JSON_Object];
    } else {
        NSLog(@"AdvancedUI Command not recognized");
    }
    
    CFAbsoluteTime aftercalltime = CFAbsoluteTimeGetCurrent();
    fprintf(stderr, "Call time = %lf\n", (aftercalltime - beforecalltime)*1000.0);
    
    //NSLog(@"Call time = %lf", (aftercalltime - beforecalltime)*1000.0);
    //NSLog(@"Total command interpreting time = %lf", (aftercalltime - now)*1000.0);
}

- (void)executeCommand:(NSString *)command args:(NSArray *)args {
    
}

- (void)dealloc {
    NSLog(@"Command Interpreter for Advanced UI dealloc");
    self.delegate = nil;
    [super dealloc];
}

@end
