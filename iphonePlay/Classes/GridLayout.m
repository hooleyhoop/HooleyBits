//
//  GridLayout.m
//  iphonePlay
//
//  Created by steve hooley on 19/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GridLayout.h"


@implementation GridLayout

@synthesize gridWidth, gridHeight, xCells, yCells, cellWidth, cellHeight;
@synthesize margin;

- (id)init {
	
	self = [super init];
	if(self){
	}
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (NSUInteger)cellWidth {
	
	margin = 1;
	CGFloat cellWidthf = ((CGFloat)gridWidth-(xCells-1)*margin) / (CGFloat)xCells;
	return (NSUInteger)cellWidthf;
}

- (NSUInteger)cellHeight {
	
	margin = 1;
	CGFloat cellHeightf = ((CGFloat)gridHeight-(yCells-1)*margin) / (CGFloat)yCells;
	return (NSUInteger)cellHeightf;
}

- (CGSize)size {
	CGFloat xOverlap = 0;
	CGFloat yOverlap = 0;
	return CGSizeZero;
}

- (NSArray *)cellRects {

	CGFloat xpos=0, ypos=0;
	NSUInteger wid = self.cellWidth;
	NSUInteger hei = self.cellHeight;
	NSMutableArray *cellRects = [NSMutableArray array];
	
	CGFloat xOverlap = 0;
	CGFloat yOverlap = 0;

	// layout in a grid fashion from top left
	for( NSUInteger j=0; j<yCells; j++ )
	{
		ypos = j*hei+j*margin;

		for( NSUInteger i=0; i<xCells; i++ )
		{
			xpos = i*wid+i*margin;
			CGRect cellRect = CGRectMake(xpos-(i*xOverlap), ypos-(j*yOverlap),wid,hei);
			NSValue *cellRectValue = [NSValue valueWithCGRect:cellRect];
			[cellRects addObject:cellRectValue];
		}
	}
	return cellRects;
}

@end
