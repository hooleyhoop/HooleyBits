/*
 *  LowLevelSoundGeneratorProtocol.h
 *  iphonePlay
 *
 *  Created by steve hooley on 28/01/2009.
 *  Copyright 2009 BestBefore Ltd. All rights reserved.
 *
 */

@protocol LowLevelSoundGeneratorProtocol

- (int)nextFreeChanel; // will return -1 if no free channels

- (void)turnOnSine:(UInt8)inIndex freq:(float)freq amp:(CGFloat)amplitude;
- (void)turnOffSine:(UInt8)inIndex;


@end
