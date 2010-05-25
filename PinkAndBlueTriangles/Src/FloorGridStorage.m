//
//  FloorGridStorage.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 25/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FloorGridStorage.h"
#import "GridCell.h"

@implementation FloorGridStorage

@synthesize rowArray=_rowArray;
//@synthesize rows=_rows, columns=_columns;

/* 2d array form top to bottom, left-to-right */
- (id)initWithRows:(NSUInteger)y columns:(NSUInteger)x {

	self = [super init];
	if(self){
		_rowArray = [[NSMutableArray alloc] initWithCapacity:y];
		[self resize:y :x];
	}
	return self;
}

- (void)dealloc {
	
	[_rowArray release];
	[super dealloc];
}

#pragma mark -
- (void)resize:(NSUInteger)rows :(NSUInteger)columns {
	
	NSUInteger currentRows = self.rows;
	NSUInteger currentCols = self.columns;
	
	// add new rows
	if(currentRows<rows) {
		while(currentRows<rows){
			NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:columns];
			[_rowArray addObject:columnArray];
			currentRows++;
		}

	} else if(currentRows>rows){
		// delete rows
		while(currentRows>rows){
			[_rowArray removeLastObject];
			currentRows--;
		}
	}
	if(currentCols<columns){
		// add new _columns
		for( NSUInteger i=0; i<rows; i++){
			NSMutableArray *columnArray = [_rowArray objectAtIndex:i];
			NSUInteger colCount = [columnArray count];
			while(colCount<columns){
				GridCell* cell = [[[GridCell alloc] init] autorelease];
				[columnArray addObject:cell];
				colCount++;
			}
		}
	} else if(currentCols>columns) {
		// delete _columns
		for( NSUInteger i=0; i<rows; i++){
			NSMutableArray *columnArray = [_rowArray objectAtIndex:i];
			NSUInteger colCount = [columnArray count];
			while(colCount>columns){
				[columnArray removeLastObject];
				colCount--;
			}
		}		
	}
}
#pragma mark -
- (void)addRow_top {
	
	NSUInteger colCount = self.columns;
	NSMutableArray* newRow = [NSMutableArray arrayWithCapacity:colCount];
	for( NSUInteger j=0; j<colCount; j++ ){
		GridCell *cell = [[[GridCell alloc] init] autorelease];
		[newRow addObject:cell];
	}
	[_rowArray insertObject:newRow atIndex:0];
}

- (void)addRow_bottom {
	
	NSUInteger colCount = self.columns;
	NSMutableArray *newRow = [NSMutableArray arrayWithCapacity:colCount];
	for( NSUInteger j=0; j<colCount; j++ ) {
		GridCell *cell = [[[GridCell alloc] init] autorelease];
		[newRow addObject:cell];
	}
	[_rowArray addObject:newRow];
}

- (void)addColumn_left {
	
	NSUInteger rowCount = self.rows;
	for( NSUInteger i=0; i<rowCount; i++ ) {
		NSMutableArray *thisRow = [_rowArray objectAtIndex:i];
		GridCell *cell = [[[GridCell alloc] init] autorelease];
		[thisRow insertObject:cell atIndex:0];
	}
}

- (void)addColumn_right {
	
	NSUInteger rowCount = self.rows;
	for( NSUInteger i=0; i<rowCount; i++ ) {
		NSMutableArray *thisRow = [_rowArray objectAtIndex:i];
		GridCell *cell = [[[GridCell alloc] init] autorelease];
		[thisRow addObject:cell];
	}
}

- (BOOL)removeRow_top {
	
	NSUInteger rowCount = self.rows;
	if(rowCount>1){
		[_rowArray removeObjectAtIndex:0]; // remember - 0,0 is top left of screen
		return YES;
	}
	return NO;
}

- (BOOL)removeRow_bottom {
	
	NSUInteger rowCount = self.rows;
	if(rowCount>1){
		[_rowArray removeLastObject]; // remember - 0,0 is top left of screen
		return YES;
	}
	return NO;
}

- (BOOL)removeColumn_left {
	
	NSUInteger rowCount = self.rows;
	NSUInteger colCount = self.columns;
	if(colCount>1){
		for( NSUInteger i=0; i<rowCount; i++ ){
			NSMutableArray *thisRow = [_rowArray objectAtIndex: i];
			[thisRow removeObjectAtIndex:0];
		}
		return YES;
	}
	return NO;
}

- (BOOL)removeColumn_right {
	
	NSUInteger rowCount = self.rows;
	NSUInteger colCount = self.columns;
	if(colCount>1){
		for( NSUInteger i=0; i<rowCount; i++ ){
			NSMutableArray* thisRow = [_rowArray objectAtIndex:i];
			[thisRow removeLastObject];
		}
		return YES;
	}
	return NO;
}

#pragma mark -
- (NSUInteger)rows {
	return [_rowArray count];
}

- (NSUInteger)columns {
	return ([_rowArray count] > 0) ? [[_rowArray objectAtIndex:0] count] : 0;
}

@end
