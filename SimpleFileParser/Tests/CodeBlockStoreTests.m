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

- (void)testInsertCodeBlock {
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:25];
	CodeLine *line4 = [CodeLine lineWithAddress:30];

	CodeBlock *aBlock1 = [CodeBlock blockWithName:nil];
	[aBlock1 pushLine:line1];

	CodeBlock *aBlock2 = [CodeBlock blockWithName:nil];
	[aBlock2 pushLine:line2];
	
	CodeBlock *aBlock3 = [CodeBlock blockWithName:nil];
	[aBlock3 pushLine:line3];
	
	CodeBlock *aBlock4 = [CodeBlock blockWithName:nil];
	[aBlock4 pushLine:line4];
	
	[_cbs insertCodeBlock:aBlock4];
	[_cbs insertCodeBlock:aBlock2];
	[_cbs insertCodeBlock:aBlock3];
	[_cbs insertCodeBlock:aBlock1];
	
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
	
	CodeBlock *aBlock1 = [CodeBlock blockWithName:nil];
	[aBlock1 pushLine:line1];
	
	CodeBlock *aBlock2 = [CodeBlock blockWithName:nil];
	[aBlock2 pushLine:line2];
	
	CodeBlock *aBlock3 = [CodeBlock blockWithName:nil];
	[aBlock3 pushLine:line3];
	
	CodeBlock *aBlock4 = [CodeBlock blockWithName:nil];
	[aBlock4 pushLine:line4];

	[_cbs insertCodeBlock:aBlock1];
	[_cbs insertCodeBlock:aBlock2];
	[_cbs insertCodeBlock:aBlock3];
	[_cbs insertCodeBlock:aBlock4];

	CodeBlock *resultBlock1 = [_cbs codeBlockForAddress:10];
	CodeBlock *resultBlock2 = [_cbs codeBlockForAddress:20];
	CodeBlock *resultBlock3 = [_cbs codeBlockForAddress:25];
	CodeBlock *resultBlock4 = [_cbs codeBlockForAddress:30];
	
	STAssertEqualObjects( resultBlock1, aBlock1, nil );
	STAssertEqualObjects( resultBlock2, aBlock2, nil );
	STAssertEqualObjects( resultBlock3, aBlock3, nil );
	STAssertEqualObjects( resultBlock4, aBlock4, nil );
}

- (void)testComplicatedCodeBlockFroAddress {
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];

	CodeBlock *aBlock1 = [CodeBlock blockWithName:nil];
	[aBlock1 pushLine:line1];
	[aBlock1 pushLine:line2];
	
	[_cbs insertCodeBlock:aBlock1];

	CodeBlock *resultBlock1 = [_cbs codeBlockForAddress:1];
	STAssertNil( resultBlock1, nil );
	
	CodeBlock *resultBlock2 = [_cbs codeBlockForAddress:10];
	STAssertEqualObjects( resultBlock2, aBlock1, nil );
	
	CodeBlock *resultBlock3 = [_cbs codeBlockForAddress:11];
	STAssertEqualObjects( resultBlock3, aBlock1, nil );
	
	CodeBlock *resultBlock4 = [_cbs codeBlockForAddress:20];
	STAssertEqualObjects( resultBlock4, aBlock1, nil );
	
	CodeBlock *resultBlock5 = [_cbs codeBlockForAddress:21];
	STAssertNil( resultBlock5, nil );
}

- (void)testBlockAtIndex {
	// - (CodeBlock *)blockAtIndex:(NSUInteger)ind

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];

	CodeBlock *aBlock1 = [CodeBlock blockWithName:nil];
	[aBlock1 pushLine:line1];

	CodeBlock *aBlock2 = [CodeBlock blockWithName:nil];
	[aBlock2 pushLine:line2];
	
	[_cbs insertCodeBlock:aBlock1];
	[_cbs insertCodeBlock:aBlock2];

	CodeBlock *block1 = [_cbs blockAtIndex:0];
	STAssertTrue( block1==aBlock1, nil);

	CodeBlock *block2 = [_cbs blockAtIndex:1];
	STAssertTrue( block2==aBlock2, nil);
}

- (void)testAllBlocks {
// - (NSArray *)allBlocks

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	
	CodeBlock *aBlock1 = [CodeBlock blockWithName:nil];
	[aBlock1 pushLine:line1];
	
	CodeBlock *aBlock2 = [CodeBlock blockWithName:nil];
	[aBlock2 pushLine:line2];
	
	[_cbs insertCodeBlock:aBlock1];
	[_cbs insertCodeBlock:aBlock2];
	
	NSArray *blocks = [_cbs allBlocks];
	STAssertTrue([blocks count]==2, nil);
	
	STAssertTrue([blocks objectAtIndex:0]==aBlock1, nil);
	STAssertTrue([blocks objectAtIndex:1]==aBlock2, nil);
}

- (void)testForEach {
	// - (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len

	CodeBlock *block1 = [CodeBlock blockWithName:nil];
	CodeBlock *block2 = [CodeBlock blockWithName:nil];
	CodeBlock *block3 = [CodeBlock blockWithName:nil];

	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:30];	
	
	[block1 pushLine:line1];
	[block2 pushLine:line2];
	[block3 pushLine:line3];
	
	[_cbs insertCodeBlock:block1];
	[_cbs insertCodeBlock:block2];
	[_cbs insertCodeBlock:block3];
	
	NSUInteger i = 0;
	for( id each in _cbs ) {
		STAssertTrue( each==[_cbs blockAtIndex:i], nil );
		i++;
	}
}

- (void)testSort {
		
	CodeBlock *block1 = [CodeBlock blockWithName:nil];
	CodeBlock *block2 = [CodeBlock blockWithName:nil];
	CodeBlock *block3 = [CodeBlock blockWithName:nil];
	
	CodeLine *line1 = [CodeLine lineWithAddress:10];
	CodeLine *line2 = [CodeLine lineWithAddress:20];
	CodeLine *line3 = [CodeLine lineWithAddress:30];	
	
	[block1 pushLine:line1];
	[block2 pushLine:line2];
	[block3 pushLine:line3];
	
	[_cbs addCodeBlockOutOfOrder:block2];
	[_cbs addCodeBlockOutOfOrder:block3];
	[_cbs addCodeBlockOutOfOrder:block1];
	
	[_cbs sort];
	
	STAssertTrue( [_cbs blockAtIndex:0]==block1, nil );
	STAssertTrue( [_cbs blockAtIndex:1]==block2, nil );
	STAssertTrue( [_cbs blockAtIndex:2]==block3, nil );

}

@end
