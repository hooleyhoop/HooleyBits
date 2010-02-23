
#import <Cocoa/Cocoa.h>

#ifndef _S_AUDIO_PA_H
#define _S_AUDIO_PA_H

int pa_open_audio(int inchans, int outchans, int rate, float *soundin, float *soundout, int framesperbuf, int nbuffers, int indeviceno, int outdeviceno);

int pa_send_dacs(void);

void pa_listdevs(void);

void pa_getdevs(char *indevlist, int *nindevs, char *outdevlist, int *noutdevs, int *canmulti, int maxndev, int devdescsize);


#endif
