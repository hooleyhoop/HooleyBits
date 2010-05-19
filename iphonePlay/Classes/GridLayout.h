//
//  GridLayout.h
//  iphonePlay
//
//  Created by steve hooley on 19/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SHooleyObject.h"


@interface GridLayout : SHooleyObject {

	NSUInteger gridWidth, gridHeight, xCells, yCells, cellWidth, cellHeight;
	NSInteger margin;
}

@property NSUInteger gridWidth, gridHeight, xCells, yCells, cellWidth, cellHeight;
@property NSInteger margin;

- (CGSize)size;
- (NSArray *)cellRects;

@end
