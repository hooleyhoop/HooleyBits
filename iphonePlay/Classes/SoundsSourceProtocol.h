/*
 *  LowLevelSoundGeneratorProtocol.h
 *  iphonePlay
 *
 *  Created by steve hooley on 28/01/2009.
 *  Copyright 2009 BestBefore Ltd. All rights reserved.
 *
 */

@protocol SoundsSourceProtocol

- (int)playSine:(double)freq amp:(CGFloat)amplitude ;	
- (int)stopSine:(double)freq;

@end
