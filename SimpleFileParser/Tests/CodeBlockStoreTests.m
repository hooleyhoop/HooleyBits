//
//  CodeBlockStoreTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "CodeBlockStore.h"
#import "CodeBlock.h"
#import "CodeLine.h"

@interface CodeBlockStoreTests : SenTestCase {
	
	CodeBlockStore *_cbs;
}

@end

@implementation CodeBlockStoreTests

- (void)setUp {
	_cbs = [[CodeBlockStore alloc] init]; 
}

- (void)tearDown {
	[_cbs release];
}

- (void)testAddCodeBlock {
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:25];
	CodeLine *line4 = [CodeLine lineWithAddress:30];

	CodeBlock *aBlock1 = [CodeBlock block];
	[aBlock1 pushLine:line1];

	CodeBlock *aBlock2 = [CodeBlock block];
	[aBlock2 pushLine:line2];
	
	CodeBlock *aBlock3 = [CodeBlock block];
	[aBlock3 pushLine:line3];
	
	CodeBlock *aBlock4 = [CodeBlock block];
	[aBlock4 pushLine:line4];
	
	[_cbs addCodeBlock:aBlock4];
	[_cbs addCodeBlock:aBlock2];
	[_cbs addCodeBlock:aBlock3];
	[_cbs addCodeBlock:aBlock1];
	
	STAssertTrue( [_cbs blockCount]==4, nil );
	STAssertEqualObjects( [_cbs blockAtIndex:0], aBlock1, nil );
	STAssertEqualObjects( [_cbs blockAtIndex:1], aBlock2, nil );
	STAssertEqualObjects( [_cbs blockAtIndex:2], aBlock3, nil );
	STAssertEqualObjects( [_cbs blockAtIndex:3], aBlock4, nil );
}

- (void)testCodeBlockForAddress {

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:25];
	CodeLine *line4 = [CodeLine lineWithAddress:30];
	
	CodeBlock *aBlock1 = [CodeBlock block];
	[aBlock1 pushLine:line1];
	
	CodeBlock *aBlock2 = [CodeBlock block];
	[aBlock2 pushLine:line2];
	
	CodeBlock *aBlock3 = [CodeBlock block];
	[aBlock3 pushLine:line3];
	
	CodeBlock *aBlock4 = [CodeBlock block];
	[aBlock4 pushLine:line4];

	[_cbs addCodeBlock:aBlock1];
	[_cbs addCodeBlock:aBlock2];
	[_cbs addCodeBlock:aBlock3];
	[_cbs addCodeBlock:aBlock4];

	CodeBlock *resultBlock1 = [_cbs codeBlockForAddress:10];
	CodeBlock *resultBlock2 = [_cbs codeBlockForAddress:20];
	CodeBlock *resultBlock3 = [_cbs codeBlockForAddress:25];
	CodeBlock *resultBlock4 = [_cbs codeBlockForAddress:30];
	
	STAssertEqualObjects( resultBlock1, aBlock1, nil );
	STAssertEqualObjects( resultBlock2, aBlock2, nil );
	STAssertEqualObjects( resultBlock3, aBlock3, nil );
	STAssertEqualObjects( resultBlock4, aBlock4, nil );

}


@end
