//
//  FloorGrid.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Engine, PBCamera;

/*
 *
*/
@interface FloorGrid : NSObject {

	unsigned _rows;
	unsigned _columns;
	unsigned _boundsSize;
	unsigned _cellSz;
	
	NSMutableArray* _rowArray;

	NSPoint _translation;
	NSPoint _anchorIndex;
	
	Engine* _engine;
	float _xVelocity, _yVelocity;
	
	double _startTime, _time;
	
	// GCSE revisions
	// p(t) = 16t^2
	// SPEED = (P(t2) - P(t1)) / (t2 - t1) 

}

- (id)initWithSize:(int)aValue divisions:(int)divs;

#pragma mark action methods
- (void)remakeGrid;
- (void)moveForwardAtTime:(double)time;

- (void)drawAtPoint:(NSPoint)p;
- (void)useWith:(PBCamera *)camera atTime:(double)time;


- (void)addRow_top;
- (void)addRow_bottom;
- (void)addColumn_left;
- (void)addColumn_right;

- (void)removeRow_top;
- (void)removeRow_bottom;
- (void)removeColumn_left;
- (void)removeColumn_right;

- (unsigned)rows;
- (void)setRows:(unsigned)value;
- (unsigned)columns;
- (void)setColumns:(unsigned)value;
- (unsigned)boundsSize;
- (void)setBoundsSize:(unsigned)value;
- (unsigned)cellSz;
- (void)setCellSz:(unsigned)value;
	
- (float)xVelocity;
- (void)setXVelocity:(float)value;
- (float)yVelocity;
- (void)setYVelocity:(float)value;

- (NSArray *)rowArray;

@end
