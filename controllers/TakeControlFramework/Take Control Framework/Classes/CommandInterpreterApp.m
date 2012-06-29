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
    }
    
    return self;
}


- (void)interpretCommand:(NSString *)command {
    fprintf(stderr, "\n\nAsync Command received: %s\n\n", [command UTF8String]);
    
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
    //NSLog(@"CommandInterpreterApp command: %@", args);
    if (firstCommand) {
        if ([command compare:@"WM"] == NSOrderedSame) {
            [delegate do_WM:args];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionEstablishedNotification" object:nil];
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
    } else if ([command compare:@"SGY"] == NSOrderedSame) {
        [delegate do_SGY:args];
    } else if ([command compare:@"PGY"] == NSOrderedSame) {
        [delegate do_PGY:args];
    } else if ([command compare:@"SMM"] == NSOrderedSame) {
        [delegate do_SMM:args];
    } else if ([command compare:@"PMM"] == NSOrderedSame) {
        [delegate do_PMM:args];
    } else if ([command compare:@"SAT"] == NSOrderedSame) {
        [delegate do_SAT:args];
    } else if ([command compare:@"PAT"] == NSOrderedSame) {
        [delegate do_PAT:args];
    } else if ([command compare:@"SS"] == NSOrderedSame) {
        [delegate do_SS:args];
    } else if ([command compare:@"PS"] == NSOrderedSame) {
        [delegate do_PS:args];
    } else if ([command compare:@"SV"] == NSOrderedSame) {
        [delegate do_SV];
    } else if ([command compare:@"HV"] == NSOrderedSame) {
        [delegate do_HV];
    } else if ([command compare:@"PI"] == NSOrderedSame) {
        [delegate do_PI:args];
    } else if ([command compare:@"SVSC"] == NSOrderedSame) {
        [delegate do_SVSC:args];
    } else if ([command compare:@"SVEC"] == NSOrderedSame) {
        [delegate do_SVEC:args];
    } else if ([command compare:@"SVSS"] == NSOrderedSame) {
        [delegate do_SVSS];
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
