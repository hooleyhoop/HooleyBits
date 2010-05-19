//
//  SinePlayer.h
//  iphonePlay
//
//  Created by steve hooley on 27/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LowLevelSoundGeneratorProtocol.h"
#import "SHooleyObject.h"
#import "SoundsSourceProtocol.h"


@interface SinePlayer : SHooleyObject <SoundsSourceProtocol> {

	NSMutableDictionary *channelFreqLookup;
	NSObject <LowLevelSoundGeneratorProtocol>* _lowLevelSoundGenerator;
}

+ (id)SinePlayerWithInfrastructure:(NSObject<LowLevelSoundGeneratorProtocol>*)soundInfrastructure;

- (int)playSine:(CGFloat)freq amp:(CGFloat)amplitude;	
- (void)stopSine:(CGFloat)freq;

@end
