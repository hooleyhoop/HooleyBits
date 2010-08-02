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
}

- (NSUInteger)countOfCodeBlocks;

- (NSArray *)allCodeBlocks;
- (void)setStore:(CodeBlockStore *)str;

@end
