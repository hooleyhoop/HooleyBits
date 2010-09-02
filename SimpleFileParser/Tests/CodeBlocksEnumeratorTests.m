//
//  CodeBlocksEnumeratorTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "CodeBlocksEnumerator.h"
#import "CodeBlockStore.h"
#import "CodeLine.h"
#import "CodeBlock.h"

@interface CodeBlocksEnumeratorTests : SenTestCase {
	
	CodeBlockStore			*_cbs; 
	CodeBlocksEnumerator	*_cbe;
}

@end


@implementation CodeBlocksEnumeratorTests

- (void)setUp {
	
	_cbs = [[CodeBlockStore alloc] init]; 
	_cbe = [[CodeBlocksEnumerator alloc] initWithCodeBlockStore:_cbs];
}

- (void)tearDown {
	
	[_cbe release];
	[_cbs release];
}

- (void)testEnumerateCodeBlockStore {
	
	CodeBlock *block1 = [CodeBlock blockWithName:@"steve"];
	CodeBlock *block2 = [CodeBlock blockWithName:@"james"];
	CodeBlock *block3 = [CodeBlock blockWithName:@"dave"];
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:30];	
	
	[block1 pushLine:line1];
	[block2 pushLine:line2];
	[block3 pushLine:line3];
	
	[_cbs insertCodeBlock:block1];
	[_cbs insertCodeBlock:block2];
	[_cbs insertCodeBlock:block3];
	
	NSUInteger counter = 0;
	NSString *lineString;
	while( (lineString=[_cbe nextLine])!=nil ) {

		switch (counter) {
			case 0:
				STAssertTrue( [lineString isEqualToString:@"steve"], nil);
				break;
			case 1:
				STAssertTrue( [lineString isEqualToString:@"10"], nil);
				break;
			case 2:
				STAssertTrue( [lineString isEqualToString:@"\n"], nil);
				break;
			case 3:
				STAssertTrue( [lineString isEqualToString:@"james"], nil);
				break;
			case 4:
				STAssertTrue( [lineString isEqualToString:@"20"], nil);
				break;
			case 5:
				STAssertTrue( [lineString isEqualToString:@"\n"], nil);
				break;
			case 6:
				STAssertTrue( [lineString isEqualToString:@"dave"], nil);
				break;
			case 7:
				STAssertTrue( [lineString isEqualToString:@"30"], nil);
				break;
			default:
				[NSException raise:@"too many lines" format:@""];
				break;
		}
		counter++;
	}
	STAssertTrue( counter==8, @"enumerator returned wrong number of lines?" );
}



@end
