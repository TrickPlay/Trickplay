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
#import "TrickplayGroup.h"

@implementation AdvancedUIObjectManager

@synthesize rectangles;
@synthesize images;
@synthesize textFields;
@synthesize groups;
@synthesize resourceManager;

- (id)initWithView:(TrickplayGroup *)aView resourceManager:(ResourceManager *)aResourceManager {
    if ((self = [super init])) {
        self.rectangles = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.images = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.textFields = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.groups = [[NSMutableDictionary alloc] initWithCapacity:20];
        currentID = 1;
        
        self.resourceManager = aResourceManager;
        
        view = aView;
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
    
    NSLog(@"Image created: %@", image);
    [images setObject:image forKey:imageID];
    
    //[view addSubview:image];
    [image release];
}


/**
 * Creates Rectangles and stores them.
 */

- (void)createRectangle:(NSString *)rectID withArgs:(NSDictionary *)args {
    TrickplayRectangle *rect = [[TrickplayRectangle alloc] initWithID:rectID args:args objectManager:self];
    
    NSLog(@"Rectangle created: %@", rect);
    [rectangles setObject:rect forKey:rectID];
    
    //[view addSubview:rect];
    [rect release];
}


/**
 * Creates TextFields and stores them
 */

- (void)createText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayText *text = [[TrickplayText alloc] initWithID:textID args:args objectManager:self];
    
    NSLog(@"Text created: %@", text);
    [textFields setObject:text forKey:textID];
    
    //[view addSubview:text];
    [text release];
}


/**
 * Creates Groups and stores them
 */

- (void)createGroup:(NSString *)groupID withArgs:(NSDictionary *)args {
    TrickplayGroup *group = [[TrickplayGroup alloc] initWithID:groupID args:args objectManager:self];
    
    NSLog(@"Group created: %@", group);
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
    NSLog(@"Creating object %@", object);
    
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
        [self createText:ID withArgs:args];
    } else if ([type compare:@"Group"] == NSOrderedSame) {
        [self createGroup:ID withArgs:args];
    }

    [self createObjectReply:ID];
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
#pragma mark Old Protocol

/**
 * Object creation function.
 */

- (void)createObjects:(NSArray *)JSON_Array {
    // Destroy any objects of the same name
    [self destroyObjects:JSON_Array];
    
    NSLog(@"Creating Objects from JSON: %@", JSON_Array);
    
    // Now that we have the JSON Array of objects, create all the objects
    for (NSDictionary *object in JSON_Array) {
        NSLog(@"Creating object %@", object);
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [self createRectangle:(NSString *)[object objectForKey:@"id"]
                         withArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [self createImage:(NSString *)[object objectForKey:@"id"]
                     withArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [self createText:(NSString *)[object objectForKey:@"id"]
                     withArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Group"] == NSOrderedSame) {
            [self createGroup:(NSString *)[object objectForKey:@"id"]
                    withArgs:object];
        }
    }
}


/**
 * Object Destruction function.
 */

- (void)destroyObjects:(NSArray *)JSON_Array {
    NSLog(@"Destroying Objects from JSON: %@", JSON_Array);
    
    // Total destruction
    for (NSDictionary *object in JSON_Array) {
        // remove from local repository
        NSLog(@"Destroying object %@", object);
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [rectangles removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [[images objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [images removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [[textFields objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [textFields removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Group"] == NSOrderedSame) {
            for (TrickplayGroup *group in groups) {
                [group.manager destroyObjects:JSON_Array];
            }
            [[groups objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [groups removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        }
    }
}


/**
 * Object Setter function.
 */

- (void)setValuesForObjects:(NSArray *)JSON_Array {
    for (NSDictionary *object in JSON_Array) {
        NSLog(@"Setting object %@", object);
        
        // Set values for class specific properties
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [(TrickplayUIElement *)[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [(TrickplayUIElement *)[images objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [(TrickplayUIElement *)[textFields objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Group"] == NSOrderedSame) {
            for (TrickplayGroup *group in groups) {
                [group.manager setValuesForObjects:JSON_Array];
            }
            [(TrickplayUIElement *)[groups objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        }
    }
}


/**
 * Object Getter function.
 */

- (void)getValuesForObjects:(NSArray *)JSON_Array {
    for (NSDictionary *object in JSON_Array) {
        // Set values for class specific properties
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [(TrickplayUIElement *)[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [(TrickplayUIElement *)[images objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [(TrickplayUIElement *)[textFields objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Group"] == NSOrderedSame) {
            [(TrickplayUIElement *)[groups objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        }
    }
}


- (void)dealloc {
    NSLog(@"AdvancedUIObjectManager dealloc");
    if (hostName) {
        [hostName release];
        hostName = nil;
    }
    
    if (socketManager) {
        [socketManager release];
        socketManager = nil;
    }
    
    [self clean];
    
    self.rectangles = nil;
    self.images = nil;
    self.textFields = nil;
    self.groups = nil;
    self.resourceManager = nil;
    
    [super dealloc];
}

@end
