//
//  AudioPlayer.h
//  QuartzAudio
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
// These are possible input/output types.  You don't need these if you
// don't have inputs/outputs, but it doesn't hurt to leave them.
//
// TODO: I need to post the headers to each of these so you can
// see the methods available.
	
@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QTMovie;
	
@interface BBAudioPlayer : QCPatch {
	QCStringPort *inputAudioFile;
	
	QTMovie* movieSoundTrack;
	double previousFrameTime;
	
	BOOL alreadyPlaying;
	BOOL timeHasBeenFixed;
	BOOL paused;
}
	
+ (int)executionMode;
+ (BOOL)allowsSubpatches;
- (id)initWithIdentifier:(id)fp8;
- (id)setup:(id)fp8;
- (BOOL)execute:(id)fp8 time:(double)fp12 arguments:(id)fp20;
	
@end