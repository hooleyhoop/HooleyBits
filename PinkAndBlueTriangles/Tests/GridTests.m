//
//  GridTests.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 02/08/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FloorGrid.h"
#import "GridCell.h"

#import <SenTestingKit/SenTestingKit.h>
@class FloorGrid;


@interface GridTests : SenTestCase {
	
	FloorGrid* _grid;
	
}

@end


@implementation GridTests

// ===========================================================
// - setUp
// ===========================================================
- (void)setUp
{
	_grid =  [[FloorGrid alloc] initWithSize:10 divisions:10];
	STAssertNotNil(_grid, @"GridTests ERROR.. Couldnt make a FloorGrid");
}

// ===========================================================
// - tearDown
// ===========================================================
- (void)tearDown
{
	[_grid release];
	_grid = nil;
}

- (void)testinitWithSize
{
	// - (id)initWithSize:(int)aValue divisions:(int)divs
	Class test = NSClassFromString(@"FloorGrid");
	if(test){
		NSLog(@"Yay");
		FloorGrid* newGrid =  [[FloorGrid alloc] initWithSize:10 divisions:10];
		unsigned cols = [newGrid columns];
		unsigned rows = [newGrid rows];
		unsigned cellSz = [newGrid cellSz];

		STAssertTrue(cols==10, [NSString stringWithFormat:@"GridTests ERROR.. %i", cols]);
		STAssertTrue(rows==10, [NSString stringWithFormat:@"GridTests ERROR.. %i", rows]);
		STAssertTrue(cellSz==1, [NSString stringWithFormat:@"GridTests ERROR.. %i", cellSz]);	
		
	} else {
		STAssertTrue(0, @"Cant find Class");
	}
}


- (void)testsetBoundsSize
{
	// - (void)setBoundsSize:(unsigned)value;
	[_grid setBoundsSize:20];
	unsigned cols = [_grid columns];
	unsigned rows = [_grid rows];
	STAssertTrue(cols==20, [NSString stringWithFormat:@"GridTests ERROR.. %i", cols]);
	STAssertTrue(rows==20, [NSString stringWithFormat:@"GridTests ERROR.. %i", rows]);
}

- (void)testsetCellSz
{
	// - (void)setCellSz:(unsigned)value;
	[_grid setCellSz:5];
	unsigned cols = [_grid columns];
	unsigned rows = [_grid rows];
	STAssertTrue(cols==2, [NSString stringWithFormat:@"GridTests ERROR.. %i", cols]);
	STAssertTrue(rows==2, [NSString stringWithFormat:@"GridTests ERROR.. %i", rows]);
}

- (void)testremakeGrid
{
	// - (void)remakeGrid;
	[_grid setBoundsSize:100];
	[_grid setCellSz:5];
	[_grid remakeGrid];
	NSArray *rowArray = [_grid rowArray];
	STAssertTrue([rowArray count]==20, [NSString stringWithFormat:@"GridTests ERROR.. %i", [rowArray count]]);
}
@end
