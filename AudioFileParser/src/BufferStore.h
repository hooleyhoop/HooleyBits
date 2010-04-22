//
//  BufferStore.h
//  AudioFileParser
//
//  Created by steve hooley on 23/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "HooleyStuff.h"

@interface BufferStore : NSObject {

	NSUInteger		_blockSize, _framesInPartialStore;
	NSPointerArray	*_allBuffers;
	Float32			*_partialStore;
	NSUInteger		_readIteration;
	NSUInteger		_readSize;
	NSUInteger		_overlap;
}

- (void)addFrames:(NSUInteger)frameCount :(struct HooAudioBuffer *)inputBuffer;
- (void)noMoreData;

- (void)closeInput;

- (void)resetReading;
- (BOOL)hasMoreSamples;
- (Float32 *)nextSamples;

- (void)setReadSize:(NSUInteger)arg1 overlap:(NSUInteger)arg2;
- (void)setBlockSize:(NSUInteger)value;
- (NSUInteger)numberOfWholeBlocksFrom:(NSUInteger)value;
- (NSUInteger)remainderFrom:(NSUInteger)value;
- (NSUInteger)numberOfWholeBuffers;
- (NSUInteger)framesInPartialStore;
- (NSUInteger)framesNeededToCompletePartialStore;

- (Float32 *)bufferAtIndex:(NSUInteger)i;
@end
