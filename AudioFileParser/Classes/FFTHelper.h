//
//  FFTHelper.h
//  AudioFileParser
//
//  Created by Steven Hooley on 02/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class ProcessingStuff;

@interface FFTHelper : NSObject {

	ProcessingStuff	*_processor;
}

- (void)processSomeAudio:(UInt32)inFramesToProcess :(Float32 *)aSingleBlock;
- (void)saveImage;

- (void)open;
- (void)close;

@end
