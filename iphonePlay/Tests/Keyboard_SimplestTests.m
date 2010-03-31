//
//  Keyboard_SimplestTests.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import <OCMock/OCMock.h>
#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "Keyboard_Simplest.h"
#import "NoteLookupProtocol.h"
#import "AmplitudeCurve.h"

@interface Keyboard_SimplestTests : SenTestCase {
	
	Keyboard_Simplest	*keyBoard;
}

@end

@implementation Keyboard_SimplestTests

- (void)setUp {
	
	keyBoard = [[Keyboard_Simplest alloc] init];
	keyBoard.offset = 0;
}

- (void)tearDown {
	
	[keyBoard release];
}

- (void)testKeyPresses {
	// - (void)pressedKey:(int)keyIndex
	// - (void)releasedKey:(int)keyIndex
	
	OCMockObject *mockAmplitudeLookup = [OCMockObject mockForClass:[AmplitudeCurve class]];
	CGFloat amp = 0.5f;
	[[[mockAmplitudeLookup stub] andReturnValue:OCMOCK_VALUE(amp)] mapEarResponseToAmplitudeForFreq:440.0];
	[keyBoard setAmplitudeLookup:(id)mockAmplitudeLookup];

	// Mock a note-Lookup
	OCMockObject *mockNoteLookup = [OCMockObject mockForProtocol:@protocol(NoteLookupProtocol)];
	double expectedHz = 440.0;
	[[[mockNoteLookup expect] andReturnValue:OCMOCK_VALUE(expectedHz)] hzForStepsAboveA4:0]; // use 'andReturnValue' for primitives : 'andReturn' for objects
	keyBoard.noteLookup = (id)mockNoteLookup;

	// Mock a sound-source
	OCMockObject *mockSoundSource = [OCMockObject mockForProtocol:@protocol(SoundsSourceProtocol)];
	int channelID = 0;
	[[[mockSoundSource expect] andReturnValue:OCMOCK_VALUE(channelID)] playSine:440.0 amp:amp]; // use 'andReturnValue' for primitives : 'andReturn' for objects
	[keyBoard connectOutputTo:(id)mockSoundSource];

	// Press and release a key
	[keyBoard pressedKey:0];
	[mockNoteLookup verify];
	[mockSoundSource verify];
	
	[[[mockNoteLookup expect] andReturnValue:OCMOCK_VALUE(expectedHz)] hzForStepsAboveA4:0]; // use 'andReturnValue' for primitives : 'andReturn' for objects
	[[[mockSoundSource expect] andReturnValue:OCMOCK_VALUE(channelID)] stopSine:440.0]; // use 'andReturnValue' for primitives : 'andReturn' for objects
	[keyBoard releasedKey:0];
	[mockNoteLookup verify];
	[mockSoundSource verify];

	// Clean up
	[keyBoard connectOutputTo:nil];
	keyBoard.noteLookup = nil;
}

@end
