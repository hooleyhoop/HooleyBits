//
//  CodeBlock.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeLine;

@interface CodeBlock : NSObject {

	NSString		*_name;
	NSMutableArray	*_lineStore;
}

+ (id)blockWithName:(NSString *)name;

- (NSUInteger)insertionIndexFor:(CodeLine *)insertObject;

- (void)pushLine:(CodeLine *)insertObject;

- (NSComparisonResult)compareStartAddress:(CodeBlock *)aBlock;
- (NSComparisonResult)compareStartToAddress:(NSUInteger)addr;

- (NSUInteger)startAddress;
- (NSUInteger)endAddress;

- (CodeLine *)firstLine;
- (CodeLine *)lastLine;

- (NSString *)name;
- (NSUInteger)lineCount;

- (CodeLine *)lineAtIndex:(NSUInteger)ind;

@end
