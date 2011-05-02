//
//  SHMemoryBlockTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SHMemoryBlock.h"

@interface SHMemoryBlockTests : SenTestCase {
@private
    
}

@end

@implementation SHMemoryBlockTests

char testData[10] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09};

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicDimensionalProperties {
    
    SHMemoryBlock *data1 = [[SHMemoryBlock alloc] initWithStart:testData length:10];
    STAssertTrue([data1 startAddress]==testData, nil);
    STAssertTrue([data1 lastAddress]==testData+9, nil);
    STAssertTrue([data1 length]==10, nil);
    [data1 release];
}

- (void)testContainsAddress {
    //- (BOOL)containsAddress:(char *)addr
    
    SHMemoryBlock *data1 = [[SHMemoryBlock alloc] initWithStart:testData length:10];
    STAssertTrue( [data1 containsAddress:testData], nil);
    STAssertTrue( [data1 containsAddress:testData+9], nil);
    STAssertFalse( [data1 containsAddress:0], nil);
    STAssertFalse( [data1 containsAddress:testData+10], nil);    
    [data1 release];
}

- (void)testSplitAtAddress {
    
    // - (void)splitAtAddress:(char *)addrr
    SHMemoryBlock *data1 = [[SHMemoryBlock alloc] initWithStart:0 length:10];
    struct SplitData result = [data1 splitAtAddress:(char *)5];
    
    STAssertTrue([result.blk1 startAddress]==0, nil);
    STAssertTrue([result.blk1 lastAddress]==(char *)4, nil);
    STAssertTrue([result.blk1 length]==5, nil);

    STAssertTrue([result.blk2 startAddress]==(char *)5, nil);
    STAssertTrue([result.blk2 lastAddress]==(char *)9, nil);
    STAssertTrue([result.blk2 length]==5, nil);

    // 0 1 2 3 4 5 6 7 8 9    
    STAssertThrows( [data1 splitAtAddress:(char *)0], nil );
    STAssertThrows( [data1 splitAtAddress:(char *)10], nil );
    
    [data1 release];    
}
@end
