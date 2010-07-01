//
//  CodeLineTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeLine.h"


@interface CodeLineTests : SenTestCase {
	
}

@end


@implementation CodeLineTests

- (void)testCompareAddress {
	// - (NSComparisonResult)compareAddress:(Line *)arg

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	NSComparisonResult a = [line1 compareAddress:line2];
	STAssertTrue( a==NSOrderedAscending, nil );
	
	NSComparisonResult b = [line2 compareAddress:line3];
	STAssertTrue( b==NSOrderedSame, nil );
	
	NSComparisonResult c = [line4 compareAddress:line3];
	STAssertTrue( c==NSOrderedDescending, nil );
}

- (void)testCompareAddressToAddress {
	// - (NSComparisonResult)compareAddressToAddress(NSUInteger)addr
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	NSComparisonResult a = [line1 compareAddressToAddress:20];
	STAssertTrue( a==NSOrderedAscending, nil );
	
	NSComparisonResult b = [line2 compareAddressToAddress:20];
	STAssertTrue( b==NSOrderedSame, nil );
	
	NSComparisonResult c = [line4 compareAddressToAddress:20];
	STAssertTrue( c==NSOrderedDescending, nil );
}


@end
