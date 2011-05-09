//
//  ContiguousMemoryBlockStoreTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 30/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ContiguousMemoryBlockStore.h"
#import "TPLine.h"

@interface ContiguousMemoryBlockStoreTests : SenTestCase {
@private
    
}

@end


@implementation ContiguousMemoryBlockStoreTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testContiguousLength {
    
    char simpleInData1[1] = {0xff};  
    char simpleInData2[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock1 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData1 start:(char *)0 length:1];
    STAssertTrue([codeDataBlock1 contiguousLength]==1, nil);
    [codeDataBlock1 release];
    
    id codeDataBlock2 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData2 start:(char *)1 length:10];
    STAssertTrue([codeDataBlock2 contiguousLength]==10, nil);
    [codeDataBlock2 release];   
}

- (void)testContainsAddress {
    
    char simpleInData1[1] = {0xff};  
    char simpleInData2[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock1 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData1 start:(char *)0 length:1];
    STAssertTrue([codeDataBlock1 containsAddress:(char *)0], nil);
    STAssertFalse([codeDataBlock1 containsAddress:(char *)9], nil);
    [codeDataBlock1 release];
    
    id codeDataBlock2 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData2 start:(char *)1 length:10];
    STAssertFalse([codeDataBlock2 containsAddress:(char *)0], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)1], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)5], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)10], nil);
    STAssertFalse([codeDataBlock2 containsAddress:(char *)11], nil);    
    [codeDataBlock2 release];
}

- (void)testGetItemAtAddress {
    // - (enum datatype)getItemAtAddress:(int)address item:(id *)ptr
    
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:0 length:10];
    
    id datBlock;
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)0 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)5 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)9 item:&datBlock]==datatype_DATA, nil);
    
    [codeDataBlock release];
}

// -- when we have implemented memory section splitting lets put this back
//- (void)testTemporarySimpleSplit {
//    
//    /* Simple case */
//    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
//    id codeDataBlock = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:0 length:10];
//    
//    [codeDataBlock simpleTemporarySplitAtAddress:(char *)5];
//    STAssertTrue( [codeDataBlock startAddress]==0, nil);
//    STAssertTrue( [codeDataBlock contiguousLength]==10, nil);
//    STAssertTrue( [codeDataBlock itemCount]==2, nil);
//    
//    SHMemoryBlock *item1 = [codeDataBlock memoryBlockAtIndex:0];
//    STAssertTrue( [item1 startAddress]==(char *)0, nil);
//    STAssertTrue( [item1 length]==5, nil);
//    STAssertTrue( [item1 lastAddress]==(char *)4, nil);
//    
//    SHMemoryBlock *item2 = [codeDataBlock memoryBlockAtIndex:1];
//    STAssertTrue( [item2 startAddress]==(char *)5, nil);
//    STAssertTrue( [item2 length]==5, nil);
//    STAssertTrue( [item2 lastAddress]==(char *)9, @"%i", [item1 lastAddress] );
//    
//    [codeDataBlock release];
//    
//    /* Complex case */
//    id codeDataBlock2 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:(char *)100 length:10];
//    STAssertThrows( [codeDataBlock2 simpleTemporarySplitAtAddress:(char *)5], nil);
//    STAssertThrows( [codeDataBlock2 simpleTemporarySplitAtAddress:(char *)100], nil);
//    STAssertThrows( [codeDataBlock2 simpleTemporarySplitAtAddress:(char *)110], nil);
//    
//    [codeDataBlock2 simpleTemporarySplitAtAddress:(char *)105];
//    
//    STAssertTrue( [codeDataBlock2 startAddress]==(char *)100, nil);
//    STAssertTrue( [codeDataBlock2 contiguousLength]==10, nil);
//    STAssertTrue( [codeDataBlock2 itemCount]==2, nil);
//    
//    SHMemoryBlock *item3 = [codeDataBlock2 memoryBlockAtIndex:0];
//    STAssertTrue( [item3 startAddress]==(char *)100, nil);
//    STAssertTrue( [item3 length]==5, nil);
//    STAssertTrue( [item3 lastAddress]==(char *)104, nil);
//    
//    SHMemoryBlock *item4 = [codeDataBlock2 memoryBlockAtIndex:1];
//    STAssertTrue( [item4 startAddress]==(char *)105, nil);
//    STAssertTrue( [item4 length]==5, nil);
//    STAssertTrue( [item4 lastAddress]==(char *)109, @"%i", [item1 lastAddress] );
//    
//    [codeDataBlock2 release];
//}

- (void)testSplitData_atIndex_withLine {
    // - (void)splitData:(SHMemoryBlock *)dataBlk atIndex:(int)ind withLine:(TPLine *)line
    
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:0 length:10];
    id mockLine1 = [[[TPLine alloc] initWithStart:(char *)1 length:1] autorelease];
    
    [codeDataBlock splitData:[codeDataBlock memoryBlockAtIndex:0] atIndex:0 withLine:mockLine1];
    
    STAssertTrue( [codeDataBlock itemCount]==3, nil);
    SHMemoryBlock *item1 = [codeDataBlock memoryBlockAtIndex:0];
    SHMemoryBlock *item2 = [codeDataBlock memoryBlockAtIndex:1];
    SHMemoryBlock *item3 = [codeDataBlock memoryBlockAtIndex:2];
    
    STAssertTrue( [item1 startAddress]==(char *)0, nil);
    STAssertTrue( [item1 length]==1, nil);
    STAssertTrue( [item1 lastAddress]==(char *)0, nil);
    
    STAssertTrue( [item2 startAddress]==(char *)1, nil);
    STAssertTrue( [item2 length]==1, nil);
    STAssertTrue( [item2 lastAddress]==(char *)1, nil);
    STAssertTrue( item2 == mockLine1, nil);
    
    STAssertTrue( [item3 startAddress]==(char *)2, nil);
    STAssertTrue( [item3 length]==8, nil);
    STAssertTrue( [item3 lastAddress]==(char *)9, nil);
    
    id mockLine2 = [[[TPLine alloc] initWithStart:(char *)0 length:1] autorelease];
    [codeDataBlock splitData:[codeDataBlock memoryBlockAtIndex:0] atIndex:0 withLine:mockLine2];
    STAssertTrue( [codeDataBlock itemCount]==3, nil);
    STAssertTrue( [codeDataBlock memoryBlockAtIndex:0] == mockLine2, nil);
    
    id mockLine3 = [[[TPLine alloc] initWithStart:(char *)9 length:1] autorelease];    
    [codeDataBlock splitData:[codeDataBlock memoryBlockAtIndex:2] atIndex:2 withLine:mockLine3];
    STAssertTrue( [codeDataBlock itemCount]==4, nil);
    STAssertTrue( [codeDataBlock memoryBlockAtIndex:3] == mockLine3, nil);
    
    item3 = [codeDataBlock memoryBlockAtIndex:2];
    STAssertTrue( [item3 startAddress]==(char *)2, nil);
    STAssertTrue( [item3 length]==7, nil);
    STAssertTrue( [item3 lastAddress]==(char *)8, nil);
    
    [codeDataBlock release];
}

@end
