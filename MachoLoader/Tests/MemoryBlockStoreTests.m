//
//  MemoryBlockStoreTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 25/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

//  Created by Steven Hooley on 25/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MemoryBlockStore.h"
#import "SHMemoryBlock.h"

@interface MemoryBlockStoreTests : SenTestCase {
@private
    
}

@end


@implementation MemoryBlockStoreTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {    
    [super tearDown];
}

- (void)testBlockForAddress {
    // - (SHMemoryBlock *)blockForAddress:(char *)memAddr

    MemoryBlockStore *memStr = [[MemoryBlockStore alloc] init];
        
    SHMemoryBlock *memBlock1 = [[[SHMemoryBlock alloc] initWithStart:0 length:10] autorelease];
    SHMemoryBlock *memBlock2 = [[[SHMemoryBlock alloc] initWithStart:(char *)11 length:10] autorelease];
    [memStr insertMemoryBlock:memBlock1];
    [memStr insertMemoryBlock:memBlock2];

    SHMemoryBlock *blk1 = [memStr blockForAddress:(char *)0];
    SHMemoryBlock *blk2 = [memStr blockForAddress:(char *)11];

    STAssertTrue( blk1==memBlock1, nil );
    STAssertTrue( blk2==memBlock2, nil );
    
    // bounds checks
    SHMemoryBlock *blk3 = [memStr blockForAddress:(char *)50];
    STAssertNil( blk3, nil );
    
    [memStr release];
}

- (void)testBlock_ForAddress {
    // - (NSInteger)block:(SHMemoryBlock **)blk forAddress:(char *)memAddr
    
    MemoryBlockStore *memStr = [[MemoryBlockStore alloc] init];

    SHMemoryBlock *memBlock1 = [[[SHMemoryBlock alloc] initWithStart:0 length:10] autorelease];
    SHMemoryBlock *memBlock2 = [[[SHMemoryBlock alloc] initWithStart:(char *)11 length:10] autorelease];
    [memStr insertMemoryBlock:memBlock1];
    [memStr insertMemoryBlock:memBlock2];
    
    SHMemoryBlock *blk1, *blk2;
    NSInteger foundIndex1 = [memStr block:&blk1 forAddress:(char *)0];
    NSInteger foundIndex2 = [memStr block:&blk2 forAddress:(char *)11];

    STAssertTrue( foundIndex1==0, nil );
    STAssertTrue( foundIndex2==1, nil );
    STAssertTrue( blk1==memBlock1, nil );
    STAssertTrue( blk2==memBlock2, nil );
    
    // boundry cases
    SHMemoryBlock *blk3;    
    NSInteger foundIndex3 = [memStr block:&blk3 forAddress:(char *)50];
    STAssertTrue( foundIndex3==-1, nil );

    [memStr release];
}

- (void)testReplaceItemAtIndex_with {
    // - (void)replaceItemAtIndex:(int)ind with:(SHMemoryBlock *)firstItem,  ...
    
    MemoryBlockStore *memStr = [[MemoryBlockStore alloc] init];
    SHMemoryBlock *memBlock1 = [[[SHMemoryBlock alloc] initWithStart:0 length:10] autorelease];
    [memStr insertMemoryBlock:memBlock1];
    
    SHMemoryBlock *memBlock2 = [[[SHMemoryBlock alloc] initWithStart:0 length:2] autorelease];
    SHMemoryBlock *memBlock3 = [[[SHMemoryBlock alloc] initWithStart:(char *)2 length:2] autorelease];
    SHMemoryBlock *memBlock4 = [[[SHMemoryBlock alloc] initWithStart:(char *)4 length:2] autorelease];

    [memStr replaceItemAtIndex:0 with:memBlock2, memBlock3, memBlock4, nil];
    
    STAssertTrue( [memStr itemCount]==3, nil);
    STAssertTrue( [memStr memoryBlockAtIndex:0]==memBlock2, nil);
    STAssertTrue( [memStr memoryBlockAtIndex:1]==memBlock3, nil);
    STAssertTrue( [memStr memoryBlockAtIndex:2]==memBlock4, nil);
    [memStr release];    
}

@end
