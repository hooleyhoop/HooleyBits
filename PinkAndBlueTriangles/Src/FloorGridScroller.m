//
//  FloorGridScroller.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 25/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FloorGridScroller.h"


@implementation FloorGridScroller

copyWithZone

- (void)moveForwardAtTime:(double)time {
	
	//	NSLog(@"Moving forward at time %f", (float)time);
	// have an angle and forward velocity
	
	// move in that dirction, check bounds etc
	
	// then rotate so facing forwards
	
	// then draw
	
	_translation.y = _translation.y - (time*8.0); // + equals up
	//	_translation.x = _translation.x - (time*8.0);
	
	// test grid edges against bounds - shrink or grow appropriately
	float width = _columns*_cellSz;
	float height = _rows*_cellSz;
	NSPoint distToAnchorFromTopLeft = NSMakePoint(_anchorIndex.x*_cellSz, _anchorIndex.y*_cellSz);
	NSPoint topLeftPoint = NSMakePoint(_translation.x-distToAnchorFromTopLeft.x, _translation.y-distToAnchorFromTopLeft.y);
	
	/* (0, 0) is Center of screen */
	NSRect clipBounds = NSMakeRect( -(_boundsSize/2.0), -(_boundsSize/2.0), _boundsSize, _boundsSize ); // clipping is fixed around the origin
	NSRect gridBounds = NSMakeRect( topLeftPoint.x, topLeftPoint.y, width, height);
	BOOL didChangeBounds = [self testEdges:gridBounds againstClip:clipBounds cellSize:_cellSz];
	didChangeBounds;
}

@end
