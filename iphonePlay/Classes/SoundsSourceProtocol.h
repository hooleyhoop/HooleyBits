/*
 *  LowLevelSoundGeneratorProtocol.h
 *  iphonePlay
 *
 *  Created by steve hooley on 28/01/2009.
 *  Copyright 2009 BestBefore Ltd. All rights reserved.
 *
 */
#import <CoreGraphics/CoreGraphics.h>

@protocol SoundsSourceProtocol

- (int)playSine:(double)freq amp:(CGFloat)amplitude ;	
- (int)stopSine:(double)freq;

@end
