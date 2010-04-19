/*
 *  HooleyStuff.h
 *  AudioFileParser
 *
 *  Created by Steven Hooley on 25/12/2009.
 *  Copyright 2009 Tinsal Parks. All rights reserved.
 *
 */
#import "HooleyStuff.h"
#import <stdlib.h>
#import <stdio.h>

Float32 * memAddr_HooAudioBuffer( struct HooAudioBuffer *buff ) {
	
	NSCParameterAssert( buff!=NULL );

//	AudioBuffer theBuffer;
//    UInt32 theOffset;
//	
//    UInt32  mNumberChannels;
//    UInt32  mDataByteSize;
//    void*   mData;
	Float32 *iwish = (Float32 *)buff->theBuffer->mData;
	iwish = iwish+buff->theOffset;
	return iwish;
}

struct HooAudioBuffer * copyHooAudioBuffer( struct HooAudioBuffer *buff ) {
	
	NSCParameterAssert( buff!=NULL );
	return newHooAudioBuffer_copy( buff->theBuffer, buff->length, buff->theOffset );
}

void freeHooAudioBuffer( struct HooAudioBuffer *buff ){

	NSCParameterAssert( buff!=NULL );
	if(!buff->weak){
		free(buff->theBuffer->mData);
		free(buff->theBuffer);
	}
	free(buff);
}

struct HooAudioBuffer * newHooAudioBuffer( UInt32 length, Float32 offset ) {
	
	NSCParameterAssert( length );
	
	UInt32 actuallLength = length+offset;
	struct HooAudioBuffer *hooBuff = (struct HooAudioBuffer *)calloc(1, sizeof(struct HooAudioBuffer) );
	hooBuff->theBuffer = audioBuffer( actuallLength, 0 );
	hooBuff->theOffset = offset;
	hooBuff->length = length;
	return hooBuff;
}

struct HooAudioBuffer * newHooAudioBuffer_weak( AudioBuffer *outAudioBuffer, UInt32 length, Float32 offset ) {

	NSCParameterAssert( outAudioBuffer!=NULL );
	NSCParameterAssert( length );

	struct HooAudioBuffer *hooBuff = (struct HooAudioBuffer *)calloc(1, sizeof(struct HooAudioBuffer) );
	hooBuff->theBuffer = outAudioBuffer;
	hooBuff->theOffset = offset;
	hooBuff->length = length;
	hooBuff->weak = true;
	return hooBuff;
}

// copy the data we are passing in
struct HooAudioBuffer * newHooAudioBuffer_copy( AudioBuffer *outAudioBuffer, UInt32 length, Float32 offset ) {

	NSCParameterAssert( outAudioBuffer!=NULL );
	NSCParameterAssert( length );
	
	struct HooAudioBuffer *hooBuff = newHooAudioBuffer( length, offset );
	memcpy( memAddr_HooAudioBuffer(hooBuff), outAudioBuffer->mData, length*sizeof(Float32) );
	return hooBuff;
}

AudioBuffer * audioBuffer( UInt32 length, Float32 start ) {
	
	NSCParameterAssert( length );

	// generate some fake data - for testing
	Float32 *dataPtr = (Float32 *)calloc(length, sizeof(Float32));
	for(UInt32 i=0; i<length; i++){
		Float32 value = i*1.0f +start;
		dataPtr[i] = value;
	}
	
	// create an AudioBuffer
	AudioBuffer *aBuffer = (AudioBuffer *)calloc(1, sizeof(AudioBuffer));
	aBuffer->mNumberChannels = 1;
	aBuffer->mDataByteSize = sizeof(Float32)*length;
	aBuffer->mData = dataPtr;
	
	return aBuffer;
}

void advanceDataPtr( struct HooAudioBuffer *inputBufferPtr, UInt32 frameCount ){
	
	NSCParameterAssert( inputBufferPtr!=NULL );
	NSCParameterAssert( frameCount );

	inputBufferPtr->theOffset = inputBufferPtr->theOffset+frameCount;
	if( inputBufferPtr->theOffset > sizeof(Float32)*(inputBufferPtr->theBuffer->mDataByteSize)){
		printf("doh\n");
	}
}