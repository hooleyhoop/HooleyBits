//
//  SHSwapIns.m
//  SHExtras
//
//  Created by Steven Hooley on 07/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHSwapIns.h"

@implementation SHSwapIns

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + timeMode:
//=========================================================== 
+ (int)timeMode {
	return 1;		//Forces continuous execution
}

//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode
{
	// I have found the following execution modes:
	//  1 - Renderer, Environment - pink title bar
	//  2 - Source, Tool, Controller - blue title bar
	//  3 - Numeric, Modifier, Generator - green title bar
	return 2;
}

//=========================================================== 
// + allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	isSwapped=NO;

	[inputSwap setBooleanValue:NO];
	[inputReset setBooleanValue:NO];
	[inputValue1 setDoubleValue:0];
	[inputValue2 setDoubleValue:0];
	[output1 setDoubleValue:0];
	[output2 setDoubleValue:0];	

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

//=========================================================== 
// - setup:
//=========================================================== 
- (id)setup:(id)fp8
{
	//BBLog(@"SHGlobalVar.. setup");
	[super setup:fp8];
	return fp8;
}

//=========================================================== 
// - cleanup:
//=========================================================== 
- (void)cleanup:(id)fp8
{
	//BBLog(@"SHGlobalVar.. cleanup");
	[super cleanup:fp8];
}

#pragma mark action methods
//=========================================================== 
// - execute:
//=========================================================== 
- (BOOL)execute:(id)openGLContext_ptr time:(double)currentTime arguments:(id)fp20
{

	if ([inputReset booleanValue] == YES)
	{
		[inputReset setBooleanValue:NO]; // signal like behavoir
		isSwapped=NO;
	}
	if ([inputSwap booleanValue] == YES)
	{
		[inputSwap setBooleanValue:NO]; // signal like behavoir
		isSwapped=!isSwapped;
	}
	if (isSwapped)
	{
		[output1 setDoubleValue:[inputValue2 doubleValue]];
		[output2 setDoubleValue:[inputValue1 doubleValue]];	
	} else {
		[output1 setDoubleValue:[inputValue1 doubleValue]];
		[output2 setDoubleValue:[inputValue2 doubleValue]];	
	}	
	
	return TRUE;
}

@end



