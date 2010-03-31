//
//  BBClock1Patch.m
//  SHExtras
//
//  Created by Steven Hooley on 31/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBClock1Patch.h"

/*
 *
*/
@implementation BBClock1Patch


		// Get preferences
		prefManager = [PreferencesManager alloc];
		prefManager = [prefManager init];
		[prefManager loadPrefs];

		// set a bunch of objects from preferences to save a few clock cycles
		stringAttributes = [prefManager getStringAttributes];
		repositionClock = [prefManager getRepositionClock];
		clockFormat = [prefManager getClockFormat];
		motionEffect = [prefManager getMotionEffect];

		
		// Set initial attributed time string to the current time and current display attributes (also set random location)
		clockString = [ [NSMutableString alloc] initWithString:[ [NSDate date] descriptionWithCalendarFormat:clockFormat timeZone:nil locale:nil]];

		// set previous string for comparison of clock changes
		prevClockString = [ [NSMutableString alloc] initWithString: clockString];



	[clockString setString: [ [NSDate date] descriptionWithCalendarFormat:clockFormat timeZone:nil locale:nil ]];

	if ( [clockString compare:prevClockString] != NSOrderedSame ) {
		[self setNeedsDisplay: YES];
		[prevClockString setString: clockString];
	}
		
	[clockString drawAtPoint:timestringLocation withAttributes:stringAttributes];



//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode {
	return 3;
}

//=========================================================== 
// - timeMode:
//=========================================================== 
+ (int)timeMode {
	return 1;
}

//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	[self setEnvelope: [LWEnvelope lWEnvelope]];
	[_envelope moveToPoint:[G3DTuple2d tupleWithX:0 y:10]];
	[_envelope lineToPoint:[G3DTuple2d tupleWithX:100 y:1]];

	return self;
}

#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	// NSLog(@"BBInterpolationPatch: %@ executing at time %f", [self description], (float)compositionTime);
	
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
	[outputValue setDoubleValue: [_envelope evalAtTime:compositionTime]];

	return YES;
}



#pragma mark accessor methods





@end
