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
        
        timeLine = [[TrickplayTimeline alloc] init];
        
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
    
    [timeLine startTimeline];
    
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

- (void)storeObject:(TrickplayUIElement *)object {
    if ([object isKindOfClass:[TrickplayRectangle class]]) {
        [rectangles setObject:object forKey:object.ID];
    } else if ([object isKindOfClass:[TrickplayGroup class]]) {
        [groups setObject:object forKey:object.ID];
    } else if ([object isKindOfClass:[TrickplayText class]]) {
        [textFields setObject:object forKey:object.ID];
    } else if ([object isKindOfClass:[TrickplayTextHTML class]]) {
        [webTexts setObject:object forKey:object.ID];
    } else if ([object isKindOfClass:[TrickplayImage class]]) {
        [images setObject:object forKey:object.ID];
    }
}

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
    
    [gestureViewController advancedUIObjectDeleted];
}


/**
 * Creates Images and stores them
 *
 * MUST NOT USE AUTORELEASE POOL FOR ADVANCED_UI OBJECTS!
 */

- (void)createImage:(NSString *)imageID withArgs:(NSDictionary *)args {
    
    
    TrickplayImage *image = [[TrickplayImage alloc] initWithID:imageID args:args resourceManager:resourceManager objectManager:self];
    
    [images setObject:image forKey:imageID];
    image.timeLine = timeLine;
    
    [image release];
}


/**
 * Creates Rectangles and stores them.
 */

- (void)createRectangle:(NSString *)rectID withArgs:(NSDictionary *)args {
    TrickplayRectangle *rect = [[TrickplayRectangle alloc] initWithID:rectID args:args objectManager:self];
    
    [rectangles setObject:rect forKey:rectID];
    rect.timeLine = timeLine;
    
    [rect release];
}


/**
 * Creates TextFields and stores them
 */

- (void)createText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayText *text = [[TrickplayText alloc] initWithID:textID args:args objectManager:self];
    
    [textFields setObject:text forKey:textID];
    text.timeLine = timeLine;
    
    [text release];
}

/**
 * Creates UIWebViews used for Text and stores them
 */

- (void)createWebText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayTextHTML *text = [[TrickplayTextHTML alloc] initWithID:textID args:args objectManager:self];
    
    [webTexts setObject:text forKey:textID];
    text.timeLine = timeLine;
    
    [text release];
}


/**
 * Creates Groups and stores them
 */

- (void)createGroup:(NSString *)groupID withArgs:(NSDictionary *)args {
    TrickplayGroup *group = [[TrickplayGroup alloc] initWithID:groupID args:args objectManager:self];
    
    [groups setObject:group forKey:groupID];
    group.timeLine = timeLine;
    
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

- (void)destroyObjectReply:(NSString *)ID absolute:(BOOL)absolute {
    if (!socketManager) {
        return;
    }
    
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", [NSNumber numberWithBool:absolute], @"destroyed", nil];
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
    // Only screen may have an ID of 0
    if (currentID == 0) {
        currentID++;
    }
    NSString *ID = [NSString stringWithFormat:@"%u", currentID];
    currentID++;
    
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

- (void)destroyObject:(NSDictionary *)object {
    id type = [object objectForKey:@"type"];
    id ID = [object objectForKey:@"id"];
    
    // Must have class type and id, type must be a string, id must be a string
    // id cannot equal 0 since this is the ID for screen
    if (!type || !ID || ![type isKindOfClass:[NSString class]]
        || ![ID isKindOfClass:[NSString class]] || [(NSString *)ID compare:@"0"] == NSOrderedSame) {
        [self reply:nil];
        return;
    }
    
    BOOL destroy_absolutely = NO;
    if ([rectangles objectForKey:ID]) {
        TrickplayRectangle *rectangle = [rectangles objectForKey:ID];
        destroy_absolutely = (rectangle.retainCount <= 1);
        [rectangles removeObjectForKey:ID];
    } else if ([groups objectForKey:ID]) {
        TrickplayGroup * group = [groups objectForKey:ID];
        [group do_clear:nil];
        destroy_absolutely = (group.retainCount <= 1);
        [groups removeObjectForKey:ID];
    } else if ([textFields objectForKey:ID]) {
        TrickplayText *text = [textFields objectForKey:ID];
        destroy_absolutely = (text.retainCount <= 1);
        [textFields removeObjectForKey:ID];
    } else if ([webTexts objectForKey:ID]) {
        TrickplayTextHTML *webText = [webTexts objectForKey:ID];
        destroy_absolutely = (webText.retainCount <= 1);
        [webTexts removeObjectForKey:ID];
    } else if ([images objectForKey:ID]) {
        TrickplayImage *image = [images objectForKey:ID];
        destroy_absolutely = (image.retainCount <= 1);
        [images removeObjectForKey:ID];
    } else {
        [self reply:nil];
        return;
    }
    
    [gestureViewController advancedUIObjectDeleted];
    
    [self destroyObjectReply:ID absolute:destroy_absolutely];
}

- (void)setValuesForObject:(NSDictionary *)JSON_object {
    NSDictionary *args = [JSON_object objectForKey:@"properties"];
    
    // Set values for class specific properties
    TrickplayUIElement *object = [self findObjectForID:[JSON_object objectForKey:@"id"]];
    if (!object) {
        [self reply:nil];
        return;
    }
    [object setValuesFromArgs:args];
    
    [self reply:@"[true]"];
}

- (void)getValuesForObject:(NSDictionary *)JSON_object {
    // Get a list of properties that need updating
    NSDictionary *properties = [JSON_object objectForKey:@"properties"];
    // Find the AdvancedUI Object to get properties from
    TrickplayUIElement *object = [self findObjectForID:[JSON_object objectForKey:@"id"]];
    if (!object) {
        [self reply:nil];
        return;
    }
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
    if (!object) {
        [self reply:nil];
        return;
    }
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
    
    if (view.view.subviews.count == 0) {
        [gestureViewController performSelector:@selector(advancedUIObjectDeleted)];
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

#pragma mark -
#pragma mark Copy/Deallocation

- (id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

- (void)dealloc {
    NSLog(@"AdvancedUIObjectManager dealloc");
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (timeLine) {
        [timeLine stopTimeline];
        [timeLine release];
        timeLine = nil;
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
