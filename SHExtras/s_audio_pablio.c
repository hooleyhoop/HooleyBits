/*

 * pablio.c
 * Portable Audio Blocking Input/Output utility.
 *
 * Author: Phil Burk, http://www.softsynth.com
 *
 * This program uses the PortAudio Portable Audio Library.
 * For more information see: http://www.audiomulch.com/portaudio/
 * Copyright (c) 1999-2000 Ross Bencina and Phil Burk
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * Any person wishing to distribute modifications to the Software is
 * requested to send the modifications to the original developer so that
 * they can be incorporated into the canonical version.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

 /* changes by Miller Puckette to support Pd:  device selection, 
    settable audio buffer size, and settable number of channels.
    LATER also fix it to poll for input and output fifo fill points. */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "portaudio.h"
#include "s_audio_paring.h"
#include "s_audio_pablio.h"     /* MSP */
#include <string.h>
// #import "pa_mac_hostapis.c"


    /* MSP -- FRAMES_PER_BUFFER constant removed */
static void NPa_Sleep(int n)    /* MSP wrapper to check we never stall... */
{
#if 0
    fprintf(stderr, "sleep\n");
#endif
    Pa_Sleep(n);
}

/************************************************************************/
/******** Prototypes ****************************************************/
/************************************************************************/


//#ifdef PA19
//static int blockingIOCallback( const void *inputBuffer, void *outputBuffer, /*MSP */
//                               unsigned long framesPerBuffer,
//                               const PaStreamCallbackTimeInfo *outTime, 
//                              PaStreamCallbackFlags myflags, 
 //                              void *userData );
//#else
static int blockingIOCallback( void *inputBuffer, void *outputBuffer,
                               unsigned long framesPerBuffer,
                               PaTimestamp outTime, void *userData );
//#endif
							   
static PaError PABLIO_InitFIFO( RingBuffer *rbuf, long numFrames, long bytesPerFrame );
static PaError PABLIO_TermFIFO( RingBuffer *rbuf );

/************************************************************************/
/******** Functions *****************************************************/
/************************************************************************/

/* Called from PortAudio.
 * Read and write data only if there is room in FIFOs.
 */
//#ifdef PA19
//static int blockingIOCallback( const void *inputBuffer, void *outputBuffer, /* MSP */
//                               unsigned long framesPerBuffer,
//                               const PaStreamCallbackTimeInfo *outTime, 
//                               PaStreamCallbackFlags myflags, 
//                               void *userData )
//#else

/*
 * This is called at different times to WriteAudioStream. Always seems to write 512 bytes
*/
static int blockingIOCallback( void *inputBuffer, void *outputBuffer,  unsigned long framesPerBuffer,  PaTimestamp outTime, void *userData )
//#endif
{
    PABLIO_Stream *data = (PABLIO_Stream*)userData;
    (void) outTime;

    /* This may get called with NULL inputBuffer during initial setup. */
    if( inputBuffer != NULL )
    {
		// printf("s_audio_pablio.c: WriteAudioStream. blockingIOCallback %i \n", (data->inbytesPerFrame * framesPerBuffer) );
        RingBuffer_Write( &data->inFIFO, inputBuffer, data->inbytesPerFrame * framesPerBuffer );
    }
    if( outputBuffer != NULL )
    {
        int i;
        int numBytes = data->outbytesPerFrame * framesPerBuffer;
        int numRead = RingBuffer_Read( &data->outFIFO, outputBuffer, numBytes);
        /* Zero out remainder of buffer if we run out of data. */
        for( i=numRead; i<numBytes; i++ )
        {
            ((char *)outputBuffer)[i] = 0;
        }
    }
    return 0;
}

/* Allocate buffer. */
static PaError PABLIO_InitFIFO( RingBuffer *rbuf, long numFrames, long bytesPerFrame )
{
    long numBytes = numFrames * bytesPerFrame;
    char *buffer = (char *) malloc( numBytes );
    if( buffer == NULL ) return paInsufficientMemory;
    memset( buffer, 0, numBytes );
    return (PaError) RingBuffer_Init( rbuf, numBytes, buffer );
}

/* Free buffer. */
static PaError PABLIO_TermFIFO( RingBuffer *rbuf )
{
    if( rbuf->buffer ) free( rbuf->buffer );
    rbuf->buffer = NULL;
    return paNoError;
}

/************************************************************
 * Write data to ring buffer.
 * Will not return until all the data has been written.
 */
 
/*
 * This is called at different times to blockingIOCallback. Always seems to write 512 bytes
*/
long WriteAudioStream( PABLIO_Stream *aStream, void *data, long numFrames )
{
    long bytesWritten;
    char *p = (char *) data;
    long numBytes = aStream->outbytesPerFrame * numFrames;
	// printf("s_audio_pablio.c: WriteAudioStream. writing %i \n", numBytes );
    while( numBytes > 0)
    {
        bytesWritten = RingBuffer_Write( &aStream->outFIFO, p, numBytes );
        numBytes -= bytesWritten;
        p += bytesWritten;
        if( numBytes > 0) NPa_Sleep(10); /* MSP */
    }
    return numFrames;
}

/************************************************************
 * Read data from ring buffer.
 * Will not return until all the data has been read.
 */
long ReadAudioStream( PABLIO_Stream *aStream, void *data, long numFrames )
{
    long bytesRead;
    char *p = (char *) data;
    long numBytes = aStream->inbytesPerFrame * numFrames;
    while( numBytes > 0)
    {
        bytesRead = RingBuffer_Read( &aStream->inFIFO, p, numBytes );
        numBytes -= bytesRead;
        p += bytesRead;
        if( numBytes > 0) NPa_Sleep(10); /* MSP */
    }
    return numFrames;
}

/************************************************************
 * Return the number of frames that could be written to the stream without
 * having to wait.
 */
long GetAudioStreamWriteable( PABLIO_Stream *aStream )
{
    int bytesEmpty = RingBuffer_GetWriteAvailable( &aStream->outFIFO );
    return bytesEmpty / aStream->outbytesPerFrame;
}

/************************************************************
 * Return the number of frames that are available to be read from the
 * stream without having to wait.
 */
long GetAudioStreamReadable( PABLIO_Stream *aStream )
{
    int bytesFull = RingBuffer_GetReadAvailable( &aStream->inFIFO );
    return bytesFull / aStream->inbytesPerFrame;
}

/************************************************************/
static unsigned long RoundUpToNextPowerOf2( unsigned long n )
{
    long numBits = 0;
    if( ((n-1) & n) == 0) return n; /* Already Power of two. */
    while( n > 0 )
    {
        n= n>>1;
        numBits++;
    }
    return (1<<numBits);
}

/************************************************************
 * Opens a PortAudio stream with default characteristics.
 * Allocates PABLIO_Stream structure.
 *
 * flags parameter can be an ORed combination of:
 *    PABLIO_READ, PABLIO_WRITE, or PABLIO_READ_WRITE
 */
PaError OpenAudioStream( PABLIO_Stream **rwblPtr, double sampleRate,
                         PaSampleFormat format, int inchannels,
                         int outchannels, int framesperbuf, int nbuffers,
                         int indeviceno, int outdeviceno) /* MSP */
{
    long   bytesPerSample;
    long   doRead = 0;
    long   doWrite = 0;
    PaError err;
    PABLIO_Stream *aStream;
    long   minNumBuffers; 
    long   numFrames;

//#ifdef PA19
//    PaStreamParameters instreamparams, outstreamparams;  /* MSP */
//#endif

    /* fprintf(stderr,
        "open %lf fmt %d flags %d ch: %d fperbuf: %d nbuf: %d devs: %d %d\n",
           sampleRate, format, flags, nchannels,
           framesperbuf, nbuffers, indeviceno, outdeviceno); */

    if (indeviceno < 0)  /* MSP... */
    {

//#ifdef PA19
//        indeviceno = Pa_GetDefaultInputDevice();
//#else
        indeviceno = Pa_GetDefaultInputDeviceID();
//#endif
        fprintf(stderr, "using default input device number: %d\n", indeviceno);
    }
    if (outdeviceno < 0)
    {

//#ifdef PA19
//        outdeviceno = Pa_GetDefaultOutputDevice();
//#else
        outdeviceno = Pa_GetDefaultOutputDeviceID();
//#endif
        fprintf(stderr, "using default output device number: %d\n", outdeviceno);
    }
    /* fprintf(stderr, "nchan %d, flags %d, bufs %d, framesperbuf %d\n",
            nchannels, flags, nbuffers, framesperbuf); */
        /* ...MSP */

    /* Allocate PABLIO_Stream structure for caller. */
    aStream = (PABLIO_Stream *) malloc( sizeof(PABLIO_Stream) );
    if( aStream == NULL ) return paInsufficientMemory;
    memset( aStream, 0, sizeof(PABLIO_Stream) );

    /* Determine size of a sample. */
    bytesPerSample = Pa_GetSampleSize( format );
    if( bytesPerSample < 0 )
    {
        fprintf(stderr, "error bytes per sample: %i\n", bytesPerSample);	
		err = (PaError) bytesPerSample;
        goto error;
    }
    aStream->insamplesPerFrame = inchannels;  /* MSP */
    aStream->inbytesPerFrame = bytesPerSample * aStream->insamplesPerFrame;
    aStream->outsamplesPerFrame = outchannels;
    aStream->outbytesPerFrame = bytesPerSample * aStream->outsamplesPerFrame;

    /* Initialize PortAudio  */
    err = Pa_Initialize();
    if( err != paNoError ) goto error;


//#ifdef PA19
//    numFrames = nbuffers * framesperbuf; /* ...MSP */

//    instreamparams.device = indeviceno;   /* MSP... */
//    instreamparams.channelCount = inchannels;
//    instreamparams.sampleFormat = format;
//    instreamparams.suggestedLatency = nbuffers*framesperbuf/sampleRate;
//    instreamparams.hostApiSpecificStreamInfo = 0;
    
//    outstreamparams.device = outdeviceno;
//    outstreamparams.channelCount = outchannels;
//    outstreamparams.sampleFormat = format;
//    outstreamparams.suggestedLatency = nbuffers*framesperbuf/sampleRate;
//   outstreamparams.hostApiSpecificStreamInfo = 0;  /* ... MSP */

//#else
/* Warning: numFrames must be larger than amount of data processed per
  interrupt inside PA to prevent glitches. */  /* MSP */
    minNumBuffers = Pa_GetMinNumBuffers(framesperbuf, sampleRate);
    if (minNumBuffers > nbuffers)
        fprintf(stderr, "warning: number of buffers %d less than recommended minimum %d\n",  (int)nbuffers, (int)minNumBuffers);
//#endif

    numFrames = nbuffers * framesperbuf;
    /* fprintf(stderr, "numFrames %d\n", numFrames); */
    /* Initialize Ring Buffers */
    doRead = (inchannels != 0);
    doWrite = (outchannels != 0);
    if(doRead)
    {
        err = PABLIO_InitFIFO( &aStream->inFIFO, numFrames, aStream->inbytesPerFrame );
        if( err != paNoError )
		{
			fprintf(stderr, "error doRead PABLIO_InitFIFO \n");
			goto error;
		}
    }
    if(doWrite)
    {
        long numBytes;
        err = PABLIO_InitFIFO( &aStream->outFIFO, numFrames, aStream->outbytesPerFrame );
        if( err != paNoError ) {
			fprintf(stderr, "error doWrite PABLIO_InitFIFO \n");
			goto error;
			}
        /* Make Write FIFO appear full initially. */
        numBytes = RingBuffer_GetWriteAvailable( &aStream->outFIFO );
        RingBuffer_AdvanceWriteIndex( &aStream->outFIFO, numBytes );
    }

    /* Open a PortAudio stream that we will use to communicate with the underlying
     * audio drivers. */

//#ifdef PA19
 //   err = Pa_OpenStream(
//              &aStream->stream,
//              (doRead ? &instreamparams : 0),  /* MSP */
//              (doWrite ? &outstreamparams : 0),  /* MSP */
//             sampleRate,
 //             framesperbuf,  /* MSP */
 //             paNoFlag,      /* MSP -- portaudio will clip for us */
 //             blockingIOCallback,
//              aStream );
//#else
 //   err = Pa_OpenStream(
 //             &aStream->stream,
//              (doRead ? indeviceno : paNoDevice),  /* MSP */
//              (doRead ? aStream->insamplesPerFrame : 0 ),
//              format,
//              NULL,
//              (doWrite ? outdeviceno : paNoDevice),  /* MSP */
//              (doWrite ? aStream->outsamplesPerFrame : 0 ),
//              format,
//              NULL,
//              sampleRate,
//              framesperbuf,  /* MSP */
//              nbuffers,      /* MSP */
//              paNoFlag,      /* MSP -- portaudio will clip for us */
//              blockingIOCallback,
//              aStream );
// #endif
PortAudioStream   *stream;
err = Pa_OpenDefaultStream( 
	stream, 
	0,
	2, 
	paFloat32, 
	44100,  
	256, 
	0,  
	blockingIOCallback, 
	stream );


    if( err != paNoError ){
		fprintf(stderr, "error Pa_OpenStream \n");
		goto error;
	}
	
    err = Pa_StartStream( aStream->stream );
    if( err != paNoError )      /* MSP */
    {
        fprintf(stderr, "Pa_StartStream failed; closing audio stream...\n");
        CloseAudioStream( aStream );
        goto error;
    }

    *rwblPtr = aStream;
    return paNoError;

error:
    *rwblPtr = NULL;
    return err;
}

/************************************************************/
PaError CloseAudioStream( PABLIO_Stream *aStream )
{
    PaError err;
    int bytesEmpty;
    int byteSize = aStream->outFIFO.bufferSize;

    /* If we are writing data, make sure we play everything written. */
    if( byteSize > 0 )
    {
        bytesEmpty = RingBuffer_GetWriteAvailable( &aStream->outFIFO );
        while( bytesEmpty < byteSize )
        {
            NPa_Sleep( 10 ); /* MSP */
            bytesEmpty = RingBuffer_GetWriteAvailable( &aStream->outFIFO );
        }
    }

    err = Pa_StopStream( aStream->stream );
    if( err != paNoError ) goto error;
    err = Pa_CloseStream( aStream->stream );
    if( err != paNoError ) goto error;
    Pa_Terminate();

error:
    PABLIO_TermFIFO( &aStream->inFIFO );
    PABLIO_TermFIFO( &aStream->outFIFO );
    free( aStream );
    return err;
}
