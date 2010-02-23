//
//  SHExecutionModeTest.m
//  SHExtras
//
//  Created by Steven Hooley on 22/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHExecutionModeTest.h"

/*
 *
*/
@implementation SHExecutionModeTest

// 0:0 - GREEN	-- executes when asked, and an input has changed
// 0:1 - GREEN	-- executes when asked
// 0:2 - GREEN	-- executes when asked, and an input has changed

// 1:0 - PINK	-- executes when input changes, when added to the stage
// 1:1 - PINK	-- executes a lot
// 1:2 - PINK	-- executes when inputs changed

// 2:0 - BLUE	-- executes slowly when asked
// 2:1 - BLUE	-- executes slowly when asked
// 2:2 - BLUE	-- executes when something changes and we have been asked

// 3:0 is the default

//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	_madnessWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,800,600) styleMask:NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_madnessWindow makeKeyAndOrderFront:self];
	[_madnessWindow setTitle:[self description]];
	return self;
}


#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	NSLog(@"SHExecutionModeTest: %@ executing at time %f", [self description], (float)compositionTime);
	
	/* all i know..
	[inputNumber didChangeValue] will cause this patch to execute, but nothing further down the chain if the value hasn't really changed
	doing this on the outport port has no effect
	[outputNumber setDoubleValue:xxx] will cause everything below in the chain to be updated but only if xxx is a different value
	[self _setNeedsExecution] will cause us to executed, but not the chain if no values have changed
	
//	[inputNumber setDoubleValue:[inputNumber doubleValue]+1];



	[outputNumber setDoubleValue:[inputNumber doubleValue]];
//	outputNumber updated
//	outputNumber wasUpdated

	/* returning no causes an exception */
	return YES;
}

- (NSWindow*)madnessWindow
{
	return _madnessWindow;
}

@end
