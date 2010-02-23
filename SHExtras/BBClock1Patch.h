//
//  BBClock1Patch.h
//  SHExtras
//
//  Created by Steven Hooley on 31/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;

/*
 *
*/
@interface BBClock1Patch : QCPatch {

    IBOutlet id clockFormat;
    IBOutlet id colorWell;
    IBOutlet id delayDisplay;
    IBOutlet id fontField;
    IBOutlet id motionSelect;
    IBOutlet id repositionClockCheckbox;
    IBOutlet id speedSlider;
    IBOutlet id warningMessage;
		
		NSColor *originalColor;
		PreferencesManager *prefManager;



	NSSize timestringSize;
	NSPoint timestringLocation;
	NSPoint startTimestringLocation;
	NSPoint nextTimestringLocation;

	// preference data
	PreferencesManager *prefManager;
	NSMutableDictionary *stringAttributes;
	BOOL repositionClock;
	NSString *clockFormat;
	int motionEffect;

	NSMutableString *clockString;
	NSMutableString *prevClockString;
	
	// animation data
	float frameRate;
	float repositionFrames;
	float repositionFrameCountdown;
	BOOL isMoving;
	int motionFrameNumber;
	
}

@end
