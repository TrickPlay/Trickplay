//
//  CommandInterpreter.h
//  Services-test
//
//  Created by Rex Fenley on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandInterpreter.h"

@protocol CommandInterpreterAppDelegate

// Commands issued here
@required
- (void)do_MC:(NSArray *)args;
- (void)do_DR:(NSArray *)args;
- (void)do_DG:(NSArray *)args;
- (void)do_UB:(NSArray *)args;
- (void)do_UG:(NSArray *)args;
- (void)do_RT:(NSArray *)args;
/** depricated
- (void)do_SC;
- (void)do_PC;
//*/
- (void)do_ST;
- (void)do_PT;
- (void)do_CU;
- (void)do_ET:(NSArray *)args;
- (void)do_SA:(NSArray *)args;
- (void)do_PA:(NSArray *)args;
- (void)do_SS:(NSArray *)args;
- (void)do_PS:(NSArray *)args;

- (void)do_SGY:(NSArray *)args;
- (void)do_PGY:(NSArray *)args;
- (void)do_SMM:(NSArray *)args;
- (void)do_PMM:(NSArray *)args;
- (void)do_SAT:(NSArray *)args;
- (void)do_PAT:(NSArray *)args;

// Video Streaming Server->Controller
- (void)do_SVSC:(NSArray *)args;
- (void)do_SVEC:(NSArray *)args;
- (void)do_SVSS;

// Welcome Message
- (void)do_WM:(NSArray *)args;

// Take pictures
- (void)do_PI:(NSArray *)args;

// Modal Virtual Remote
- (void)do_SV;
- (void)do_HV;

@end

@interface CommandInterpreterApp : CommandInterpreter {
    id <CommandInterpreterAppDelegate> delegate;

    BOOL firstCommand;
}

@property (nonatomic, assign) id <CommandInterpreterAppDelegate> delegate;

@end
