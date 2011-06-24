//
//  CommandInterpreter.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommandInterpreter.h"


@implementation CommandInterpreter

- (id)init:(id)theDelegate {
    NSLog(@"Error, This is just an interface");
    return nil;
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
            [self interpretCommand:command];
            
            prev = i+1;
        }
    }
    // delete those commands from the commandLine
    /*
    NSLog(@"commandLine: %@", commandLine);
    NSLog(@"prev = %d", prev);
    //*/
    NSString *newCommandLine = [commandLine substringFromIndex:prev];
    [commandLine release];
    commandLine = [[NSMutableString alloc] initWithCapacity:40];
    [commandLine appendString:newCommandLine];
}

- (void)interpretCommand:(NSString *)command {
    // This class is an interface, this code just prevents a warning
}

- (void)executeCommand:(NSString *)command args:(NSArray *)args {
    // This class is a n interface, this code just prevents a warning
}

- (void)dealloc {
    [commandLine release];
    [super dealloc];
}

@end
