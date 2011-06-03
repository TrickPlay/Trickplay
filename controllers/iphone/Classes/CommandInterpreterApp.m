//
//  CommandInterpreter.m
//  Services-test
//
//  Created by Rex Fenley on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommandInterpreterApp.h"


@implementation CommandInterpreterApp

@synthesize delegate;

/**
 * Initialize and create a mutable string that will act as the command line.
 */
- (id)init:(id)theDelegate {
    if ((self = [super init])) {
        commandLine = [[NSMutableString alloc] initWithCapacity:40];
        
        delegate = theDelegate;
        
        firstCommand = YES;
        
        //[self createCommandDictionary];
    }
    
    return self;
}


- (void)interpretCommand:(NSString *)command {
    //NSLog(@"Received command: %@", command);
    
    NSArray *components = [[command componentsSeparatedByString:@"\t"] retain];
    NSMutableArray *args = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    
    int i;
    for (i = 1; i < [components count]; i++) {
        //fprintf(stderr, "arg: %s\n", [[components objectAtIndex:i] UTF8String]);
        [args addObject:[components objectAtIndex:i]];
    }
    
    NSString *key = [[[components objectAtIndex:0] retain] autorelease];
    [self executeCommand:key args:args];
    [components release];
}

- (void)executeCommand:(NSString *)command args:(NSArray *)args {
    if (!delegate) {
        return;
    }
    //NSLog(@"CommandInterpreterApp delegate: %@", delegate);
    /*
    SEL method = (SEL)[commandDictionary objectForKey:key];
    if (method) {
        [delegate performSelector:method withObject:args];
    } else {
        fprintf(stderr, "Unrecognized command %s\n", [key UTF8String]);
    }
    //*/
    if (firstCommand) {
        if ([command compare:@"WM"] == NSOrderedSame) {
            [delegate do_WM:args];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushAppBrowserNotification" object:self];
        firstCommand = NO;
    }
    if ([command compare:@"MC"] == NSOrderedSame) {
        [delegate do_MC:args];
    } else if ([command compare:@"DR"] == NSOrderedSame) {
        [delegate do_DR:args];
    } else if ([command compare:@"DG"] == NSOrderedSame) {
        [delegate do_DG:args];
    } else if ([command compare:@"UB"] == NSOrderedSame) {
        [delegate do_UB:args];
    } else if ([command compare:@"UG"] == NSOrderedSame) {
        [delegate do_UG:args];
    } else if ([command compare:@"RT"] == NSOrderedSame) {
        [delegate do_RT:args];
    /** depricated
    } else if ([key compare:@"SC"] == NSOrderedSame) {
        [delegate do_SC];
	} else if ([key compare:@"PC"] == NSOrderedSame) {
        [delegate do_PC];
    //*/
	} else if ([command compare:@"ST"] == NSOrderedSame) {
		[delegate do_ST];
	} else if ([command compare:@"PT"] == NSOrderedSame) {
		[delegate do_PT];
    } else if ([command compare:@"CU"] == NSOrderedSame) {
        [delegate do_CU];
    } else if ([command compare:@"ET"] == NSOrderedSame) {
        [delegate do_ET:args];
    } else if ([command compare:@"SA"] == NSOrderedSame) {
        [delegate do_SA:args];
    } else if ([command compare:@"PA"] == NSOrderedSame) {
        [delegate do_PA:args];
    } else if ([command compare:@"SS"] == NSOrderedSame) {
        [delegate do_SS:args];
    } else if ([command compare:@"PS"] == NSOrderedSame) {
        [delegate do_PS:args];
    } else if ([command compare:@"UX"] == NSOrderedSame) {
        [delegate do_UX:args];
    } else if ([command compare:@"PI"] == NSOrderedSame) {
        [delegate do_PI:args];
    } else {
        NSLog(@"Command not recognized %@", command);
    }
}

- (void)dealloc {
    NSLog(@"Command Interpreter for App dealloc");
    self.delegate = nil;
    [super dealloc];
}

@end
