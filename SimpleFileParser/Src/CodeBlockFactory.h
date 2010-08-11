//
//  CodeBlockFactory.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "iMakeCodeBlocks.h"

@class CodeBlockStore, CodeBlock;

@interface CodeBlockFactory : NSObject <iMakeCodeBlocks> {

	CodeBlockStore	*_blockStore;
	CodeBlock		*_currenBlock;
	NSUInteger		_anonFunctionCount;
}

+ (id)factoryWithStore:(CodeBlockStore *)str;

- (id)initWithStore:(CodeBlockStore *)str;

- (NSUInteger)countOfCodeBlocks;

- (NSArray *)allCodeBlocks;

@end
