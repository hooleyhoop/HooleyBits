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

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicDimensionalProperties {
    
    char simpleInData[10] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09};
    SHMemoryBlock *data1 = [[SHMemoryBlock alloc] initWithStart:simpleInData length:10];
    STAssertTrue([data1 startAddress]==simpleInData, nil);
    STAssertTrue([data1 lastAddress]==simpleInData+9, nil);
    STAssertTrue([data1 length]==10, nil);
    [data1 release];
}

- (void)testShrinkToLength {
    char simpleInData[10] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09};
    SHMemoryBlock *data1 = [[SHMemoryBlock alloc] initWithStart:simpleInData length:10];
    [data1 shrinkToLength:5];
    STAssertTrue([data1 startAddress]==simpleInData, nil);
    STAssertTrue([data1 lastAddress]==simpleInData+4, nil);
    STAssertTrue([data1 length]==5, nil);
    [data1 release];
}

- (void)testSplittingAMemoryBlock {
    
    //-- make ablock of data, test splitting it (we need to do this to add a line)

}
@end
