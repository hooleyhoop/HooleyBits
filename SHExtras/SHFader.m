//
//  SHFader.m
//  Quartz
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "SHFader.h"


@implementation SHFader
	

+ (int)timeMode
{
	return 1;		//Forces continuous execution
}

+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 3;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return FALSE;
}
	
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	
	[inputFadeTime setDoubleValue:1.0];

	fadingIn = NO;
	fadingOut = NO;
	
	return self;
}

- (BOOL)execute:(id)fp8 time:(double)currentTime arguments:(id)fp20
{
	if([inputReset booleanValue]==YES)
	{
		[inputReset setBooleanValue:NO];
		currentValue = 0;
		fadingIn = NO;
		fadingOut = NO;
	}
	
	if ([inputStartFadeIn booleanValue] == YES)
	{
		[inputStartFadeIn setBooleanValue:NO];
		[inputStartFadeOut setBooleanValue:NO];
		fadingIn = YES;
		fadingOut = NO;
		timeToFinishFade = currentTime + (1-currentValue)*[inputFadeTime doubleValue];
	}
	else if ([inputStartFadeOut booleanValue] == YES)
	{
		[inputStartFadeIn setBooleanValue:NO];
		[inputStartFadeOut setBooleanValue:NO]; 
		fadingIn = NO;
		fadingOut = YES;
		timeToFinishFade = currentTime + (currentValue)*[inputFadeTime doubleValue];
	}
	
	if (fadingIn)
	{
		currentValue = 1 - (timeToFinishFade - currentTime)/[inputFadeTime doubleValue];
		if (currentValue >= 1)
		{
			fadingIn = NO;
		}
	}
	else if (fadingOut)
	{
		currentValue = (timeToFinishFade - currentTime)/[inputFadeTime doubleValue];
		if (currentValue <=  0)
		{
			fadingOut = NO;
		}
	}
	
	BBCLAMP(currentValue, 0, 1);
	[outputValue setDoubleValue:currentValue];
	
	return TRUE;
}

@end