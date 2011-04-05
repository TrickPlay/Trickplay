//
//  CommandInterpreter.m
//  Services-test
//
//  Created by Rex Fenley on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommandInterpreter.h"


@implementation CommandInterpreter

@synthesize delegate;

/**
 * Initialize and create a mutable string that will act as the command line.
 */
- (id)init:(id <CommandInterpreterDelegate>)theDelegate {
    if ((self = [super init])) {
        commandLine = [[NSMutableString alloc] initWithCapacity:40];
        
        delegate = theDelegate;
        
        //[self createCommandDictionary];
    }
    
    return self;
}

- (void)createCommandDictionary {
    commandDictionary = [[NSMutableDictionary alloc] initWithCapacity:40];
    
    /*
    Protocol *commandProtocol = @protocol(CommandInterpreterDelegate);
    unsigned int outCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(commandProtocol, YES, YES, &outCount);
    if (methods) {
        int i;
        for (i = 0; i < outCount; i++){
            struct objc_method_description method = methods[i];
            fprintf(stderr, "Protocol has method: %s\n", [[NSStringFromSelector(method.name)] UTF8String]);
        }
        
        free(methods);
    }
    */
    
    SEL method = NSSelectorFromString(@"do_DR:");
    [commandDictionary setObject:(id)method forKey:@"DR"];
}

/**
 * Append bytes recieved over the socket to the end of the command line to
 * be interpreted.
 */
- (void)addBytes:(const uint8_t *)bytes length:(NSUInteger)length {
    if (!commandLine) {
        commandLine = [[NSMutableString alloc] initWithCapacity:40];
    }
    NSString *string = [[[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding] autorelease];
    [commandLine appendString:string];
    [self parse];
}

/**
 * Parse the command line by pulling out lines sections of bytes that are 
 * 'newline' terminated.
 */
- (void)parse {
    NSUInteger range = [commandLine length];
    
    //fprintf(stderr, "Command Line: \n%s\n\n", [commandLine UTF8String]);
    
    if (range == 0) return;
    
    NSUInteger i, prev = 0;
    for (i = 0; i < range; i++) {
        if ([commandLine characterAtIndex:i] == '\n') {
            // pull out a command and interpret
            NSString *command = [[[commandLine substringWithRange:NSMakeRange(prev, i-prev)] retain] autorelease];
            [self interpret:command];
            
            prev = i+1;
        }
    }
    // delete those commands from the commandLine
    NSString *newCommandLine = [[[commandLine substringFromIndex:prev] retain] autorelease];
    [commandLine release];
    commandLine = [[NSMutableString alloc] initWithCapacity:40];
    [commandLine appendString:newCommandLine];
}


- (void)interpret:(NSString *)command {
    //fprintf(stderr, "Command recieved: %s\n", [command UTF8String]);
    NSLog(@"Received command: %@", command);
    
    NSArray *components = [[command componentsSeparatedByString:@"\t"] retain];
    NSMutableArray *args = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    
    int i;
    for (i = 1; i < [components count]; i++) {
        //fprintf(stderr, "arg: %s\n", [[components objectAtIndex:i] UTF8String]);
        [args addObject:[components objectAtIndex:i]];
    }
    
    NSString *key = [[[components objectAtIndex:0] retain] autorelease];
    [components release];
    /*
    SEL method = (SEL)[commandDictionary objectForKey:key];
    if (method) {
        [delegate performSelector:method withObject:args];
    } else {
        fprintf(stderr, "Unrecognized command %s\n", [key UTF8String]);
    }
    //*/
    if ([key compare:@"MC"] == NSOrderedSame) {
        [delegate do_MC:args];
    } else if ([key compare:@"DR"] == NSOrderedSame) {
        [delegate do_DR:args];
    } else if ([key compare:@"UB"] == NSOrderedSame) {
        [delegate do_UB:args];
    } else if ([key compare:@"UG"] == NSOrderedSame) {
        [delegate do_UG:args];
    } else if ([key compare:@"RT"] == NSOrderedSame) {
        [delegate do_RT:args];
    /** depricated
    } else if ([key compare:@"SC"] == NSOrderedSame) {
        [delegate do_SC];
	} else if ([key compare:@"PC"] == NSOrderedSame) {
        [delegate do_PC];
    //*/
	} else if ([key compare:@"ST"] == NSOrderedSame) {
		[delegate do_ST];
	} else if ([key compare:@"PT"] == NSOrderedSame) {
		[delegate do_PT];
    } else if ([key compare:@"CU"] == NSOrderedSame) {
        [delegate do_CU];
    } else if ([key compare:@"ET"] == NSOrderedSame) {
        [delegate do_ET:args];
    } else if ([key compare:@"SA"] == NSOrderedSame) {
        [delegate do_SA:args];
    } else if ([key compare:@"PA"] == NSOrderedSame) {
        [delegate do_PA:args];
    } else if ([key compare:@"SS"] == NSOrderedSame) {
        [delegate do_SS:args];
    } else if ([key compare:@"UX"] == NSOrderedSame) {
        [delegate do_UX:args];
    } else {
        NSLog(@"Command not recognized %@", key);
    }

}

- (void)dealloc {
    NSLog(@"Command Interpreter dealloc");
    [commandLine release];
    [super dealloc];
}

@end
