//
//  GridLayoutTests.m
//  iphonePlay
//
//  Created by steve hooley on 19/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "GridLayout.h"


@interface GridLayoutTests : SenTestCase {
	
	GridLayout *gridLayout;
}

@end

@implementation GridLayoutTests

- (void)setUp {
	
	gridLayout = [[GridLayout alloc] init];
}

- (void)tearDown {
	
	[gridLayout release];
}

#warning! fucked - redo margin and overlap!

- (void)testGridLayout {
	
	gridLayout.gridWidth = 130;
	gridLayout.gridHeight = 130;
	gridLayout.margin = 10;
	gridLayout.xCells = 4;
	gridLayout.yCells = 4;
	
	STAssertTrue( gridLayout.cellWidth==25, @"should be - is %i", gridLayout.cellWidth );
	STAssertTrue( gridLayout.cellHeight==25, @"should be");

	NSArray *allCellRects = gridLayout.cellRects;
	STAssertTrue( [allCellRects count]==16, @"should be");

	// row1
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:0] CGRectValue], CGRectMake(0,0,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:0] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:1] CGRectValue], CGRectMake(35,0,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:1] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:2] CGRectValue], CGRectMake(70,0,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:2] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:3] CGRectValue], CGRectMake(105,0,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:3] CGRectValue])));

	// row2
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:4] CGRectValue], CGRectMake(0,35,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:4] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:5] CGRectValue], CGRectMake(35,35,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:5] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:6] CGRectValue], CGRectMake(70,35,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:6] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:7] CGRectValue], CGRectMake(105,35,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:7] CGRectValue])));

	// row3
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:8] CGRectValue], CGRectMake(0,70,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:8] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:9] CGRectValue], CGRectMake(35,70,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:9] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:10] CGRectValue], CGRectMake(70,70,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:10] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:11] CGRectValue], CGRectMake(105,70,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:11] CGRectValue])));

	// row4
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:12] CGRectValue], CGRectMake(0,105,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:12] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:13] CGRectValue], CGRectMake(35,105,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:13] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:14] CGRectValue], CGRectMake(70,105,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:14] CGRectValue])));
	STAssertTrue( CGRectEqualToRect([[allCellRects objectAtIndex:15] CGRectValue], CGRectMake(105,105,25,25) ), @"should be %@", NSStringFromRect(NSRectFromCGRect([[allCellRects objectAtIndex:15] CGRectValue])));
}

@end