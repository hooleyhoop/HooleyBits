//
//  CodeBlockTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


#import "CodeLine.h"
#import "CodeBlock.h"

@interface CodeBlockTests : SenTestCase {
	
}

@end


@implementation CodeBlockTests

- (void)setUp {
	
}

- (void)tearDown {
	
}

//- (NSUInteger)insertionIndexFor:(Line *)arg;
//
//- (void)pushLine:(Line *)arg;
//- (void)insertLine:(Line *)arg;

- (void)testCompareStartAddress {
	// - (NSComparisonResult)compareStartAddress:(Line *)arg

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	[block1 pushLine:line1];
	 
	CodeBlock *block2 = [CodeBlock block];
	[block2 pushLine:line2];

	CodeBlock *block3 = [CodeBlock block];
	[block3 pushLine:line3];

	CodeBlock *block4 = [CodeBlock block];
	[block4 pushLine:line4];

	NSComparisonResult a = [block1 compareStartAddress:block2];
	STAssertTrue( a==NSOrderedAscending, nil );
	
	NSComparisonResult b = [block2 compareStartAddress:block3];
	STAssertTrue( b==NSOrderedSame, nil );
	
	NSComparisonResult c = [block4 compareStartAddress:block3];
	STAssertTrue( c==NSOrderedDescending, nil );
}


@end
