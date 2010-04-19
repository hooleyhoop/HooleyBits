//
//  WindowController.m
//  TypeSetter
//
//  Created by steve hooley on 13/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "WindowController.h"
#import "DebugView.h"

@implementation WindowController

@synthesize inputText=_inputText;
@synthesize typeSetterView=_typeSetterView;


- (IBAction)textChanged:(id)sender {
	
	[_typeSetterView setNeedsDisplay:YES];
}

- (NSString *)textToDraw {
	
	return _inputText.stringValue;
}

@end
