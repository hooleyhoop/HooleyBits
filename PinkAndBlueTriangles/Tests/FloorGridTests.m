//
//  FloorGridTests.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 02/08/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FloorGrid.h"
#import "GridCell.h"


@interface FloorGridTests : SenTestCase {
	
	FloorGrid *_grid;
}

@end


@implementation FloorGridTests

- (void)setUp {

	_grid = [[FloorGrid alloc] initWithSize:10 divisions:10];
}

- (void)tearDown {

	[_grid release];
}

- (void)testinitWithSize {
	// - (id)initWithSize:(int)aValue divisions:(int)divs
	
	FloorGrid *newGrid =  [[FloorGrid alloc] initWithSize:10 divisions:10];
	NSUInteger cols = [newGrid columns];
	NSUInteger rows = [newGrid rows];
	NSUInteger cellSz = [newGrid cellSz];

	STAssertTrue( cols==10, @"GridTests ERROR.. %i", cols );
	STAssertTrue( rows==10, @"GridTests ERROR.. %i", rows );
	STAssertTrue( cellSz==1, @"GridTests ERROR.. %i", cellSz );	
}

- (void)testSetBoundsSize {
	// - (void)setBoundsSize:(unsigned)value
	
	[_grid setBoundsSize:20];
	NSUInteger cols = [_grid columns];
	NSUInteger rows = [_grid rows];
	STAssertTrue( cols==20, [NSString stringWithFormat:@"GridTests ERROR.. %i", cols] );
	STAssertTrue( rows==20, [NSString stringWithFormat:@"GridTests ERROR.. %i", rows] );
}

- (void)testSetCellSz {
	// - (void)setCellSz:(unsigned)value
	
	[_grid setCellSz:5];
	NSUInteger cols = [_grid columns];
	NSUInteger rows = [_grid rows];
	STAssertTrue(cols==2, [NSString stringWithFormat:@"GridTests ERROR.. %i", cols]);
	STAssertTrue(rows==2, [NSString stringWithFormat:@"GridTests ERROR.. %i", rows]);
}

- (void)testRemakeGrid {
	// - (void)remakeGrid
	
	[_grid setBoundsSize:100];
	[_grid setCellSz:5];
	[_grid remakeGrid];
	NSArray *rowArray = [_grid rowArray];
	STAssertTrue( [rowArray count]==20, @"GridTests ERROR.. %i", [rowArray count] );
}

@end
