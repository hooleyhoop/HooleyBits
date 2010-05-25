//
//  FloorGridStorageTests.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 25/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FloorGridStorage.h"

@interface FloorGridStorageTests : SenTestCase {
	
	FloorGridStorage *_cellStore;
}

@end


@implementation FloorGridStorageTests

- (void)setUp {

	_cellStore = [[FloorGridStorage alloc] initWithRows:10 columns:20];
}

- (void)tearDown {
	
	[_cellStore release];
}

- (void)testInitWithRowsColumns {
	// - (id)initWithRows:(NSUInteger)y columns:(NSUInteger)x
	
	_cellStore = [[FloorGridStorage alloc] initWithRows:10 columns:20];
	STAssertTrue( _cellStore.rows==10, nil );
	STAssertTrue( _cellStore.columns==20, @"%i", _cellStore.columns );
}


- (void)testResize {
	// - (void)resize:(NSUInteger)rows :(NSUInteger)columns
	
	[_cellStore resize:0 :0];
	STAssertTrue( _cellStore.rows==0, nil );
	STAssertTrue( _cellStore.columns==0, nil );
}
	
- (void)testAddRow_top {
	// - (void)addRow_top
	
	[_cellStore addRow_top];
	STAssertTrue( _cellStore.rows==11, nil );
	STAssertTrue( _cellStore.columns==20, @"%i", _cellStore.columns );
}
	

- (void)testAddRow_bottom {
	// - (void)addRow_bottom
	
	[_cellStore addRow_bottom];
	STAssertTrue( _cellStore.rows==11, nil );
	STAssertTrue( _cellStore.columns==20, @"%i", _cellStore.columns );
}

- (void)testAddColumn_left {
	// - (void)addColumn_left
	
	[_cellStore addColumn_left];
	STAssertTrue( _cellStore.rows==10, nil );
	STAssertTrue( _cellStore.columns==21, @"%i", _cellStore.columns );
}

- (void)testAddColumn_right {
	// - (void)addColumn_right
	
	[_cellStore addColumn_right];
	STAssertTrue( _cellStore.rows==10, nil );
	STAssertTrue( _cellStore.columns==21, @"%i", _cellStore.columns );
}

- (void)testRemoveRow_top {
	// - (BOOL)removeRow_top
	
	[_cellStore removeRow_top];
	STAssertTrue( _cellStore.rows==9, nil );
	STAssertTrue( _cellStore.columns==20, @"%i", _cellStore.columns );
}

- (void)testRemoveRow_bottom {
	// - (BOOL)removeRow_bottom
	
	[_cellStore removeRow_bottom];
	STAssertTrue( _cellStore.rows==9, nil );
	STAssertTrue( _cellStore.columns==20, @"%i", _cellStore.columns );
}
	
- (void)testRemoveColumn_left {
	// - (BOOL)removeColumn_left
	
	[_cellStore removeColumn_left];
	STAssertTrue( _cellStore.rows==10, nil );
	STAssertTrue( _cellStore.columns==19, @"%i", _cellStore.columns );
}

- (void)testRemoveColumn_right {
	// - (BOOL)removeColumn_right
	
	[_cellStore removeColumn_right];
	STAssertTrue( _cellStore.rows==10, nil );
	STAssertTrue( _cellStore.columns==19, @"%i", _cellStore.columns );
}

@end
