//
//  PB3DView.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 13/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@class FloorGrid, PBCamera;

@interface PB3DView : NSView {

	NSTimer				*drawTimer;
	NSPoint				mousePt;
	FloorGrid				*floorGrid;
	NSTrackingRectTag		trackingRect;

    PBCamera				*camera;

	NSOpenGLContext		*context;
	NSOpenGLPixelFormat	*pixelFormat;
	
	double					currentTime, startTime;
}

#pragma mark action methods
- (IBAction)stop:(id)sender;
- (IBAction)start:(id)sender;

- (void)update;
- (void)reshape;
- (void)setTracking;

#pragma mark accessor methods
- (FloorGrid *)floorGrid;
- (void)setFloorGrid:(FloorGrid *)value;

- (PBCamera	*)camera;

- (double)currentTime;
- (void)inceraseCurrentTime:(double)value;

@end
