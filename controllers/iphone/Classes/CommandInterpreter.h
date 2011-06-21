//
//  CommandInterpreter.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommandInterpreter : NSObject {
    NSMutableString *commandLine;
    NSMutableDictionary *commandDictionary;
}

- (id)init:(id)theDelegate;
- (void)createCommandDictionary;
- (void)addBytes:(const uint8_t *)bytes length:(NSUInteger)length;
- (void)parse;
- (void)interpretCommand:(NSString *)command;
- (void)executeCommand:(NSString *)command args:(NSArray *)args;

@end
