//
//  SHGlobalVar.m
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHGlobalVar.h"
#import "SHNumberPort.h"


@implementation SHGlobalVar

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
	return 3;
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

	// BBLog(@"SHGlobalVar.. initWithIdentifier");
	[inputKeyForVariable setStringValue:@"default"];
	[inputTakeSampleSignal setBooleanValue:NO];
	[inputSignal setDoubleValue:0];
	[outputValue setDoubleValue:0];
	
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
	[outputValue setKey:[inputKeyForVariable stringValue]];
	
	if ([inputTakeSampleSignal booleanValue] == YES)
	{

		//BBLog(@"SHGlobalVar.. execute: key:%@, val:%f", key, (float)[inputSignal doubleValue]);

		[inputTakeSampleSignal setBooleanValue:NO]; // signal like behavoir
		[outputValue setDoubleValue:[inputSignal doubleValue]];
	}

	return TRUE;
}
@end
