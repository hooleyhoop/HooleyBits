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
		char *newLastAddress = [memBlock lastAddress];
		char *currentStartAddress = [existingObjectAtThatIndex startAddress];
		
		if( newLastAddress >= currentStartAddress )
			[NSException raise:@"Addresses have colided" format:@"Addresses have colided %i > %i", newLastAddress, currentStartAddress];
	}
	
	[_memoryBlockStore insertObject:memBlock atIndex:ind];
}

- (void)replaceItemAtIndex:(int)ind with:(SHMemoryBlock *)firstItem,  ... {
    
    [_memoryBlockStore replaceObjectAtIndex:ind++ withObject:firstItem];

    id eachObject;
    va_list argumentList;
    va_start(argumentList, firstItem);
    while (eachObject = va_arg(argumentList, id))
        [_memoryBlockStore insertObject:eachObject atIndex:ind++]; // that isn't nil, add it to self's contents.
    va_end(argumentList);
}

- (SHMemoryBlock *)blockForAddress:(char *)memAddr {

    SHMemoryBlock *memBlk = nil;
    [self block:&memBlk forAddress:memAddr];
    return memBlk;
}

- (NSInteger)block:(SHMemoryBlock **)blk forAddress:(char *)memAddr {

	NSUInteger low = 0;
	NSUInteger high  = [_memoryBlockStore count];
	NSInteger index = low;
	BOOL hit = NO;
	
	while( index < (NSInteger)high ) {
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
	if(!hit){
		index = index-1;
    }
	if(index==-1){
		return -1;
    }
	SHMemoryBlock *test = [_memoryBlockStore objectAtIndex:index];
	if( memAddr>=[test startAddress] && memAddr<=[test lastAddress] ) {
        *blk = test;
		return index;
    }
	return -1;
}

- (NSUInteger)itemCount {
    return [_memoryBlockStore count];
}

- (char *)startAddress {
    return [[_memoryBlockStore objectAtIndex:0] startAddress];
}

- (char *)lastAddress {
	return [[_memoryBlockStore lastObject] lastAddress];
}

- (SHMemoryBlock *)memoryBlockAtIndex:(int)ind {
    return [_memoryBlockStore objectAtIndex:ind];
}
@end
