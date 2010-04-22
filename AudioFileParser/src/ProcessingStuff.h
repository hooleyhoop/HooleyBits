//
//  ProcessingStuff.h
//  AudioFileParser
//
//  Created by steve hooley on 21/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import <CoreAudio/CoreAudio.h>

@class BacwardsProcessTests;

@interface ProcessingStuff : NSObject {
	
	NSPointerArray	*_allFFTMagnitudes;
	
	BacwardsProcessTests *_backwardsProcessor;

}

- (void)processSomeAudio:(UInt32)inFramesToProcess :(AudioBufferList *)inputBufList;

- (void)storeMagnitudes:(Float32 *)mags;
- (NSPointerArray *)allFFTMagnitudes;

@end
