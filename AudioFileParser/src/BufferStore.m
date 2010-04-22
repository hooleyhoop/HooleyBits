//
//  BufferStore.m
//  AudioFileParser
//
//  Created by steve hooley on 23/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "BufferStore.h"
#import <SHShared/SHShared.h>

@implementation BufferStore

- (id)init {

	self = [super init];
	if(self){
		_blockSize = 1024;
		_framesInPartialStore = 0;
		_allBuffers = [[NSPointerArray pointerArrayWithWeakObjects] retain];
		_partialStore = (Float32 *)calloc(_blockSize, sizeof(Float32));
	}
	return self;
}

- (void)dealloc {

	for( NSUInteger i=0; i<[_allBuffers count]; i++ ){
		Float32 *buffer = (Float32 *)[_allBuffers pointerAtIndex:i];
		free(buffer);
	}
	free(_partialStore);

	[_allBuffers release];
	[super dealloc];
}

//* HOOLEY - create a buffer to hold all frames **/
//AudioBuffer completeInputBuffer;
//completeInputBuffer.mNumberChannels = 1;
//completeInputBuffer.mDataByteSize = myInfo.mDataFormat.mSampleRate
//Float32* dataPtr = (Float32 *)calloc(1024, sizeof(Float32));
//completeInputBuffer.mData = dataPtr;
- (void)_movePartialStoreToBufferArray {

	// copy the partial store frames to main buffer store
	Float32 *newBuffer = (Float32 *)calloc(_blockSize, sizeof(Float32));
	Float32 one1 = _partialStore[0];
	Float32 two1 = _partialStore[1];
	Float32 three1 = _partialStore[2];
	Float32 four1 = _partialStore[3];

	memcpy(newBuffer, _partialStore, _blockSize*sizeof(Float32));
	Float32 one2 = _partialStore[0];
	Float32 two2 = _partialStore[1];
	Float32 three2 = _partialStore[2];
	Float32 four2 = _partialStore[3];
	
	NSAssert( G3DCompareFloat( one1,one2,0.01f)==0, @"fucker");
	NSAssert( G3DCompareFloat( two1,two2,0.01f)==0, @"fucker");
	NSAssert( G3DCompareFloat( three1,three2,0.01f)==0, @"fucker");
	NSAssert( G3DCompareFloat( four1,four2,0.01f)==0, @"fucker");

	[_allBuffers addPointer:newBuffer];
	_framesInPartialStore = 0;
}

- (NSUInteger)_donateFramesToPartialStore:(NSUInteger)frameCount :(NSUInteger)numberOfFramesToDonateToPartialStore :(struct HooAudioBuffer *)inputBuffer {
	
	NSParameterAssert(frameCount>=numberOfFramesToDonateToPartialStore);

	Float32 *data = memAddr_HooAudioBuffer(inputBuffer);
	Float32 one1 = data[0];
	Float32 two1 = data[1];
	// copy the right amount of frames from inputBuffer to partial store
	// memcpy(void *restrict s1, const void *restrict s2, size_t n) copy from s1 to s2
	memcpy( _partialStore+_framesInPartialStore, data, numberOfFramesToDonateToPartialStore*sizeof(Float32));
	
	Float32 one2 = _partialStore[0+_framesInPartialStore];
	Float32 two2 = _partialStore[1+_framesInPartialStore];
	NSAssert( G3DCompareFloat( one1,one2,0.01f)==0, @"fucker");
	NSAssert( G3DCompareFloat( two1,two2,0.01f)==0, @"fucker");

	_framesInPartialStore = _framesInPartialStore+numberOfFramesToDonateToPartialStore;

	advanceDataPtr( inputBuffer, numberOfFramesToDonateToPartialStore);
	
	return frameCount-numberOfFramesToDonateToPartialStore;
}

- (void)_checkPartialStoreComplete {
	
	if(_framesInPartialStore==_blockSize){
		[self _movePartialStoreToBufferArray];
	}
}

- (void)closeInput {
	
	if(_framesInPartialStore)
	{
		// zero out unfilled bytes
		int remainder = _blockSize-_framesInPartialStore;
		Float32 *dest = _partialStore+_framesInPartialStore;
		memset( dest, 0, remainder*sizeof(Float32) );

		[self _movePartialStoreToBufferArray];
	}
}

- (void)addFrames:(NSUInteger)frameCount :(struct HooAudioBuffer *)inputBuffer {
	
	NSAssert( frameCount==((inputBuffer->theBuffer->mDataByteSize/sizeof(Float32))-inputBuffer->theOffset), @"This will only be true for single channel?" );
	
	if(_framesInPartialStore)
	{
		NSUInteger framesNeededToCompletePartialStore = [self framesNeededToCompletePartialStore];
		NSUInteger numberOfFramesToDonateToPartialStore;
		if(frameCount>framesNeededToCompletePartialStore)
			numberOfFramesToDonateToPartialStore = frameCount-framesNeededToCompletePartialStore;
		else
			numberOfFramesToDonateToPartialStore = frameCount;
		
		frameCount = [self _donateFramesToPartialStore:frameCount :numberOfFramesToDonateToPartialStore :inputBuffer];

		[self _checkPartialStoreComplete];
	}
	
	// how many whole blocks?
	NSUInteger wholeBlocks = [self numberOfWholeBlocksFrom:frameCount];
	for( NSUInteger i=0; i<wholeBlocks; i++ )
	{
		// copy in the whole blocks
		Float32 *newBuffer = (Float32 *)calloc(_blockSize, sizeof(Float32));
		Float32 *data = memAddr_HooAudioBuffer(inputBuffer);
		Float32 one1 = data[0];
		Float32 two1 = data[1];
		memcpy(newBuffer, data, _blockSize*sizeof(Float32));
		Float32 one2 = newBuffer[0];
		Float32 two2 = newBuffer[1];
		NSAssert( G3DCompareFloat(one1,one2,0.001f)==0, @"fucker" );
		NSAssert( G3DCompareFloat(two1,two2,0.001f)==0, @"fucker" );
	
		[_allBuffers addPointer:newBuffer];
		advanceDataPtr( inputBuffer, _blockSize );
		frameCount = frameCount-_blockSize;
	}

	NSUInteger remainderBlocks = [self remainderFrom:frameCount];
	if(remainderBlocks){

		frameCount = [self _donateFramesToPartialStore:frameCount :remainderBlocks :inputBuffer];
		NSAssert(0==frameCount, @"doh - framecount seems wrong");

		[self _checkPartialStoreComplete];
	}
}

- (void)noMoreData {
	logError(@"make sure we fluuuuush!");
}

- (void)resetReading {
	_readIteration = 0;
}

- (BOOL)hasMoreSamples {
	
	return _readIteration<[self numberOfWholeBuffers];
}

- (Float32 *)nextSamples {
	
	void *ptr = [_allBuffers pointerAtIndex:_readIteration]; // uint8_t
	_readIteration++;
	return (Float32 *)ptr;
}

- (void)setReadSize:(NSUInteger)arg1 overlap:(NSUInteger)arg2 {
	_readSize = arg1;
	_overlap = arg2;
}

- (void)setBlockSize:(NSUInteger)value {
	
	free(_partialStore);
	_blockSize = value;
	_partialStore = (Float32 *)calloc(_blockSize, sizeof(Float32));
}

- (NSUInteger)numberOfWholeBlocksFrom:(NSUInteger)value {
	return value/_blockSize;
}

- (NSUInteger)remainderFrom:(NSUInteger)value {
	return value%_blockSize;
}

- (NSUInteger)numberOfWholeBuffers {
	return [_allBuffers count];
}

- (NSUInteger)framesInPartialStore {
	return _framesInPartialStore;
}

- (NSUInteger)framesNeededToCompletePartialStore {
	return _blockSize - _framesInPartialStore;
}

- (Float32 *)bufferAtIndex:(NSUInteger)i {
	return (Float32 *)[_allBuffers pointerAtIndex:i];
}
@end
