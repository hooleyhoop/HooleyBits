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
#import "GenericTimer.h"

@interface CodeBlockFactory ()

- (void)setCurrentBlock:(CodeBlock *)blk;

@end

@implementation CodeBlockFactory

+ (id)factoryWithStore:(CodeBlockStore *)str {

	return [[[self alloc] initWithStore:str] autorelease];
}

- (id)initWithStore:(CodeBlockStore *)str {

	self = [super init];
	if(self){
		_anonFunctionCount = 0;
		_blockStore = [str retain];
	}
	return self;
}

- (void)dealloc {

	[_blockStore release];
	[_currenBlock release];

	[super dealloc];
}

- (void)newCodeBlockWithName:(NSString *)funcName lines:(NSArray *)lineArray {
	//NSLog(@"async woo woo woo woo woo");
	
	CodeBlock *newBlock = [CodeBlock blockWithName:funcName];
	for( CodeLine *each in lineArray)
		[newBlock pushLine:each];
	[_blockStore addCodeBlockOutOfOrder: newBlock];
}

- (void)newCodeBlockWithName:(NSString *)funcName {

	NSAssert( _blockStore, @"need a blockstore" );

	if(funcName)
		NSLog(@"Name-- %@", funcName);
	else {
		funcName = [NSString stringWithFormat:@"%lu", _anonFunctionCount++];
	}

	CodeBlock *newBlock = [CodeBlock blockWithName:funcName];
	[self setCurrentBlock:newBlock];
}

- (void)noMoreLines {

	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];

	NSLog(@"about to sort blockstore %i", [_blockStore blockCount]);
	[_blockStore sort];
	NSLog(@"sorted blockstore %i", [_blockStore blockCount]);
	
	[readTimer close];
}

- (void)addCodeLine:(CodeLine *)line {

	NSAssert( _currenBlock, @"need a blockstore" );

	[_currenBlock pushLine:line];
	
	if( [_currenBlock lineCount]==1 )
		[_blockStore insertCodeBlock: _currenBlock];
}

- (NSUInteger)countOfCodeBlocks {
	return [_blockStore blockCount];
}

- (NSArray *)allCodeBlocks {
	return [_blockStore allBlocks];
}

- (void)setCurrentBlock:(CodeBlock *)blk {

	if(_currenBlock!=blk) {
		[_currenBlock release];
		_currenBlock = [blk retain];
	}
}

@end
