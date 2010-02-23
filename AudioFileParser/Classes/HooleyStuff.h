/*
 *  HooleyStuff.h
 *  AudioFileParser
 *
 *  Created by Steven Hooley on 25/12/2009.
 *  Copyright 2009 Tinsal Parks. All rights reserved.
 *
 */
#import <CoreAudio/CoreAudioTypes.h>


struct HooAudioBuffer
{
    AudioBuffer *theBuffer;
    UInt32 theOffset;
	bool weak;
};

Float32 * memAddr_HooAudioBuffer( struct HooAudioBuffer *buff );

void freeHooAudioBuffer( struct HooAudioBuffer *buff );

struct HooAudioBuffer * newHooAudioBuffer( UInt32 length, Float32 offset );
struct HooAudioBuffer * newHooAudioBuffer_weak( AudioBuffer *outAudioBuffer, UInt32 length, Float32 offset );

AudioBuffer * audioBuffer( UInt32 length, Float32 offset );

void advanceDataPtr(struct HooAudioBuffer *inputBufferPtr, UInt32 frameCount );
