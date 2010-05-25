//
//  FloorGrid.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@class Engine, FloorGridStorage, PBCamera;

/*
 *
*/
@interface FloorGrid : NSObject {

	NSUInteger			_rows;
	NSUInteger			_columns;
	NSUInteger			_boundsSize;
	NSUInteger			_cellSz;
	
	FloorGridStorage *_cellStore;

	NSPoint _translation;
	NSPoint _anchorIndex;
	
	Engine* _engine;
	float _xVelocity, _yVelocity;
	
	double _startTime, _time;
	
	// GCSE revisions
	// p(t) = 16t^2
	// SPEED = (P(t2) - P(t1)) / (t2 - t1) 

}

- (id)initWithSize:(NSUInteger)aValue divisions:(NSUInteger)divs;

#pragma mark action methods
- (void)remakeGrid;

//- (void)drawAtPoint:(NSPoint)p;
//- (void)useWith:(PBCamera *)camera atTime:(double)time;


- (void)addRow_top;
- (void)addRow_bottom;
- (void)addColumn_left;
- (void)addColumn_right;

- (void)removeRow_top;
- (void)removeRow_bottom;
- (void)removeColumn_left;
- (void)removeColumn_right;

- (NSUInteger)rows;
//- (void)setRows:(unsigned)value;
//
- (NSUInteger)columns;
//- (void)setColumns:(unsigned)value;

- (NSUInteger)boundsSize;
- (void)setBoundsSize:(NSUInteger)value;

- (NSUInteger)cellSz;
- (void)setCellSz:(NSUInteger)value;
	
- (float)xVelocity;
- (void)setXVelocity:(float)value;
- (float)yVelocity;
- (void)setYVelocity:(float)value;

// - (NSArray *)rowArray;

@end
