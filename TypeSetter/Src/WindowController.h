//
//  WindowController.h
//  TypeSetter
//
//  Created by steve hooley on 13/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DebugView;

@interface WindowController : NSWindowController {

	NSTextField *_inputText;
	DebugView *_typeSetterView;
}

@property (assign) IBOutlet NSTextField *inputText;
@property (assign) IBOutlet DebugView *typeSetterView;

- (IBAction)textChanged:(id)sender;
- (NSString *)textToDraw;
@end
