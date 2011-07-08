//
//  AdvancedUIObjectManager.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvancedUIObjectManager.h"
#import "TrickplayImage.h"
#import "TrickplayRectangle.h"
#import "TrickplayText.h"
#import "TrickplayTextHTML.h"
#import "TrickplayGroup.h"
#import "TrickplayScreen.h"

@implementation AdvancedUIObjectManager

@synthesize rectangles;
@synthesize images;
@synthesize textFields;
@synthesize webTexts;
@synthesize groups;
@synthesize resourceManager;
@synthesize gestureViewController;

- (id)initWithView:(TrickplayGroup *)aView resourceManager:(ResourceManager *)aResourceManager {
    if ((self = [super init])) {
        self.rectangles = [NSMutableDictionary dictionaryWithCapacity:20];
        self.images = [NSMutableDictionary dictionaryWithCapacity:20];
        self.textFields = [NSMutableDictionary dictionaryWithCapacity:20];
        self.webTexts = [NSMutableDictionary dictionaryWithCapacity:20];
        self.groups = [NSMutableDictionary dictionaryWithCapacity:20];
        currentID = 1;
        
        self.resourceManager = aResourceManager;
        
        view = aView;
        gestureViewController = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark Networking

- (void)setupServiceWithPort:(NSInteger)p hostname:(NSString *)h {
    NSLog(@"AdvancedUI Service Setup: host: %@ port: %d", h, p);
    
    port = p;
    if (hostName) {
        [hostName release];
    }
    hostName = [h retain];
}

- (BOOL)startServiceWithID:(NSString *)ID {
    NSLog(@"AdvancedUI Start Service");
    // Tell socket manager to create a socket and connect to the service selected
    socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                       port:port
                                                   delegate:self
                                                   protocol:ADVANCED_UI_PROTOCOL];
    
    if (!socketManager || ![socketManager isFunctional]) {
        // If null then error connecting, back up to selecting services view
        NSLog(@"AdvancedUI Could Not Establish Connection");
        return NO;
    }
    NSLog(@"AdvancedUI Connection Established");
    
    // Made a connection, let the service know!
	NSData *welcomeData = [[NSString stringWithFormat:@"UX\t%@\n", ID] dataUsingEncoding:NSUTF8StringEncoding];

    [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
    
    return YES;
}

#pragma mark -
#pragma mark Network Handling

- (void) socketErrorOccurred {
    NSLog(@"AdvancedUI stream error");
    // TODO: good error handling
}

- (void) streamEndEncountered {
    NSLog(@"AdvancedUI stream end");
    // TODO: good error handling
}

#pragma mark -
#pragma mark UI

- (void)clean {
    NSLog(@"AdvancedUI clean");
    
    for (UIView *rectangle in [rectangles allValues]) {
        [rectangle removeFromSuperview];
    }
    [rectangles removeAllObjects];
    
    for (UIView *image in [images allValues]) {
        [image removeFromSuperview];
    }
    [images removeAllObjects];
    
    for (UIView *textField in [textFields allValues]) {
        [textField removeFromSuperview];
    }
    [textFields removeAllObjects];
    
    for (UIView *webText in [webTexts allValues]) {
        [webText removeFromSuperview];
    }
    [webTexts removeAllObjects];
    
    for (UIView *group in [groups allValues]) {
        [group removeFromSuperview];
    }
    [groups removeAllObjects];
}


/**
 * Creates Images and stores them
 */

- (void)createImage:(NSString *)imageID withArgs:(NSDictionary *)args {
    
    
    TrickplayImage *image = [[TrickplayImage alloc] initWithID:imageID args:args resourceManager:resourceManager objectManager:self];
    
    //NSLog(@"Image created: %@", image);
    [images setObject:image forKey:imageID];
    
    //[view addSubview:image];
    [image release];
}


/**
 * Creates Rectangles and stores them.
 */

- (void)createRectangle:(NSString *)rectID withArgs:(NSDictionary *)args {
    TrickplayRectangle *rect = [[TrickplayRectangle alloc] initWithID:rectID args:args objectManager:self];
    
    //NSLog(@"Rectangle created: %@", rect);
    [rectangles setObject:rect forKey:rectID];
    
    //[view addSubview:rect];
    [rect release];
}


/**
 * Creates TextFields and stores them
 */

- (void)createText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayText *text = [[TrickplayText alloc] initWithID:textID args:args objectManager:self];
    
    //NSLog(@"Text created: %@", text);
    [textFields setObject:text forKey:textID];
    
    //[view addSubview:text];
    [text release];
}

/**
 * Creates UIWebViews used for Text and stores them
 */

- (void)createWebText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayTextHTML *text = [[TrickplayTextHTML alloc] initWithID:textID args:args objectManager:self];
    
    [webTexts setObject:text forKey:textID];
    
    [text release];
}


/**
 * Creates Groups and stores them
 */

- (void)createGroup:(NSString *)groupID withArgs:(NSDictionary *)args {
    TrickplayGroup *group = [[TrickplayGroup alloc] initWithID:groupID args:args objectManager:self];
    
    //NSLog(@"Group created: %@", group);
    [groups setObject:group forKey:groupID];
    
    //[view addSubview:group];
    [group release];
}

#pragma mark -
#pragma mark New Protocol

- (void)reply:(NSString *)JSON_String {
    if (!JSON_String) {
        JSON_String = @"[null]";
    }
    JSON_String = [NSString stringWithFormat:@"%@\n", JSON_String];
    NSData *data = [JSON_String dataUsingEncoding:NSUTF8StringEncoding];
    [socketManager sendData:[data bytes] numberOfBytes:[data length]];
}

- (void)createObjectReply:(NSString *)ID {
    if (!socketManager) {
        return;
    }
    
    NSDictionary *object = [NSDictionary dictionaryWithObject:ID forKey:@"id"];
    NSString *JSON_String = [object yajl_JSONString];
    [self reply:JSON_String];
}

- (void)createObject:(NSDictionary *)object {
    //NSLog(@"Creating object %@", object);
    
    //CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    NSString *type = [object objectForKey:@"type"];
    NSDictionary *args = [object objectForKey:@"properties"];
    if (args) {
        if (![args isKindOfClass:[NSDictionary class]]) {
            [self reply:nil];
            return;
        }
    }
    NSString *ID = [NSString stringWithFormat:@"%u", currentID];
    currentID++;
    if (currentID == 0) {
        currentID++;
    }
    
    if ([type compare:@"Rectangle"] == NSOrderedSame) {
        [self createRectangle:ID withArgs:args];
    } else if ([type compare:@"Image"] == NSOrderedSame) {
        [self createImage:ID withArgs:args];
    } else if ([type compare:@"Text"] == NSOrderedSame) {
        [self createWebText:ID withArgs:args];
    } else if ([type compare:@"Group"] == NSOrderedSame) {
        [self createGroup:ID withArgs:args];
    }
    
    

    [self createObjectReply:ID];
    //CFAbsoluteTime stop = CFAbsoluteTimeGetCurrent();
    //NSLog(@"Create Object Time = %lf", (stop - start)*1000.0);
}

- (void)setValuesForObject:(NSDictionary *)JSON_object {
    NSDictionary *args = [JSON_object objectForKey:@"properties"];
    
    // Set values for class specific properties
    TrickplayUIElement *object = [self findObjectForID:[JSON_object objectForKey:@"id"]];
    [object setValuesFromArgs:args];
    
    [self reply:@"[true]"];
}

- (void)getValuesForObject:(NSDictionary *)JSON_object {
    // Get a list of properties that need updating
    NSDictionary *properties = [JSON_object objectForKey:@"properties"];
    // Find the AdvancedUI Object to get properties from
    TrickplayUIElement *object = [self findObjectForID:[JSON_object objectForKey:@"id"]];
    // Make a dictionary that will carry the returned values
    NSMutableDictionary *JSON_dictionary = [NSMutableDictionary dictionaryWithDictionary:JSON_object];
    // Set the properties to this dictionary
    [JSON_dictionary setObject:[object getValuesFromArgs:properties] forKey:@"properties"];
    // Convert dictionary to JSON string and send over the socket
    [self reply:[JSON_dictionary yajl_JSONString]];
}

- (void)deleteValuesForObject:(NSDictionary *)JSON_object {
    NSDictionary *args = [JSON_object objectForKey:@"properties"];
    
    // Set values for class specific properties
    TrickplayUIElement *object = [self findObjectForID:[JSON_object objectForKey:@"id"]];
    [object deleteValuesFromArgs:args];    // TODO: finish this
    [self reply:@"[false]"];
}

- (TrickplayUIElement *)findObjectForID:(NSString *)ID {
    if ([ID intValue] == 0) {
        return view;
    } else if ([rectangles objectForKey:ID]) {
        return [rectangles objectForKey:ID];
    } else if ([groups objectForKey:ID]) {
        return [groups objectForKey:ID];
    } else if ([textFields objectForKey:ID]) {
        return [textFields objectForKey:ID];
    } else if ([webTexts objectForKey:ID]) {
        return [webTexts objectForKey:ID];
    } else if ([images objectForKey:ID]) {
        return [images objectForKey:ID];
    }
    
    return nil;
}

- (void)callMethodOnObject:(NSDictionary *)object {
    NSString *ID = [object objectForKey:@"id"];
    NSArray *args = [object objectForKey:@"args"];
    NSString *method = [object objectForKey:@"call"];
    
    if (!ID || !args || !method) {
        NSLog(@"ERROR: Call missing something; ID: %@; args: %@; method: %@", ID, args, method);
        [self reply:nil];
        return;
    }
    
    id result = nil;
    TrickplayUIElement *uiObject = [self findObjectForID:ID];
    if (uiObject) {
        result = [uiObject callMethod:method withArgs:args];
    }
    
    if (result) {
        [self reply:[[NSDictionary dictionaryWithObject:result forKey:@"result"] yajl_JSONString]];
    } else {
        [self reply:nil];
    }
}

#pragma mark -
#pragma mark Test method

- (void)respondInstantly {
    [self reply:nil];
}


- (void)dealloc {
    NSLog(@"AdvancedUIObjectManager dealloc");
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (socketManager) {
        socketManager.delegate = nil;
        [socketManager release];
        socketManager = nil;
    }
    
    [self clean];
    
    self.rectangles = nil;
    self.images = nil;
    self.textFields = nil;
    self.webTexts= nil;
    self.groups = nil;
    self.resourceManager = nil;
    
    gestureViewController = nil;
    
    [super dealloc];
}

@end
