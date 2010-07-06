//
//  CodeBlockStore.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeBlock;

@interface CodeBlockStore : NSObject {

	NSMutableArray *_codeBlockStore;
}

- (void)addCodeBlock:(CodeBlock *)aBlock;
- (CodeBlock *)codeBlockForAddress:(NSUInteger)address;
- (NSUInteger)blockCount;
- (CodeBlock *)blockAtIndex:(NSUInteger)ind;
- (NSArray *)allBlocks;

@end
