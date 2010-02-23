/* Copyright (c) 2003, Miller Puckette and others.
* For information on usage and redistribution, and for a DISCLAIMER OF ALL
* WARRANTIES, see the file, "LICENSE.txt," in this distribution.  */

/*  machine-independent (well, mostly!) audio layer.  Stores and recalls
    audio settings from argparse routine and from dialog window. 
*/

//#include "m_pd.h"
//#include "s_stuff.h"
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

//sh #define SYS_DEFAULTCH 2
//sh #define SYS_MAXCH 100
//sh typedef long t_pa_sample;
//sh #define SYS_SAMPLEWIDTH sizeof(t_pa_sample)
//sh #define SYS_BYTESPERCHAN (DEFDACBLKSIZE * SYS_SAMPLEWIDTH) 
//sh #define SYS_XFERSAMPS (SYS_DEFAULTCH*DEFDACBLKSIZE)
//sh #define SYS_XFERSIZE (SYS_SAMPLEWIDTH * SYS_XFERSAMPS)
//sh #define MAXNDEV 20
//sh #define DEVDESCSIZE 80

//sh static void audio_getdevs(char *indevlist, int *nindevs, char *outdevlist, int *noutdevs, int *canmulti, int maxndev, int devdescsize);

    /* these are set in this file when opening audio, but then may be reduced,
    even to zero, in the system dependent open_audio routines. */
//sh int sys_inchannels;
//sh int sys_outchannels;
//sh int sys_advance_samples;        /* scheduler advance in samples */
//sh int sys_blocksize = 0;          /* audio I/O block size in sample frames */
//sh int sys_audioapi = API_DEFAULT;

//sh static int sys_meters;          /* true if we're metering */
//sh static float sys_inmax;         /* max input amplitude */
//sh static float sys_outmax;        /* max output amplitude */

    /* exported variables */
int sys_schedadvance;   /* scheduler advance in microseconds */
//sh float sys_dacsr;

//sh t_sample *sys_soundout;
//sh t_sample *sys_soundin;

    /* the "state" is normally one if we're open and zero otherwise; 
    but if the state is one, we still haven't necessarily opened the
    audio hardware; see audio_isopen() below. */
//sh static int audio_state;

    /* last requested parameters */
//sh static int audio_naudioindev = -1;
//sh static int audio_audioindev[MAXAUDIOINDEV];
//sh static int audio_audiochindev[MAXAUDIOINDEV];
//sh static int audio_naudiooutdev = -1;
//sh static int audio_audiooutdev[MAXAUDIOOUTDEV];
//sh static int audio_audiochoutdev[MAXAUDIOOUTDEV];
//sh static int audio_rate;
//sh static int audio_advance;

//sh static int audio_isopen(void)
//sh {
//sh     return (audio_state && ((audio_naudioindev > 0 && audio_audiochindev[0] > 0) || (audio_naudiooutdev > 0 && audio_audiochoutdev[0] > 0)));
//sh }

//sh void sys_get_audio_params( int *pnaudioindev, int *paudioindev, int *chindev, int *pnaudiooutdev, int *paudiooutdev, int *choutdev, int *prate, int *padvance)
//sh {
//sh     int i;
 //sh    *pnaudioindev = audio_naudioindev;
//sh     for (i = 0; i < MAXAUDIOINDEV; i++)
//sh         paudioindev[i] = audio_audioindev[i],
//sh             chindev[i] = audio_audiochindev[i]; 
//sh     *pnaudiooutdev = audio_naudiooutdev;
//sh     for (i = 0; i < MAXAUDIOOUTDEV; i++)
//sh         paudiooutdev[i] = audio_audiooutdev[i],
//sh             choutdev[i] = audio_audiochoutdev[i]; 
//sh     *prate = audio_rate;
//sh     *padvance = audio_advance;
//sh }

//sh void sys_save_audio_params( int naudioindev, int *audioindev, int *chindev, int naudiooutdev, int *audiooutdev, int *choutdev, int rate, int advance)
//sh {
//sh     int i;
//sh     audio_naudioindev = naudioindev;
//sh     for (i = 0; i < MAXAUDIOINDEV; i++)
//sh         audio_audioindev[i] = audioindev[i],
//sh             audio_audiochindev[i] = chindev[i]; 
//sh     audio_naudiooutdev = naudiooutdev;
//sh     for (i = 0; i < MAXAUDIOOUTDEV; i++)
//sh         audio_audiooutdev[i] = audiooutdev[i],
//sh             audio_audiochoutdev[i] = choutdev[i]; 
//sh     audio_rate = rate;
//sh     audio_advance = advance;
//sh }

    /* init routines for any API which needs to set stuff up before
    any other API gets used.  This is only true of OSS so far. */
//sh #ifdef USEAPI_OSS
//sh void oss_init(void);
//sh #endif

//sh static void audio_init( void)
//sh {
//sh     static int initted = 0;
//sh     if (initted)
//sh         return;
//sh     initted = 1;
//sh } 


/* set channels and sample rate.  */
//sh void sys_setchsr(int chin, int chout, int sr)
//sh {
//sh     //sh int nblk;
//sh     int inbytes = (chin ? chin : 2) * (DEFDACBLKSIZE*sizeof(float));
//sh     int outbytes = (chout ? chout : 2) * (DEFDACBLKSIZE*sizeof(float));

//sh     sys_inchannels = chin;
//sh     sys_outchannels = chout;
//sh     sys_dacsr = sr;
 //sh    sys_advance_samples = (sys_schedadvance * sys_dacsr) / (1000000.);

 //sh    if (sys_advance_samples < 3 * DEFDACBLKSIZE)
 //sh        sys_advance_samples = 3 * DEFDACBLKSIZE;

 //sh    if (sys_soundin)
 //sh        free(sys_soundin);
 //sh    sys_soundin = (t_float *)malloc(inbytes);
 //sh    memset(sys_soundin, 0, inbytes);

//sh    if (sys_soundout)
//sh         free(sys_soundout);
//sh     sys_soundout = (t_float *)malloc(outbytes);
//sh     memset(sys_soundout, 0, outbytes);

//sh     if (sys_verbose)
 //sh        post("input channels = %d, output channels = %d", sys_inchannels, sys_outchannels);
 //sh    canvas_resume_dsp(canvas_suspend_dsp());
//sh }

/* ----------------------- public routines ----------------------- */

    /* open audio devices (after cleaning up the specified device and channel
    vectors).  The audio devices are "zero based" (i.e. "0" means the first
    one.)  We also save the cleaned-up device specification so that we
    can later re-open audio and/or show the settings on a dialog window. */

//sh void sys_open_audio(int naudioindev, int *audioindev, int nchindev, int *chindev, int naudiooutdev, int *audiooutdev, int nchoutdev, int *choutdev, int rate, int advance, int enable)
//sh {
//sh 	printf("s_audio.c: sys_open_audio %i, %i, %i, %i, %i, %i, %i, %i, %i, %i, %i \n", naudioindev, *audioindev, nchindev, *chindev, naudiooutdev, *audiooutdev, nchoutdev, *choutdev, rate, advance, enable);

 //sh    int i; //sh *ip;
//sh     int defaultchannels = SYS_DEFAULTCH;
//sh     int inchans, outchans;
//sh     int realinchans[MAXAUDIOINDEV], realoutchans[MAXAUDIOOUTDEV];

//sh     char indevlist[MAXNDEV*DEVDESCSIZE], outdevlist[MAXNDEV*DEVDESCSIZE];
//sh     int indevs = 0, outdevs = 0, canmulti = 0;
//sh     audio_getdevs(indevlist, &indevs, outdevlist, &outdevs, &canmulti,
//sh         MAXNDEV, DEVDESCSIZE);

//sh    if (sys_externalschedlib)
//sh    {
 //sh        return;
//sh    }
        /* if we're already open close it */
//sh     if (sys_inchannels || sys_outchannels)
//sh        sys_close_audio();

 //sh    if (rate < 1)
 //sh        rate = DEFAULTSRATE;
 //sh    if (advance <= 0)
 //sh        advance = DEFAULTADVANCE;
 //sh     audio_init();
        /* Since the channel vector might be longer than the
        audio device vector, or vice versa, we fill the shorter one
        in to match the longer one.  Also, if both are empty, we fill in
        one device (the default) and two channels. */ 
//sh     if (naudioindev == -1)
 //sh    {           /* no input audio devices specified */
//sh         if (nchindev == -1)
//sh        {
//sh             if (indevs >= 1)
//sh             {
//sh                 nchindev=1;
//sh                chindev[0] = defaultchannels;
//sh                 naudioindev = 1;
//sh                 audioindev[0] = DEFAULTAUDIODEV;
//sh             }
//sh            else naudioindev = nchindev = 0;
//sh        }
 //sh        else
 //sh        {
 //sh            for (i = 0; i < MAXAUDIOINDEV; i++)
 //sh                audioindev[i] = i;
//sh             naudioindev = nchindev;
//sh         }
//sh     }
//sh     else
//sh     {
 //sh        if (nchindev == -1)
 //sh        {
//sh             nchindev = naudioindev;
//sh             for (i = 0; i < naudioindev; i++)
 //sh                chindev[i] = defaultchannels;
//sh         }
 //sh        else if (nchindev > naudioindev)
  //sh       {
  //sh           for (i = naudioindev; i < nchindev; i++)
  //sh           {
 //sh                if (i == 0)
//sh                     audioindev[0] = DEFAULTAUDIODEV;
//sh                 else audioindev[i] = audioindev[i-1] + 1;
//sh             }
//sh             naudioindev = nchindev;
//sh         }
 //sh        else if (nchindev < naudioindev)
 //sh        {
 //sh            for (i = nchindev; i < naudioindev; i++)
 //sh            {
 //sh                if (i == 0)
 //sh                    chindev[0] = defaultchannels;
 //sh                else chindev[i] = chindev[i-1];
//sh             }
 //sh            naudioindev = nchindev;
//sh         }
//sh     }

//sh     if (naudiooutdev == -1)
//sh     {           /* not set */
//sh         if (nchoutdev == -1)
//sh         {
//sh             if (outdevs >= 1)
 //sh            {
 //sh                nchoutdev=1;
 //sh                choutdev[0]=defaultchannels;
//sh                 naudiooutdev=1;
//sh                 audiooutdev[0] = DEFAULTAUDIODEV;
 //sh            }
//sh             else nchoutdev = naudiooutdev = 0;
//sh         }
//sh         else
 //sh        {
 //sh            for (i = 0; i < MAXAUDIOOUTDEV; i++)
 //sh                audiooutdev[i] = i;
//sh            naudiooutdev = nchoutdev;
//sh        }
//sh    }
 //sh    else
 //sh    {
//sh         if (nchoutdev == -1)
//sh         {
 //sh            nchoutdev = naudiooutdev;
//sh             for (i = 0; i < naudiooutdev; i++)
//sh                choutdev[i] = defaultchannels;
//sh         }
//sh         else if (nchoutdev > naudiooutdev)
//sh        {
//sh            for (i = naudiooutdev; i < nchoutdev; i++)
 //sh            {
 //sh                if (i == 0)
 //sh                    audiooutdev[0] = DEFAULTAUDIODEV;
//sh                 else audiooutdev[i] = audiooutdev[i-1] + 1;
//sh             }
 //sh            naudiooutdev = nchoutdev;
 //sh        }
 //sh        else if (nchoutdev < naudiooutdev)
 //sh        {
 //sh           for (i = nchoutdev; i < naudiooutdev; i++)
 //sh            {
 //sh                if (i == 0)
//sh                     choutdev[0] = defaultchannels;
//sh                 else choutdev[i] = choutdev[i-1];
//sh             }
//sh             naudiooutdev = nchoutdev;
//sh         }
//sh     }
    
        /* count total number of input and output channels */
//sh     for (i = inchans = 0; i < naudioindev; i++)
//sh         inchans += (realinchans[i] = (chindev[i] > 0 ? chindev[i] : 0));
//sh     for (i = outchans = 0; i < naudiooutdev; i++)
//sh         outchans += (realoutchans[i] = (choutdev[i] > 0 ? choutdev[i] : 0));
        /* if no input or output devices seem to have been specified,
        this really means just disable audio, which we now do. */
 //sh    if (!inchans && !outchans)
 //sh        enable = 0;
 //sh    sys_schedadvance = advance * 1000;

//sh 	printf("s_audio.c: sys_schedadvance = %i \n", sys_schedadvance);

//sh     sys_setchsr(inchans, outchans, rate);
 //sh    sys_log_error(ERR_NOTHING);
//sh     if (enable)
//sh     {

        //if (sys_audioapi == API_PORTAUDIO)
        //{
//sh             int blksize = (sys_blocksize ? sys_blocksize : 64);
 //sh            pa_open_audio(inchans, outchans, rate, sys_soundin, sys_soundout, blksize, sys_advance_samples/blksize, (naudiooutdev > 0 ? audioindev[0] : 0), (naudiooutdev > 0 ? audiooutdev[0] : 0));
        // } else
		//	post("unknown audio API specified");
 //sh    }
//sh    sys_save_audio_params(naudioindev, audioindev, chindev, naudiooutdev, audiooutdev, choutdev, sys_dacsr, advance);
//sh     if (sys_inchannels == 0 && sys_outchannels == 0)
//sh        enable = 0;
//sh     audio_state = enable;
 //sh    sys_vgui("set pd_whichapi %d\n",  (audio_isopen() ? sys_audioapi : 0));
//sh     sched_set_using_dacs(enable);
//sh }

//sh void sys_close_audio(void)
//sh {
//sh     if (sys_externalschedlib)
//sh     {
//sh         return;
//sh     }
//sh     if (!audio_isopen())
//sh         return;

    //if (sys_audioapi == API_PORTAUDIO)
//sh         pa_close_audio();
 //  else 
  //      post("sys_close_audio: unknown API %d", sys_audioapi);
//sh     sys_inchannels = sys_outchannels = 0;
//sh }

    /* open audio using whatever parameters were last used */
//sh void sys_reopen_audio( void)
//sh {
//sh     int naudioindev, audioindev[MAXAUDIOINDEV], chindev[MAXAUDIOINDEV];
//sh     int naudiooutdev, audiooutdev[MAXAUDIOOUTDEV], choutdev[MAXAUDIOOUTDEV];
//sh     int rate, advance;
//sh     sys_get_audio_params(&naudioindev, audioindev, chindev,
//sh         &naudiooutdev, audiooutdev, choutdev, &rate, &advance);
 //sh    sys_open_audio(naudioindev, audioindev, naudioindev, chindev,
 //sh        naudiooutdev, audiooutdev, naudiooutdev, choutdev, rate, advance, 1);
//sh }


//=========================================================== 
// - sys_send_dacs:
//=========================================================== 
//sh int sys_send_dacs(void)
//sh {
//	printf("s_audio.c: sys_send_dacs \n");
//sh     if (sys_meters)
//sh     {
//sh         int i, n;
//sh         float maxsamp;
 //sh        for (i = 0, n = sys_inchannels * DEFDACBLKSIZE, maxsamp = sys_inmax;
//sh             i < n; i++)
//sh         {
 //sh            float f = sys_soundin[i];
//sh             if (f > maxsamp) maxsamp = f;
//sh             else if (-f > maxsamp) maxsamp = -f;
//sh         }
//sh         sys_inmax = maxsamp;
 //sh        for (i = 0, n = sys_outchannels * DEFDACBLKSIZE, maxsamp = sys_outmax;
 //sh            i < n; i++)
 //sh        {
//sh             float f = sys_soundout[i];
 //sh            if (f > maxsamp) maxsamp = f;
 //sh            else if (-f > maxsamp) maxsamp = -f;
 //sh        }
 //sh        sys_outmax = maxsamp;
//sh     }
//sh 	return (pa_send_dacs());
//sh }


//sh float sys_getsr(void){
//sh      return (sys_dacsr);
//sh }

//sh int sys_get_outchannels(void){
//sh      return (sys_outchannels); 
//sh }

//sh int sys_get_inchannels(void) {
//sh      return (sys_inchannels);
//sh }

//sh void sys_getmeters(float *inmax, float *outmax)
//sh {
//sh     if (inmax)
//sh     {
//sh         sys_meters = 1;
//sh         *inmax = sys_inmax;
//sh         *outmax = sys_outmax;
//sh     }
//sh     else
//sh         sys_meters = 0;
//sh     sys_inmax = sys_outmax = 0;
//sh }

//sh void sys_reportidle(void)
//sh {
//sh }


//sh static void audio_getdevs(char *indevlist, int *nindevs, char *outdevlist, int *noutdevs, int *canmulti, int maxndev, int devdescsize)
//sh {
//sh     audio_init();
//sh #ifdef USEAPI_PORTAUDIO
//sh 	printf("s_audio.c: USEAPI_PORTAUDIO \n");

//sh     if (sys_audioapi == API_PORTAUDIO)
//sh     {
//sh         pa_getdevs(indevlist, nindevs, outdevlist, noutdevs, canmulti,
//sh             maxndev, devdescsize);
 //sh    }
 //sh    else
//sh #endif


//sh     {
//sh             /* this shouldn't happen once all the above get filled in. */
//sh         int i;
//sh         *nindevs = *noutdevs = 3;
//sh         for (i = 0; i < 3; i++)
//sh         {
//sh             sprintf(indevlist + i * devdescsize, "input device #%d", i+1);
//sh             sprintf(outdevlist + i * devdescsize, "output device #%d", i+1);
//sh         }
//sh         *canmulti = 0;
//sh     }
//sh }


//sh #define DEVONSET 1  /* To agree with command line flags, normally start at 1 */

//sh static void sys_listaudiodevs(void )
//sh {
 //sh    char indevlist[MAXNDEV*DEVDESCSIZE], outdevlist[MAXNDEV*DEVDESCSIZE];
 //sh    int nindevs = 0, noutdevs = 0, i, canmulti = 0;

//sh     audio_getdevs(indevlist, &nindevs, outdevlist, &noutdevs, &canmulti,
//sh         MAXNDEV, DEVDESCSIZE);

 //sh    if (!nindevs)
//sh         post("no audio input devices found");
//sh     else
//sh     {
//sh         post("input devices:");
//sh         for (i = 0; i < nindevs; i++)
 //sh            post("%d. %s", i+1, indevlist + i * DEVDESCSIZE);
//sh     }
//sh     if (!noutdevs)
//sh         post("no audio output devices found");
//sh     else
//sh     {
 //sh        post("output devices:");
//sh        for (i = 0; i < noutdevs; i++)
//sh             post("%d. %s", i + DEVONSET, outdevlist + i * DEVDESCSIZE);
//sh     }
//sh     post("API number %d\n", sys_audioapi);
//sh }


/* start an audio settings dialog window */
//sh void glob_audio_properties(t_pd *dummy, t_floatarg flongform)
//sh {
//sh     char buf[1024 + 2 * MAXNDEV*(DEVDESCSIZE+4)];
        /* these are the devices you're using: */
//sh     int naudioindev, audioindev[MAXAUDIOINDEV], chindev[MAXAUDIOINDEV];
//sh     int naudiooutdev, audiooutdev[MAXAUDIOOUTDEV], choutdev[MAXAUDIOOUTDEV];
 //sh    int audioindev1, audioindev2, audioindev3, audioindev4,
//sh         audioinchan1, audioinchan2, audioinchan3, audioinchan4,
 //sh        audiooutdev1, audiooutdev2, audiooutdev3, audiooutdev4,
//sh         audiooutchan1, audiooutchan2, audiooutchan3, audiooutchan4;
//sh     int rate, advance;
        /* these are all the devices on your system: */
//sh     char indevlist[MAXNDEV*DEVDESCSIZE], outdevlist[MAXNDEV*DEVDESCSIZE];
 //sh    int nindevs = 0, noutdevs = 0, canmulti = 0, i;

 //sh    char indevliststring[MAXNDEV*(DEVDESCSIZE+4)+80],
//sh         outdevliststring[MAXNDEV*(DEVDESCSIZE+4)+80];
//sh 
 //sh    audio_getdevs(indevlist, &nindevs, outdevlist, &noutdevs, &canmulti,
 //sh        MAXNDEV, DEVDESCSIZE);

//sh     strcpy(indevliststring, "{");
//sh     for (i = 0; i < nindevs; i++)
 //sh    {
 //sh        strcat(indevliststring, "\"");
//sh        strcat(indevliststring, indevlist + i * DEVDESCSIZE);
//sh         strcat(indevliststring, "\" ");
//sh     }
//sh     strcat(indevliststring, "}");

//sh     strcpy(outdevliststring, "{");
//sh     for (i = 0; i < noutdevs; i++)
//sh     {
//sh         strcat(outdevliststring, "\"");
//sh         strcat(outdevliststring, outdevlist + i * DEVDESCSIZE);
//sh         strcat(outdevliststring, "\" ");
//sh     }
 //sh    strcat(outdevliststring, "}");

//sh     sys_get_audio_params(&naudioindev, audioindev, chindev,
 //sh        &naudiooutdev, audiooutdev, choutdev, &rate, &advance);

 //sh    /* post("naudioindev %d naudiooutdev %d longform %f",
//sh             naudioindev, naudiooutdev, flongform); */
//sh     if (naudioindev > 1 || naudiooutdev > 1)
//sh         flongform = 1;


//sh    audioindev1 = (naudioindev > 0 &&  audioindev[0]>= 0 ? audioindev[0] : 0);
//sh     audioindev2 = (naudioindev > 1 &&  audioindev[1]>= 0 ? audioindev[1] : 0);
//sh     audioindev3 = (naudioindev > 2 &&  audioindev[2]>= 0 ? audioindev[2] : 0);
 //sh    audioindev4 = (naudioindev > 3 &&  audioindev[3]>= 0 ? audioindev[3] : 0);
//sh     audioinchan1 = (naudioindev > 0 ? chindev[0] : 0);
//sh     audioinchan2 = (naudioindev > 1 ? chindev[1] : 0);
//sh     audioinchan3 = (naudioindev > 2 ? chindev[2] : 0);
//sh     audioinchan4 = (naudioindev > 3 ? chindev[3] : 0);
//sh     audiooutdev1 = (naudiooutdev > 0 && audiooutdev[0]>=0 ? audiooutdev[0] : 0);  
 //sh    audiooutdev2 = (naudiooutdev > 1 && audiooutdev[1]>=0 ? audiooutdev[1] : 0);  
//sh     audiooutdev3 = (naudiooutdev > 2 && audiooutdev[2]>=0 ? audiooutdev[2] : 0);  
//sh     audiooutdev4 = (naudiooutdev > 3 && audiooutdev[3]>=0 ? audiooutdev[3] : 0);  
//sh     audiooutchan1 = (naudiooutdev > 0 ? choutdev[0] : 0);
//sh     audiooutchan2 = (naudiooutdev > 1 ? choutdev[1] : 0);
 //sh    audiooutchan3 = (naudiooutdev > 2 ? choutdev[2] : 0);
 //sh    audiooutchan4 = (naudiooutdev > 3 ? choutdev[3] : 0);
 //sh    sprintf(buf,
//sh "pdtk_audio_dialog %%s \
//sh %s %d %d %d %d %d %d %d %d \
//sh %s %d %d %d %d %d %d %d %d \
//sh %d %d %d %d\n",
//sh         indevliststring,
//sh         audioindev1, audioindev2, audioindev3, audioindev4, 
//sh         audioinchan1, audioinchan2, audioinchan3, audioinchan4, 
//sh         outdevliststring,
//sh         audiooutdev1, audiooutdev2, audiooutdev3, audiooutdev4,
//sh         audiooutchan1, audiooutchan2, audiooutchan3, audiooutchan4, 
//sh        rate, advance, canmulti, (flongform != 0));
//sh     gfxstub_deleteforkey(0);
//sh     gfxstub_new(&glob_pdobject, (void *)glob_audio_properties, buf);
//sh }

    /* new values from dialog window */
//sh void glob_audio_dialog(t_pd *dummy, t_symbol *s, int argc, t_atom *argv)
//sh {
    //sh int naudioindev, audioindev[MAXAUDIOINDEV], chindev[MAXAUDIOINDEV];
    //sh int naudiooutdev, audiooutdev[MAXAUDIOOUTDEV], choutdev[MAXAUDIOOUTDEV];
//sh     int i, nindev, noutdev; //sh rate, advance, audioon,
    //sh int audioindev1, audioinchan1, audiooutdev1, audiooutchan1;
//sh     int newaudioindev[4], newaudioinchan[4],
//sh         newaudiooutdev[4], newaudiooutchan[4];
        /* the new values the dialog came back with: */
//sh     int newrate = atom_getintarg(16, argc, argv);
//sh     int newadvance = atom_getintarg(17, argc, argv);
    //sh int statewas;

//sh    for (i = 0; i < 4; i++)
//sh     {
//sh         newaudioindev[i] = atom_getintarg(i, argc, argv);
//sh         newaudioinchan[i] = atom_getintarg(i+4, argc, argv);
//sh         newaudiooutdev[i] = atom_getintarg(i+8, argc, argv);
//sh         newaudiooutchan[i] = atom_getintarg(i+12, argc, argv);
//sh     }

//sh    for (i = 0, nindev = 0; i < 4; i++)
//sh     {
//sh         if (newaudioinchan[i])
//sh         {
//sh             newaudioindev[nindev] = newaudioindev[i];
//sh             newaudioinchan[nindev] = newaudioinchan[i];
            /* post("in %d %d %d", nindev,
                newaudioindev[nindev] , newaudioinchan[nindev]); */
//sh             nindev++;
//sh         }
//sh     }
//sh     for (i = 0, noutdev = 0; i < 4; i++)
//sh     {
//sh         if (newaudiooutchan[i])
//sh         {
//sh             newaudiooutdev[noutdev] = newaudiooutdev[i];
 //sh            newaudiooutchan[noutdev] = newaudiooutchan[i];
            /* post("out %d %d %d", noutdev,
                newaudiooutdev[noutdev] , newaudioinchan[noutdev]); */
//sh             noutdev++;
//sh         }
//sh     }

//sh     sys_close_audio();
//sh     sys_open_audio(nindev, newaudioindev, nindev, newaudioinchan,
//sh         noutdev, newaudiooutdev, noutdev, newaudiooutchan,
//sh         newrate, newadvance, 1);
//sh }

//sh void sys_listdevs(void )
//sh {
//sh #ifdef USEAPI_PORTAUDIO
 //sh    if (sys_audioapi == API_PORTAUDIO)
//sh         sys_listaudiodevs();
//sh     else 
//sh #endif


//sh     post("unknown API");    

//sh     sys_listmididevs();
//sh }

//sh void sys_setblocksize(int n)
//sh {
//sh     if (n < 1)
//sh         n = 1;
//sh     if (n != (1 << ilog2(n)))
//sh         post("warning: adjusting blocksize to power of 2: %d", 
//sh             (n = (1 << ilog2(n))));
//sh     sys_blocksize = n;
//sh }

//sh void sys_set_audio_api(int which)
//sh {
//sh      sys_audioapi = which;
//sh      if (sys_verbose)
//sh         post("sys_audioapi %d", sys_audioapi);
//sh }

//sh void glob_audio_setapi(void *dummy, t_floatarg f)
//sh {
//sh     int newapi = f;
//sh     if (newapi)
//sh     {
//sh         if (newapi == sys_audioapi)
//sh         {
 //sh            if (!audio_isopen())
 //sh                sys_reopen_audio();
 //sh        }
//sh        else
//sh         {
//sh             sys_close_audio();
 //sh            sys_audioapi = newapi;
 //sh                /* bash device params back to default */
//sh            audio_naudioindev = audio_naudiooutdev = 1;
//sh             audio_audioindev[0] = audio_audiooutdev[0] = DEFAULTAUDIODEV;
//sh             audio_audiochindev[0] = audio_audiochoutdev[0] = SYS_DEFAULTCH;
//sh            sys_reopen_audio();
//sh         }
//sh         glob_audio_properties(0, 0);
//sh     }
//sh     else if (audio_isopen())
 //sh    {
 //sh        sys_close_audio();
//sh         audio_state = 0;
//sh         sched_set_using_dacs(0);
//sh     }
//sh }

    /* start or stop the audio hardware */
//sh void sys_set_audio_state(int onoff)
//sh {
//sh     if (onoff)  /* start */
//sh     {
//sh         if (!audio_isopen())
//sh             sys_reopen_audio();    
//sh     }
//sh     else
//sh     {
//sh        if (audio_isopen())
//sh         {
 //sh            sys_close_audio();
 //sh            sched_set_using_dacs(0);
 //sh        }
 //sh    }
//sh    audio_state = onoff;
//sh }

//sh void sys_get_audio_apis(char *buf)
//sh {
//sh     int n = 0;
//sh     strcpy(buf, "{ ");

//sh 			printf("s_audio.c: USEAPI_PORTAUDIO \n");
//sh 			sprintf(buf + strlen(buf), "{\"standard (portaudio)\" %d} ", API_PORTAUDIO);


  //sh    n++;


//sh     strcat(buf, "}");
        /* then again, if only one API (or none) we don't offer any choice. */
//sh    if (n < 2)
 //sh        strcpy(buf, "{}");
    
//sh }



/* debugging */
//sh void glob_foo(void *dummy, t_symbol *s, int argc, t_atom *argv)
//sh {
//sh     t_symbol *arg = atom_getsymbolarg(0, argc, argv);
//sh     if (arg == gensym("restart"))
//sh         sys_reopen_audio();
//sh }
