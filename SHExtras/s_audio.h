//
//  s_audio.h
//  
//
//  Created by Steve Hooley on 13/03/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef _S_AUDIO_H
#define _S_AUDIO_H

int sys_inchannels;
int sys_outchannels;

#define SENDDACS_NO 0           /* return values for sys_send_dacs() */
#define SENDDACS_YES 1 
#define SENDDACS_SLEPT 2

#define DEFDACBLKSIZE 64

#define SYS_DEFAULTCH 2
#define MAXAUDIOINDEV 4
#define MAXAUDIOOUTDEV 4
#define SYS_MAXCH 100
#define DEFAULTSRATE 44100
#define DEFAULTADVANCE 50
#define DEFAULTAUDIODEV 0

typedef long t_pa_sample;
#define SYS_SAMPLEWIDTH sizeof(t_pa_sample)
//sh #define SYS_BYTESPERCHAN (DEFDACBLKSIZE * SYS_SAMPLEWIDTH) 
//sh #define SYS_XFERSAMPS (SYS_DEFAULTCH*DEFDACBLKSIZE)
//sh #define SYS_XFERSIZE (SYS_SAMPLEWIDTH * SYS_XFERSAMPS)
#define MAXNDEV 20
#define DEVDESCSIZE 80

// This is where you put the noise!!
float *sys_soundout;
float *sys_soundin;


#endif

@interface s_audio : NSObject {


}

#pragma mark -
#pragma mark init methods

#pragma mark action methods

void sys_close_audio(void);

void sys_open_audio(int naudioindev, int *audioindev, int nchindev, int *chindev, int naudiooutdev, int *audiooutdev, int nchoutdev, int *choutdev, int rate, int advance, int enable);

static void audio_getdevs(char *indevlist, int *nindevs, char *outdevlist, int *noutdevs, int *canmulti, int maxndev, int devdescsize);

#pragma mark accessor methods

@end
