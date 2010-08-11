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

+ (id)store {
	return [[[self alloc] init] autorelease];
}

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
	
	if( address< [[_codeBlockStore objectAtIndex:0] startAddress] )
		return nil;
	
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
	
	if( index>0 ) {
		CodeBlock *prevOb = [_codeBlockStore objectAtIndex:index-1];
		if( address>=[prevOb startAddress] && address<=[prevOb endAddress] )
			return prevOb;
	}
	
	if( index >= [_codeBlockStore count] )
		return nil;
	
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

- (NSArray *)allBlocks {
	return _codeBlockStore;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	
	CodeBlock *currentBlock;

	NSUInteger total = [self blockCount];
    NSUInteger batchCount=0;
    while( state->state<total && batchCount<len )
    {
        stackbuf[batchCount] = [_codeBlockStore objectAtIndex:state->state];
        state->state++;
        batchCount++;
    }
	
    state->itemsPtr = stackbuf;
    state->mutationsPtr = (unsigned long *)self;
	
    return batchCount;
}

@end
