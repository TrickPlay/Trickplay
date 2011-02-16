//
//  CommandInterpreter.h
//  Services-test
//
//  Created by Rex Fenley on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CommandInterpreterDelegate

// Commands issued here
@required
- (void)do_DR:(NSArray *)args;
- (void)do_UB:(NSArray *)args;
- (void)do_UG:(NSArray *)args;
- (void)do_RT:(NSArray *)args;

@end

@interface CommandInterpreter : NSObject {
    id <CommandInterpreterDelegate> delegate;
    NSMutableString *commandLine;
    NSMutableDictionary *commandDictionary;
}

@property (nonatomic, assign) id <CommandInterpreterDelegate> delegate;

- (id)init:(id <CommandInterpreterDelegate>)theDelegate;
- (void)createCommandDictionary;
- (void)addBytes:(const uint8_t *)bytes length:(NSUInteger)length;
- (void)parse;
- (void)doDispatchUBToDelegate:(NSArray *)args;
- (void)doDispatchDRToDelegate:(NSArray *)args;
- (void)interpret:(NSString *)command;

@end
