//
//  AudioSessionStuff.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 03/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "AudioSessionStuff.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@implementation AudioSessionStuff

- (void)setup {
	
	// implicitly initializes the audio session
	AVAudioSession *session = [AVAudioSession sharedInstance];
	BOOL bAudioInputAvailable= [session inputIsAvailable];
	
	NSError *err;
	BOOL success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
	NSAssert(success, @"failed to set up audio session");
	
	
	//	RequireNoErr( AudioSessionInitialize( NULL, NULL, rioInterruptionListener, self ) );
	success = [session setActive:YES error:&err];
	if(!success){
		// GetMacOSStatusErrorString(OSStatus err);
		//GetMacOSStatusCommentString(OSStatus err);
		[NSException raise:@"Could not start audio session" format:@"%@", err];
	}
	//	UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;
	//	RequireNoErr( AudioSessionSetProperty( kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory ));
	
	//	Float64 hwSampleRate;
	//	UInt32 size = sizeof(hwSampleRate);
	//	RequireNoErr( AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate) );
	
	
}

// find this in aurio touch and complete appropriately
void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");	
}


@end
