//
//  CodeBlock.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeLine;

@interface CodeBlock : NSObject {

	NSMutableArray *_lineStore;
}

+ (id)block;

- (NSUInteger)insertionIndexFor:(CodeLine *)arg;

- (void)pushLine:(CodeLine *)arg;
- (void)insertLine:(CodeLine *)arg;

- (NSComparisonResult)compareStartAddress:(CodeBlock *)aBlock;
- (NSComparisonResult)compareStartToAddress:(NSUInteger)addr;

- (NSUInteger)startAddress;
- (NSUInteger)endAddress;

- (CodeLine *)firstLine;
- (CodeLine *)lastLine;

@end
