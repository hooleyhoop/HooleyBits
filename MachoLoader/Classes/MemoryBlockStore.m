//
//  MemoryBlockStore.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "MemoryBlockStore.h"
#import "SHMemoryBlock.h"

@implementation MemoryBlockStore

- (id)init {
	
	self = [super init];
	if(self){
		_memoryBlockStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	
	[_memoryBlockStore release];
	[super dealloc];
}

- (NSUInteger)findInsertionPt:(SHMemoryBlock *)memBlock {
	
	NSUInteger low = 0;
	NSUInteger high  = [_memoryBlockStore count];
	NSUInteger index = low;
	
	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		SHMemoryBlock *test = [_memoryBlockStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddress:memBlock];
		if ( result < 0) {
			index = mid + 1;
		} else {
			high = mid;
		}
	}
	return index;
}

- (void)insertMemoryBlock:(SHMemoryBlock *)memBlock {
	
	NSUInteger ind = [self findInsertionPt:memBlock];
	
	// sanity check
	if( ind<[_memoryBlockStore count] ){
		SHMemoryBlock *existingObjectAtThatIndex = [_memoryBlockStore objectAtIndex:ind];
		if( [memBlock lastAddress]<[existingObjectAtThatIndex startAddr]==NO )
			[NSException raise:@"Addresses have colided" format:@""];
	}
	
	[_memoryBlockStore insertObject:memBlock atIndex:ind];
}

- (SHMemoryBlock *)blockForAddress:(NSUInteger)memAddr {
	
	NSUInteger low = 0;
	NSUInteger high  = [_memoryBlockStore count];
	NSInteger index = low;
	BOOL hit = NO;
	
	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		SHMemoryBlock *test = [_memoryBlockStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddressToAddress:memAddr];
		if ( result < 0) {
			index = mid + 1;
		} else if( result==0 ) {
			high = mid;
			hit = YES;
		} else {
			high = mid;
		}
	}
	if(!hit)
		index = index-1;
	if(index==-1)
		return nil;
	SHMemoryBlock *test = [_memoryBlockStore objectAtIndex: index];
	if( memAddr>=[test startAddr] && memAddr<=[test lastAddress] )
		return test;
	return nil;
}

@end
