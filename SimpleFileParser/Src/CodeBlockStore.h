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

+ (id)store;

- (void)insertCodeBlock:(CodeBlock *)aBlock;
- (void)addCodeBlockOutOfOrder:(CodeBlock *)aBlock;

- (CodeBlock *)codeBlockForAddress:(NSUInteger)address;
- (NSUInteger)blockCount;
- (CodeBlock *)blockAtIndex:(NSUInteger)ind;
- (NSArray *)allBlocks;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (void)sort;

@end
