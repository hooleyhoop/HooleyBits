//
//  FloorGridStorage.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 25/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FloorGridStorage : NSObject {

	NSMutableArray *_rowArray;
}

@property (readonly) NSMutableArray *rowArray;
@property (readonly) NSUInteger rows, columns;

- (id)initWithRows:(NSUInteger)y columns:(NSUInteger)x;

- (void)resize:(NSUInteger)rows :(NSUInteger)columns;

- (void)addRow_top;
- (void)addRow_bottom;
- (void)addColumn_left;
- (void)addColumn_right;

- (BOOL)removeRow_top;
- (BOOL)removeRow_bottom;
- (BOOL)removeColumn_left;
- (BOOL)removeColumn_right;

@end
