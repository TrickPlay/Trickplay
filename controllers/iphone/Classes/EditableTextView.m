//
//  EditableTextView.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditableTextView.h"


@implementation EditableTextView

- (void)textChanged:(NSNotification *)notification {
    if ([notification object] == self) {
        NSRange range = NSMakeRange(self.text.length - 1, 1);
        [self scrollRangeToVisible:range];
    }
}

- (void)setProperties {
    self.userInteractionEnabled = YES;
    //self.delegate = self;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

//*
- (id)init {
    if ((self = [super init])) {
        [self setProperties];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setProperties];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setProperties];
    }
    
    return self;
}
//*/


#pragma mark -
#pragma mark Touch Delegate Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self becomeFirstResponder];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark -
#pragma mark UITextView Delegate Methods

/*
- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"selected range: %@", [textView selectedRange]);
    [textView scrollRangeToVisible:[textView selectedRange]];
}
 */


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"Done editing...");
    [textField resignFirstResponder];
    return YES;
}

@end
