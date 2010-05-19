//
//  Keyboard_Simplest.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "Keyboard_Simplest.h"
#import "TemperedScale.h"
#import "LogController.h"
#import "AmplitudeCurve.h"

@implementation Keyboard_Simplest

@synthesize connectedSoundSource = _connectedSoundSource;
@synthesize noteLookup;
@synthesize  offset;

- (id)init {

	self = [super init];
	if(self){
		_amplitudeLookup = [[AmplitudeCurve alloc] init];
		
		// These values still need tweaking to get right
		_amplitudeLookup.minAmp = 0.05f;

		pressedKeys = [[NSMutableIndexSet indexSet] retain];
		offset = -10;
		
		/* 20 ish htz sounds good but i think it needs longer attack - release  1975 is the highest i can hear */
	}
	return self;
}

- (void)dealloc {

	[_amplitudeLookup release];
	[_connectedSoundSource release];
	[noteLookup release];
	[pressedKeys release];
	[super dealloc];
}

- (void)connectOutputTo:(SHooleyObject<SoundsSourceProtocol> *)soundSource {
	
	if(_connectedSoundSource!=soundSource){
		[_connectedSoundSource release];
		_connectedSoundSource = [soundSource retain];
	}
}

- (BOOL)pressedKey:(int)keyIndex {
	
	BOOL success = NO;
	if([pressedKeys containsIndex:keyIndex]==NO)
	{
		CGFloat hz = [noteLookup hzForStepsAboveA4:keyIndex+offset];
		//logInfo(@"hz is %f", (float)hz );
		//NSAssert(hz>50 && hz<5000, @"Invalid Hz");
		
		// it is possible that the press failed
		CGFloat amplitude = _amplitudeLookup ? [_amplitudeLookup mapEarResponseToAmplitudeForFreq:hz] : 0.5f;  // m*(freq-p1.x)+p1.y; // MAX_AMP should be a function of velocity - when we implement velocity!
		int channel = [_connectedSoundSource playSine:hz amp:amplitude];
		if(channel!=-1){
			[pressedKeys addIndex:keyIndex];
			success = YES;
		}
	}
	return success;
}

- (void)releasedKey:(int)keyIndex {

	if([pressedKeys containsIndex:keyIndex]==YES)
	{
		CGFloat hz = [noteLookup hzForStepsAboveA4:keyIndex+offset];
		//NSAssert(hz>50 && hz<5000, @"Invalid Hz");
		[_connectedSoundSource stopSine:hz];
		[pressedKeys removeIndex:keyIndex];
	}
}

- (int)keyCount {
	return 12*4 +6;
}

- (NSString *)nameOfKey:(NSUInteger)keyIndex {
	
	int offsetValue = keyIndex+offset +144; // + 144 to make sure all objects are positive
	int modVal = offsetValue%12;
	// NSLog(@"mod val is %i", modVal);
	switch(modVal){
		case 0:
			return @"0";
		case 1:
			return @"b2";
		case 2:
			return @"2";
		case 3:
			return @"b3";
		case 4:
			return @"3";
		case 5:
			return @"4";
		case 6:
			return @"b5";
		case 7:
			return @"5";
		case 8:
			return @"#5";
		case 9:
			return @"6";
		case 10:
			return @"m7";
		case 11:
			return @"7";
	}
	return @"unknown";
}

- (void)setAmplitudeLookup:(AmplitudeCurve *)alup {
	if(alup!=_amplitudeLookup){
		[_amplitudeLookup release];
		_amplitudeLookup = [alup retain];
	}
}

@end
