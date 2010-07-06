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

- (void)testInsertionIndexFor {
	// - (NSUInteger)insertionIndexFor:(Line *)arg

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	
	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	
	STAssertTrue( [block1 insertionIndexFor:line4]==3, nil );
}

- (void)testCompareStartToAddress {
	// - (NSComparisonResult)compareStartToAddress:(NSUInteger)addr
	STFail(@"do this now");
}

- (void)testStartAddress {
	// - (NSUInteger)startAddress

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	
	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	[block1 pushLine:line4];
	
	STAssertTrue( [block1 endAddress]==10, nil );
}

- (void)testEndAddress {
	// - (NSUInteger)endAddress

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	
	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	[block1 pushLine:line4];
	
	STAssertTrue( [block1 endAddress]==30, nil );
}

- (void)testFirstLine {
	// - (CodeLine *)firstLine

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	
	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	[block1 pushLine:line4];
	
	STAssertTrue( [block1 firstLine]==line1, nil );
}

- (void)testLastLine {
	// - (CodeLine *)lastLine

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];
	
	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	[block1 pushLine:line4];
	
	STAssertTrue( [block1 lastLine]==line4, nil );
}

- (void)testName {
	// - (NSString *)name

	CodeBlock *block1 = [CodeBlock blockWithName:@"nil"];
	STAssertTrue( [block1 name]==@"Steve", nil);
}

- (void)testLineAtIndex {
	// - (CodeLine *)lineAtIndex:(NSUInteger)ind

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:20];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *block1 = [CodeBlock block];

	[block1 pushLine:line1];
	[block1 pushLine:line2];
	[block1 pushLine:line3];
	[block1 pushLine:line4];
	
	STAssertTrue( [block1 lineAtIndex:0]==line1, nil );
	STAssertTrue( [block1 lineAtIndex:1]==line2, nil );
	STAssertTrue( [block1 lineAtIndex:2]==line3, nil );
	STAssertTrue( [block1 lineAtIndex:3]==line4, nil );
}

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

- (void)testLineCount {
	
	// - (void)pushLine:(Line *)arg
	// - (NSUInteger)lineCount

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	
	CodeBlock *block1 = [CodeBlock block];
	[block1 pushLine:line1];

	STAssertTrue([block1 lineCount]==1, nil);
	
	[block1 pushLine:line2];
	STAssertTrue([block1 lineCount]==2, nil);
}


@end
