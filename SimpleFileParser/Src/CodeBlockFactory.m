//
//  CodeBlockFactory.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeBlockFactory.h"
#import "CodeBlockStore.h"
#import "CodeBlock.h"
#import "CodeLine.h"

@interface CodeBlockFactory ()

- (void)setCurrentBlock:(CodeBlock *)blk;

@end

@implementation CodeBlockFactory

- (void)dealloc {

	[_blockStore release];
	[_currenBlock release];

	[super dealloc];
}

- (void)newCodeBlockWithName:(NSString *)funcName {

	NSAssert( _blockStore, @"need a blockstore" );

	if(funcName)
		NSLog(@"Name-- %@", funcName);
	
	CodeBlock *newBlock = [CodeBlock block];
	[self setCurrentBlock:newBlock];
}

- (void)addCodeLine:(NSString *)codeLine {

	NSAssert( _currenBlock, @"need a blockstore" );

	// TODO: make the real fucking line prick
	CodeLine *line = [CodeLine lineWithAddress:0];
	[_currenBlock pushLine:line];
	
	if( [_currenBlock lineCount]==1 )
		[_blockStore addCodeBlock: _currenBlock];
}

- (NSUInteger)countOfCodeBlocks {
	return [_blockStore blockCount];
}

- (NSArray *)allCodeBlocks {
	return [_blockStore allBlocks];
}

- (void)setStore:(CodeBlockStore *)str {
	_blockStore = [str retain];
}

- (void)setCurrentBlock:(CodeBlock *)blk {

	if(_currenBlock!=blk) {
		[_currenBlock release];
		_currenBlock = [blk retain];
	}
}

@end
