//
//  PBView.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 11/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FloorGrid;

/*
 *
*/
@interface PBView : NSView {

	NSTimer* drawTimer;
	NSPoint mousePt;
	FloorGrid* floorGrid;
	NSTrackingRectTag trackingRect;

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

@end
