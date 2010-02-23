//
//  BufferStoreTests.m
//  AudioFileParser
//
//  Created by steve hooley on 23/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "BufferStore.h"
#import "HooleyStuff.h"
#import <SHShared/SHShared.h>

@interface BufferStoreTests : SenTestCase {
	
	BufferStore *_testStore;
}

@end

@implementation BufferStoreTests

- (void)setUp {
	_testStore = [[BufferStore alloc] init];
}

- (void)tearDown {
	[_testStore release];
}

- (void)testWholeBlocksAndRemainder {
	
	[_testStore setBlockSize:10];
	STAssertTrue(3==[_testStore numberOfWholeBlocksFrom:33], @"err");
	STAssertTrue(0==[_testStore numberOfWholeBlocksFrom:9], @"err");
	STAssertTrue(1==[_testStore numberOfWholeBlocksFrom:10], @"err");
	STAssertTrue(1==[_testStore numberOfWholeBlocksFrom:11], @"err");
	STAssertTrue(1==[_testStore numberOfWholeBlocksFrom:19], @"err");
	
	STAssertTrue(3==[_testStore remainderFrom:33], @"err");
	STAssertTrue(9==[_testStore remainderFrom:9], @"err");
	STAssertTrue(0==[_testStore remainderFrom:10], @"err");
	STAssertTrue(1==[_testStore remainderFrom:11], @"err");
	STAssertTrue(9==[_testStore remainderFrom:19], @"err");
}

- (void)testFramesNeededToCompletePartialStore {
	// - (NSUInteger)framesNeededToCompletePartialStore

	struct HooAudioBuffer *hooBuff = newHooAudioBuffer(5,0);
	
	[_testStore setBlockSize:10];
	[_testStore addFrames:5 :hooBuff];
	STAssertTrue(5==[_testStore framesNeededToCompletePartialStore], @"doh");
}

- (void)testAddFrames {
	
	// test simple case
	[_testStore setBlockSize:10];
	struct HooAudioBuffer *hooBuff1 = newHooAudioBuffer(10,0);
	[_testStore addFrames:10 :hooBuff1];
	STAssertTrue(1==[_testStore numberOfWholeBuffers], @"oops");

	struct HooAudioBuffer *hooBuff2 = newHooAudioBuffer(10,0);
	[_testStore addFrames:10 :hooBuff2];

	struct HooAudioBuffer *hooBuff3 = newHooAudioBuffer(10,0);
	[_testStore addFrames:10 :hooBuff3];
	STAssertTrue(3==[_testStore numberOfWholeBuffers], @"oops");

	// test slightly more complex
	struct HooAudioBuffer *hooBuff4 = newHooAudioBuffer(20,0);
	[_testStore addFrames:20 :hooBuff4];
	STAssertTrue(5==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);
	
	// test add partial buffer
	struct HooAudioBuffer *hooBuff5 = newHooAudioBuffer(5,0);
	[_testStore addFrames:5 :hooBuff5];
	STAssertTrue( 5==[_testStore framesInPartialStore], @"doh");
	
	struct HooAudioBuffer *hooBuff6 = newHooAudioBuffer(3,0);
	[_testStore addFrames:3 :hooBuff6];
	STAssertTrue( 8==[_testStore framesInPartialStore], @"doh %i", [_testStore framesInPartialStore]);
	
	struct HooAudioBuffer *hooBuff7 = newHooAudioBuffer(2,0);
	[_testStore addFrames:2 :hooBuff7];
	STAssertTrue( 0==[_testStore framesInPartialStore], @"doh");
	STAssertTrue( 6==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);
	
	// leave the partial store half full
	struct HooAudioBuffer *hooBuff8 = newHooAudioBuffer(5,0);
	[_testStore addFrames:5 :hooBuff8];
	// now try to add a full buffer
	struct HooAudioBuffer *hooBuff9 = newHooAudioBuffer(10,0);
	[_testStore addFrames:10 :hooBuff9];
	STAssertTrue( 5==[_testStore framesInPartialStore], @"doh");
	STAssertTrue( 7==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);
	
	struct HooAudioBuffer *hooBuff10 = newHooAudioBuffer(5,0);	
	[_testStore addFrames:5 :hooBuff10];
	STAssertTrue( 0==[_testStore framesInPartialStore], @"doh");
	STAssertTrue( 8==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);
	
	freeHooAudioBuffer(hooBuff10);
	freeHooAudioBuffer(hooBuff9);
	freeHooAudioBuffer(hooBuff8);
	freeHooAudioBuffer(hooBuff7);
	freeHooAudioBuffer(hooBuff6);
	freeHooAudioBuffer(hooBuff5);
	freeHooAudioBuffer(hooBuff4);
	freeHooAudioBuffer(hooBuff3);
	freeHooAudioBuffer(hooBuff2);
	freeHooAudioBuffer(hooBuff1);
}

- (void)testAddFramesWithValues {
	
	[_testStore setBlockSize:4];
	
	struct HooAudioBuffer *hooBuff1 = newHooAudioBuffer(2,0);
	Float32 *memAddr1 = memAddr_HooAudioBuffer(hooBuff1);
	STAssertTrue( G3DCompareFloat(0.f,memAddr1[0],0.01f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(1.f,memAddr1[1],0.01f)==0, @"doh");

	struct HooAudioBuffer *hooBuff2 = newHooAudioBuffer(2,2);	
	Float32 *memAddr2 = memAddr_HooAudioBuffer(hooBuff2);
	STAssertTrue( G3DCompareFloat(2.f,memAddr2[0],0.01f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(3.f,memAddr2[1],0.01f)==0, @"doh");

	[_testStore addFrames:2 :hooBuff1];
	[_testStore addFrames:2 :hooBuff2];
	STAssertTrue(1==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);

	Float32 *firstBuffer = [_testStore bufferAtIndex:0];
	for(NSUInteger i=0; i<4; i++){
		STAssertTrue( G3DCompareFloat( firstBuffer[i], (i*1.f), 0.001f)==0, @"doh %i, %f", i, firstBuffer[i]);
	}
	freeHooAudioBuffer(hooBuff2);
	freeHooAudioBuffer(hooBuff1);
}

- (void)testBasicPtrAdvanceStuff {
	
	struct HooAudioBuffer *hooBuff = newHooAudioBuffer(6,0);

	Float32 *memAddr1 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(0.f,memAddr1[0],0.01f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(1.f,memAddr1[1],0.01f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(2.f,memAddr1[2],0.01f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(3.f,memAddr1[3],0.01f)==0, @"doh");

	hooBuff->theOffset = 1;
	Float32 *memAddr2 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(1.f,memAddr2[0],0.01f)==0, @"doh %f", memAddr2[0]);
	STAssertTrue( G3DCompareFloat(2.f,memAddr2[1],0.01f)==0, @"doh %f", memAddr2[1]);
	STAssertTrue( G3DCompareFloat(3.f,memAddr2[2],0.01f)==0, @"doh");
	
	hooBuff->theOffset = hooBuff->theOffset+1;
	Float32 *memAddr3 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(2.f,memAddr3[0],0.01f)==0, @"doh %f", memAddr3[0]);
	STAssertTrue( G3DCompareFloat(3.f,memAddr3[1],0.01f)==0, @"doh %f", memAddr3[1]);
	
	freeHooAudioBuffer(hooBuff);
}

- (void)testAdvanceDataPtrBy {
	//- (void)_advanceDataPtr:(AudioBuffer **)inputBuffer by:(NSUInteger)frameCount
	
	struct HooAudioBuffer *hooBuff = newHooAudioBuffer(6,0);
	
	NSUInteger neededSize = sizeof(Float32)*6;
	STAssertTrue(neededSize==hooBuff->theBuffer->mDataByteSize, @"doh %i", neededSize);
	Float32 *memAddr1 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(0.0f,memAddr1[0],0.001f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(1.0f,memAddr1[1],0.001f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(2.0f,memAddr1[2],0.001f)==0, @"doh");
	
	advanceDataPtr( hooBuff, 2 );
	
	Float32 *memAddr2 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(2.0f,memAddr2[0],0.01f)==0, @"doh %f", memAddr2[0]);
	STAssertTrue( G3DCompareFloat(3.0f,memAddr2[1],0.01f)==0, @"doh %f", memAddr2[1]);
	STAssertTrue( G3DCompareFloat(4.0f,memAddr2[2],0.01f)==0, @"doh %f", memAddr2[2]);
	
	freeHooAudioBuffer(hooBuff);
}

- (void)testBufferWithWeakReference {

	AudioBuffer *outAudioBuffer = audioBuffer( 6, 0 );
	struct HooAudioBuffer *hooBuff = newHooAudioBuffer_weak( outAudioBuffer, 6, 0 );
	
	NSUInteger neededSize = sizeof(Float32)*6;
	STAssertTrue(neededSize==hooBuff->theBuffer->mDataByteSize, @"doh %i", neededSize);
	Float32 *memAddr1 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(0.0f,memAddr1[0],0.001f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(1.0f,memAddr1[1],0.001f)==0, @"doh");
	STAssertTrue( G3DCompareFloat(2.0f,memAddr1[2],0.001f)==0, @"doh");
	
	advanceDataPtr( hooBuff, 2 );
	
	Float32 *memAddr2 = memAddr_HooAudioBuffer(hooBuff);
	STAssertTrue( G3DCompareFloat(2.0f,memAddr2[0],0.01f)==0, @"doh %f", memAddr2[0]);
	STAssertTrue( G3DCompareFloat(3.0f,memAddr2[1],0.01f)==0, @"doh %f", memAddr2[1]);
	STAssertTrue( G3DCompareFloat(4.0f,memAddr2[2],0.01f)==0, @"doh %f", memAddr2[2]);

	free(hooBuff);
	free(outAudioBuffer);
}

- (void)testCloseInput {
	
	[_testStore setBlockSize:6];
	
	struct HooAudioBuffer *hooBuff1 = newHooAudioBuffer(3,0);
	struct HooAudioBuffer *hooBuff2 = newHooAudioBuffer(3,3);
	struct HooAudioBuffer *hooBuff3 = newHooAudioBuffer(2,6);	

	[_testStore addFrames:3 :hooBuff1];
	[_testStore addFrames:3 :hooBuff2];
	[_testStore addFrames:2 :hooBuff3];

	STAssertTrue(1==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);
	
	[_testStore closeInput];
	STAssertTrue(2==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);

	Float32 *firstBuffer = [_testStore bufferAtIndex:0];
	for(NSUInteger i=0; i<6; i++){
		STAssertTrue( G3DCompareFloat( firstBuffer[i], (i*1.f), 0.001f)==0, @"doh %i, %f", i, firstBuffer[i]);
	}
	
	Float32 *secondBuffer = [_testStore bufferAtIndex:1];
	STAssertTrue( G3DCompareFloat( secondBuffer[0], 6.f, 0.001f)==0, @"doh %f", secondBuffer[0]);
	STAssertTrue( G3DCompareFloat( secondBuffer[1], 7.f, 0.001f)==0, @"doh %f", secondBuffer[1]);
	STAssertTrue( G3DCompareFloat( secondBuffer[2], 0.f, 0.001f)==0, @"doh %f", secondBuffer[2]);
	STAssertTrue( G3DCompareFloat( secondBuffer[3], 0.f, 0.001f)==0, @"doh %f", secondBuffer[3]);
	STAssertTrue( G3DCompareFloat( secondBuffer[4], 0.f, 0.001f)==0, @"doh %f", secondBuffer[4]);
	STAssertTrue( G3DCompareFloat( secondBuffer[5], 0.f, 0.001f)==0, @"doh %f", secondBuffer[5]);

	freeHooAudioBuffer(hooBuff3);
	freeHooAudioBuffer(hooBuff2);
	freeHooAudioBuffer(hooBuff1);
}

- (void)testIterateSamples {
	
	[_testStore setBlockSize:4];
	struct HooAudioBuffer *hooBuff1 = newHooAudioBuffer(12,0);
	[_testStore addFrames:12 :hooBuff1];
	[_testStore closeInput];
	STAssertTrue(3==[_testStore numberOfWholeBuffers], @"oops %i", [_testStore numberOfWholeBuffers]);

	[_testStore resetReading];
	NSUInteger blockCount=0;
	while([_testStore hasMoreSamples]){
		Float32 *aSingleBlock = [_testStore nextSamples];
		for(NSUInteger i=0; i<4; i++){
			Float32 expectedValue = (i*1.f+(blockCount*4));
			STAssertTrue( G3DCompareFloat( aSingleBlock[i], expectedValue, 0.001f)==0, @"doh %i, %f", i, aSingleBlock[i]);
		}
		blockCount++;
	}
	STAssertTrue(3==blockCount, @"blockCount %i", blockCount);
	freeHooAudioBuffer(hooBuff1);
}

@end
