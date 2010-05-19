//
//  SinePlayer.m
//  iphonePlay
//
//  Created by steve hooley on 27/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SinePlayer.h"
#import "LogController.h"

@implementation SinePlayer

#define MAX_WAVES 3

- (id)init {
	
	self = [super init];
	if(self){
		channelFreqLookup = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return self;
}

- (void)dealloc {
	
	[channelFreqLookup release];
	[super dealloc];
}

+ (id)SinePlayerWithInfrastructure:(NSObject<LowLevelSoundGeneratorProtocol>*)soundInfrastructure {
	
	SinePlayer *newSinPlayer = [[SinePlayer alloc] init];
	newSinPlayer->_lowLevelSoundGenerator = soundInfrastructure;
	return [newSinPlayer autorelease];
}

- (int)playSine:(CGFloat)freq amp:(CGFloat)amplitude {
	
	NSParameterAssert(amplitude>=0.0 && amplitude<=1.0);

	int channelID = [_lowLevelSoundGenerator nextFreeChanel];
	if(channelID!=-1){
		NSAssert(channelID>-1, @"incorrect channel number");
		// logInfo(@"Turning On Sin %f on Channel %i", (float)freq, channelID );
		[_lowLevelSoundGenerator turnOnSine:channelID freq:freq amp:amplitude];
		[channelFreqLookup setObject:[NSNumber numberWithUnsignedInt:channelID] forKey:[NSNumber numberWithDouble:freq]];
	} else {
		logWarning(@"No more free channels?");
	}
	return channelID;
}

- (void)stopSine:(CGFloat)freq {
	
	NSNumber *channel = [channelFreqLookup objectForKey:[NSNumber numberWithDouble:freq]];
	NSAssert1( channel, @"can't find a playing channel with that frequency - %f", (float)freq );
	
	[_lowLevelSoundGenerator turnOffSine:[channel unsignedIntValue]];
}

@end
