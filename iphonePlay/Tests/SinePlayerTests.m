//
//  SinePlayerTests.m
//  iphonePlay
//
//  Created by steve hooley on 27/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SinePlayer.h"
#import "GTMSenTestCase.h"
#import <OCMock/OCMock.h>
#import "LowLevelSoundGeneratorProtocol.h"

#define HC_SHORTHAND
#import <hamcrest/hamcrest.h>

@interface SinePlayerTests : SenTestCase {
	
	SinePlayer *sinPlayer;
	OCMockObject *mockSoundInfrastructure;
}

@end

@implementation SinePlayerTests

- (void)setUp {
	
	mockSoundInfrastructure = [[OCMockObject mockForProtocol:@protocol(LowLevelSoundGeneratorProtocol)] retain];
	sinPlayer = [[SinePlayer SinePlayerWithInfrastructure:(id)mockSoundInfrastructure] retain];
}

- (void)tearDown {

	[sinPlayer release];
	[mockSoundInfrastructure release];
}

/* OCMock 101 
 * andReturnValue is for wrapped prmitives - OCMOCK_VALUE wraps your pimitive value for you
 * andReturn is for ObjC types
*/
- (void)testSinplayer {
	// - (int)playSine:(float)freq amp:(CGFloat)amplitude

	// 1 wave
	int expectedChannel = 0;
	[[[mockSoundInfrastructure expect] andReturnValue:OCMOCK_VALUE(expectedChannel)] nextFreeChanel];
	[[mockSoundInfrastructure expect] turnOnSine:expectedChannel freq:440.0 amp:0.5f];
	int playChannelIdentifier0 = [sinPlayer playSine:440.0 amp:0.5f];	
	STAssertTrue( playChannelIdentifier0==expectedChannel, @"Identifier of used channel should be 0 - is %i", playChannelIdentifier0 );
	[mockSoundInfrastructure verify];

	// 2 waves
	expectedChannel = 1;
	[[[mockSoundInfrastructure expect] andReturnValue:OCMOCK_VALUE(expectedChannel)] nextFreeChanel];
	[[mockSoundInfrastructure expect] turnOnSine:expectedChannel freq:450.0 amp:0.5f];
	int playChannelIdentifier1 = [sinPlayer playSine:450.0 amp:0.5];	
	STAssertTrue( playChannelIdentifier1==expectedChannel, @"channelIdentifier1 should be 1 is %i", playChannelIdentifier1);
	[mockSoundInfrastructure verify];

	// 3 waves
	expectedChannel = 2;
	[[[mockSoundInfrastructure expect] andReturnValue:OCMOCK_VALUE(expectedChannel)] nextFreeChanel];
	[[mockSoundInfrastructure expect] turnOnSine:expectedChannel freq:460.0 amp:0.5f];
	int playChannelIdentifier2 = [sinPlayer playSine:460.0 amp:0.5f];	
	STAssertTrue( playChannelIdentifier2==expectedChannel, @"identifier should be 2 is %i", playChannelIdentifier2);
	[mockSoundInfrastructure verify];

	// turn them off 1 at a time
	[[mockSoundInfrastructure expect] turnOffSine:2];
	[sinPlayer stopSine:460.0];
	[mockSoundInfrastructure verify];

	[[mockSoundInfrastructure expect] turnOffSine:1];
	[sinPlayer stopSine:450.0];
	[mockSoundInfrastructure verify];

	[[mockSoundInfrastructure expect] turnOffSine:0];
	[sinPlayer stopSine:440.0];
	[mockSoundInfrastructure verify];
}

@end
