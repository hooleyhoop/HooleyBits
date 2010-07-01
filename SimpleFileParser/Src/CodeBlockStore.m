//
//  CodeBlockStore.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeBlockStore.h"
#import "CodeBlock.h"

@interface CodeBlockStore ()
- (NSUInteger)findInsertionPt:(CodeBlock *)block;
@end

@implementation CodeBlockStore

- (id)init {
	
	self = [super init];
	if(self){
		_codeBlockStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	
	[_codeBlockStore release];
	[super dealloc];
}

- (void)addCodeBlock:(CodeBlock *)aBlock {
	
	NSUInteger ind = [self findInsertionPt:aBlock];
	[_codeBlockStore insertObject:aBlock atIndex:ind];
}

- (CodeBlock *)codeBlockForAddress:(NSUInteger)address {
	
	NSUInteger low = 0;
	NSUInteger high  = [_codeBlockStore count];
	NSUInteger index = low;
	
	while( index < high )
	{
		const NSUInteger mid = (index + high)/2;
		CodeBlock *test = [_codeBlockStore objectAtIndex: mid];
		
		NSInteger result = [test compareStartToAddress:address];
		
		if ( result < 0) {
			index = mid + 1;
		} else {
			high = mid;
		}
	}
	return [_codeBlockStore objectAtIndex: index];
}


- (NSUInteger)findInsertionPt:(CodeBlock *)block {
	
	NSUInteger low = 0;
	NSUInteger high  = [_codeBlockStore count];
	NSUInteger index = low;

	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		CodeBlock *test = [_codeBlockStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddress:block];
		if ( result < 0) {
			index = mid + 1;
		} else {
			high = mid;
		}
	}
	return index;
}

- (NSUInteger)blockCount {
	return [_codeBlockStore count];
}

- (CodeBlock *)blockAtIndex:(NSUInteger)ind {
	return [_codeBlockStore objectAtIndex:ind];
}

@end
