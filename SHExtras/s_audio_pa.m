/* Copyright (c) 2001 Miller Puckette and others.
* For information on usage and redistribution, and for a DISCLAIMER OF ALL
* WARRANTIES, see the file, "LICENSE.txt," in this distribution.  */

/* this file calls Ross Bencina's and Phil Burk's Portaudio package.  It's
    the main way in for Mac OS and, with Michael Casey's help, also into
    ASIO in Windows. */


#include "s_audio_pa.h"
#include "s_audio.h"
#include <stdio.h>
#include <stdlib.h>
#include <portaudio.h>
#include "s_audio_pablio.h"

/* LATER try to figure out how to handle default devices in portaudio;
the way s_audio.c handles them isn't going to work here. */

/* public interface declared in m_imp.h */

/* implementation */
static PABLIO_Stream  *pa_stream;
static int pa_inchans, pa_outchans;
static float *pa_soundin, *pa_soundout;

#define MAX_PA_CHANS 32
#define MAX_SAMPLES_PER_FRAME MAX_PA_CHANS * DEFDACBLKSIZE


// #ifndef PA19
	#define Pa_GetDeviceCount Pa_CountDevices
// #endif


int pa_open_audio(int inchans, int outchans, int rate, float *soundin, float *soundout, int framesperbuf, int nbuffers, int indeviceno, int outdeviceno)
{
	printf("s_audio_pa.c: pa_open_audio \n");

    PaError err;
    static int initialized;
    int j, devno, pa_indev = 0, pa_outdev = 0;

    if (!initialized)
    {
        /* Initialize PortAudio  */
        int err = Pa_Initialize();
        if ( err != paNoError ) 
        {
            fprintf( stderr,
                "Error number %d occured initializing portaudio\n",
                err); 
            fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
            return (1);
        }
        initialized = 1;
    }
    /* post("in %d out %d rate %d device %d", inchans, outchans, rate, deviceno); */
    if (inchans > MAX_PA_CHANS)
    {
        NSLog(@"s_audio_pa.m: ERROR! input channels reduced to maximum %d", MAX_PA_CHANS);
        inchans = MAX_PA_CHANS;
    }
    if (outchans > MAX_PA_CHANS)
    {
		NSLog(@"s_audio_pa.m:ERROR output channels reduced to maximum %d", MAX_PA_CHANS);
        outchans = MAX_PA_CHANS;
    }
    
    if (inchans > 0)
    {
        for (j = 0, devno = 0; j < Pa_GetDeviceCount(); j++)
        {
            const PaDeviceInfo *info = Pa_GetDeviceInfo(j);
            if (info->maxInputChannels > 0)
            {
                if (devno == indeviceno)
                {
					NSLog(@"think we make input");

                    pa_indev = j;
                    break;
                }
                devno++;
            }
        }
    }   
    
    if (outchans > 0)
    {
        for (j = 0, devno = 0; j < Pa_GetDeviceCount(); j++)
        {
            const PaDeviceInfo *info = Pa_GetDeviceInfo(j);
            if (info->maxOutputChannels > 0)
            {
                if (devno == outdeviceno)
                {
					NSLog(@"think we make outoput");

                    pa_outdev = j;
                    break;
                }
                devno++;
            }
        }
    }   

//   if (sys_verbose)
//    {
        NSLog(@"input device %d, channels %d", pa_indev, inchans);
		NSLog(@"output device %d, channels %d", pa_outdev, outchans);
        NSLog(@"framesperbuf %d, nbufs %d", framesperbuf, nbuffers);
 //   }
    if (inchans || outchans)
		// stream, 44100, 
        err = OpenAudioStream( &pa_stream, rate, paFloat32, inchans, outchans, framesperbuf, nbuffers,  pa_indev, pa_outdev);
//return Pa_OpenStream( stream, ((numInputChannels > 0) ? Pa_GetDefaultInputDeviceID() : paNoDevice), numInputChannels, sampleFormat, NULL, ((numOutputChannels > 0) ? Pa_GetDefaultOutputDeviceID() : paNoDevice),  numOutputChannels, sampleFormat, NULL,  sampleRate, framesPerBuffer, numberOfBuffers, paNoFlag, callback, userData );


/*************************************************************************/
//PaError Pa_OpenDefaultStream( PortAudioStream** stream, int numInputChannels, int numOutputChannels,  PaSampleFormat sampleFormat, double sampleRate,  unsigned long framesPerBuffer,  unsigned long numberOfBuffers,  PortAudioCallback *callback,  void *userData )

//return Pa_OpenStream( stream, ((numInputChannels > 0) ? Pa_GetDefaultInputDeviceID() : paNoDevice), numInputChannels, sampleFormat, NULL, ((numOutputChannels > 0) ? Pa_GetDefaultOutputDeviceID() : paNoDevice),  numOutputChannels, sampleFormat, NULL,  sampleRate, framesPerBuffer, numberOfBuffers, paNoFlag, callback, userData );


/*************************************************************************/
//PaError Pa_OpenStream(  PortAudioStream** streamPtrPtr,  PaDeviceID inputDeviceID, int numInputChannels,  PaSampleFormat inputSampleFormat,  void *inputDriverInfo,  PaDeviceID outputDeviceID,  int numOutputChannels, PaSampleFormat outputSampleFormat,  void *outputDriverInfo,   double sampleRate,  unsigned long framesPerBuffer,  unsigned long numberOfBuffers,  unsigned long streamFlags,  PortAudioCallback *callback, void *userData )








    else err = 0;
    if ( err != paNoError ) 
    {
        fprintf( stderr, "Error number %d occured opening portaudio stream\n", err); 
        fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
        Pa_Terminate();
        sys_inchannels = sys_outchannels = 0;
        return (1);
    }
 //   else if (sys_verbose)
//        post("... opened OK.");
    pa_inchans = inchans;
    pa_outchans = outchans;
    pa_soundin = soundin;
    pa_soundout = soundout;
    return (0);
}


void pa_close_audio( void)
{
    if (pa_inchans || pa_outchans)
        CloseAudioStream( pa_stream );
    pa_inchans = pa_outchans = 0;
}


// send output to portaudio
//=========================================================== 
// - pa_send_dacs:
//=========================================================== 
int pa_send_dacs(void)
{
	// NSLog(@"s_audio_pa.c: pa_send_dacs \n");

    float samples[MAX_SAMPLES_PER_FRAME], *fp1, *fp2;
    int i, j;
    double timebefore;
    
    timebefore = sys_getrealtime();
    if ((pa_inchans && GetAudioStreamReadable(pa_stream) < DEFDACBLKSIZE) || (pa_outchans && GetAudioStreamWriteable(pa_stream) < DEFDACBLKSIZE))
    {
        if (pa_inchans && pa_outchans)
        {
            int synced = 0;
            while (GetAudioStreamWriteable(pa_stream) > 2*DEFDACBLKSIZE)
            {
                for (j = 0; j < pa_outchans; j++)
                    for (i = 0, fp2 = samples + j; i < DEFDACBLKSIZE; i++, fp2 += pa_outchans)
                {
                    *fp2 = 0;
                }
                synced = 1;
                WriteAudioStream(pa_stream, samples, DEFDACBLKSIZE);
            }
            while (GetAudioStreamReadable(pa_stream) > 2*DEFDACBLKSIZE)
            {
                synced = 1;
                ReadAudioStream(pa_stream, samples, DEFDACBLKSIZE);
            }
            /* if (synced)
                post("sync"); */
        }
        return (SENDDACS_NO);
    }
    if (pa_inchans)
    {
        ReadAudioStream(pa_stream, samples, DEFDACBLKSIZE);
        for (j = 0, fp1 = pa_soundin; j < pa_inchans; j++, fp1 += DEFDACBLKSIZE)
            for (i = 0, fp2 = samples + j; i < DEFDACBLKSIZE; i++,  fp2 += pa_inchans)
        {
            fp1[i] = *fp2;
        }
    }
#if 0 
        {
                static int nread;
                if (nread == 0)
                {
                       NSLog(@"s_audio_pa.m:ERROR it's %f %f %f %f", pa_soundin[0], pa_soundin[1], pa_soundin[2],pa_soundin[3]);
                        nread = 1000;
                }
                nread--;
        }
#endif
	
	// write the output to portAudio
    if (pa_outchans)
    {
        for (j = 0, fp1 = pa_soundout; j < pa_outchans; j++, fp1 += DEFDACBLKSIZE)
		{
			for (i = 0, fp2 = samples + j; i < DEFDACBLKSIZE; i++,  fp2 += pa_outchans)
			{
				*fp2 = fp1[i];
				fp1[i] = 0;
			}
		}
		// NSLog(@"s_audio_pa.m:ERROR writing out");
        WriteAudioStream(pa_stream, samples, DEFDACBLKSIZE);	// outStream, dataToWrite, length
    }

    if (sys_getrealtime() > timebefore + 0.002)
    {
        /* post("slept"); */
        return (SENDDACS_SLEPT);
    }
    else return (SENDDACS_YES);
}


void pa_listdevs(void)     /* lifted from pa_devs.c in portaudio */
{
    int      i; //sh j;
    int      numDevices;
    const    PaDeviceInfo *pdi;
    PaError  err;
    Pa_Initialize();
    numDevices = Pa_GetDeviceCount();
    if( numDevices < 0 )
    {
        fprintf(stderr, "ERROR: Pa_GetDeviceCount returned %d\n", numDevices );
        err = numDevices;
        goto error;
    }
    fprintf(stderr, "Audio Devices:\n");
    for( i=0; i<numDevices; i++ )
    {
        pdi = Pa_GetDeviceInfo( i );
        fprintf(stderr, "device %d:", i+1 );
        fprintf(stderr, " %s;", pdi->name );
        fprintf(stderr, "%d inputs, ", pdi->maxInputChannels  );
        fprintf(stderr, "%d outputs", pdi->maxOutputChannels  );
//#ifdef PA19
//        if ( i == Pa_GetDefaultInputDevice() )
//            fprintf(stderr, " (Default Input)");
//        if ( i == Pa_GetDefaultOutputDevice() )
//            fprintf(stderr, " (Default Output)");
//#else
        if ( i == Pa_GetDefaultInputDeviceID() )
            fprintf(stderr, " (Default Input)");
        if ( i == Pa_GetDefaultOutputDeviceID() )
            fprintf(stderr, " (Default Output)");
//#endif
        fprintf(stderr, "\n");
    }

    fprintf(stderr, "\n");
    return;

error:
    fprintf( stderr, "An error occured while using the portaudio stream\n" ); 
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );

}

/* scanning for devices */
void pa_getdevs(char *indevlist, int *nindevs, char *outdevlist, int *noutdevs, int *canmulti, int maxndev, int devdescsize)
{
    int i, nin = 0, nout = 0, ndev;
    *canmulti = 1;  /* one dev each for input and output */

    Pa_Initialize();
    ndev = Pa_GetDeviceCount();
    for (i = 0; i < ndev; i++)
    {
        const PaDeviceInfo *pdi = Pa_GetDeviceInfo(i);
        if (pdi->maxInputChannels > 0 && nin < maxndev)
        {
            strcpy(indevlist + nin * devdescsize, pdi->name);
            nin++;
        }
        if (pdi->maxOutputChannels > 0 && nout < maxndev)
        {
            strcpy(outdevlist + nout * devdescsize, pdi->name);
            nout++;
        }
    }
    *nindevs = nin;
    *noutdevs = nout;
}
