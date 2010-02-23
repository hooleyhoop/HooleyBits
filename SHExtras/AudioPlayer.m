//
//  AudioPlayer.m
//  QuartzAudio
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "AudioPlayer.h"
#import <QTKit/QTKit.h>

@implementation BBAudioPlayer
	
+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 1;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return FALSE;
}

+ (int)timeMode
{
	return 1;	//Allow external time patch
}
	
- (id)initWithIdentifier:(id)fp8
{
	// Do your initialization of variables here
	
	NSLog(@"Init %@", fp8);
	
	if ((self = [super initWithIdentifier:fp8]) == nil)
	{
		[super release];
		return nil;	
	}
	
	return self;
}
	
- (void)dealloc
{
	NSLog(@"Deallocing audio");
	[movieSoundTrack stop];
	[movieSoundTrack release];	
	[super dealloc];
}
	
- (id)setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	
	NSLog(@"Setup");

	if (movieSoundTrack != nil)
	{
		[movieSoundTrack stop];
		[movieSoundTrack release];
		movieSoundTrack = nil;
	}
	
	alreadyPlaying = NO;
	timeHasBeenFixed = NO;
	paused = YES;
	
	return fp8;
}

-(void)createMovie
{
	NSError* error = nil;
	movieSoundTrack = [[QTMovie alloc] initWithFile:[inputAudioFile stringValue] error:&error];		//Needs to be on the main thread.
	if (error != nil)
	{
		NSLog([error localizedDescription]);
	}
}
	
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20			//Arguments appear to be NULL when played in QT.  Could be useful...
{
	// This is where the execution of your patch happens.
	// Everything in this method gets executed once
	// per 'clock cycle', which is available in fp12 (time).

	// fp8 is the QCOpenGLContext*.  Don't forget to set
	// it before you start drawing.  

	// Read/Write any ports in here too.
	
	
//	NSLog(@"Playing %@, time %f, arguments %@", fp8, compositionTime, fp20);
	
	
	if (!alreadyPlaying)		//Will happen on the first frame
	{
		[self performSelectorOnMainThread:@selector(createMovie) withObject:nil waitUntilDone:YES];
		alreadyPlaying = YES;
	}
	
	if (compositionTime <= 0.0)
		return YES;
	
	if (!timeHasBeenFixed)	//Will happen on the second frame
	{
		//Setting up the movie is relatively slow, and while we've been doing that, the movie will already have started.
		//Fix up the time on the second frame
		
		[movieSoundTrack setCurrentTime:QTMakeTimeWithTimeInterval(compositionTime)];
		[movieSoundTrack play];
		paused = NO;
		timeHasBeenFixed = YES;
	}
	else
	{
		if (paused)
		{
			[movieSoundTrack play];
			paused = NO;
		}
	
		QTTime audioQTTime = [movieSoundTrack currentTime];
		NSTimeInterval audioTime;
		if (!QTGetTimeInterval(audioQTTime, &audioTime))
			NSLog(@"How the hell can QTGetTimeInterval fail?");
			
		double timeDiff = compositionTime - audioTime;		//How far ahead the movie is from the audio
		
//		static BOOL normalRate = FALSE;
		
		if (fabs(timeDiff) > 0.15)	//We're more than 0.15 seconds out of sync.  Eeek.
		{
//			NSLog(@"Waaaay out of sync.");
//			[movieSoundTrack setCurrentTime:QTMakeTimeWithTimeInterval(compositionTime)];
//			normalRate = NO;
		}
//		else if (fabs(timeDiff) > 0.1)	//We're a little out of sync - speed up / slow down to fix this.
//		{
//			NSLog(@"We're a little %@", timeDiff>0 ? @"Slow" : @"Fast");
//			[movieSoundTrack setRate:(1 + timeDiff*0.1)];
//			normalRate = NO;
//		}
//		else if (fabs(timeDiff) < 0.03)
//		{
//			if (!normalRate)
//			{
//				[movieSoundTrack setRate:1];
//				normalRate = YES;
//			}
//		}
	}
	
	return TRUE;
}

-(void)cleanup:(id)fp8;
{
	[movieSoundTrack stop];
	paused = YES;
}

//- (id)state
//{
//	NSLog(@"State?");
//	return [super state];
//}
//
//- (BOOL)setState:(id)fp8
//{
//	NSLog(@"Set state %@??", [fp8 objectForKey:@"userInfo"]);
//	return [super setState:fp8];
//}


@end