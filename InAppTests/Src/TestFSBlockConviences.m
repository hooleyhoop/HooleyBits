//
//  TestFSBlockConviences.m
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "FSBlockConviences.h"

@interface TestFSBlockConviences : SenTestCase {
	
}

@end


@implementation TestFSBlockConviences

#pragma mark Test Block conviences that should be somewhere else
- (void)test_assertEqualObjectsBlock {
	// - (FSBlock *)_assertEqualObjectsBlock
	
	FSBlock *blk = [FSBlockConviences _assertEqualObjectsBlock];
	id result1 = [blk value:@"Steven" value:@"Steven"];	
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:@"Steven" value:@"Barry"];
	STAssertFalse( [result2 isTrue], nil );
}

- (void)test_assertFailBlock {
	// - (FSBlock *)_assertFailBlock
	
	FSBlock *blk = [FSBlockConviences _assertFailBlock];
	id result1 = [blk value:[FSBoolean fsFalse]];
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:[FSBoolean fsTrue]];
	STAssertFalse( [result2 isTrue], nil );
}

- (void)test_assertTrueBlock {
	// - (FSBlock *)_assertTrueBlock
	
	FSBlock *blk = [FSBlockConviences _assertTrueBlock];
	id result1 = [blk value:[FSBoolean fsTrue]];
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:[FSBoolean fsFalse]];
	STAssertFalse( [result2 isTrue], nil );
}

- (void)test_assertNilBlock {
	// - (FSBlock *)_assertNilBlock
	
	FSBlock *blk = [FSBlockConviences _assertNilBlock];
	id result1 = [blk value:nil];
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:[NSArray array]];
	STAssertFalse( [result2 isTrue], nil );
}

- (void)test_assertNotNilBlock {
	// - (FSBlock *)_assertNotNilBlock
	
	FSBlock *blk = [FSBlockConviences _assertNotNilBlock];
	id result1 = [blk value:[NSArray array]];
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:nil];
	STAssertFalse( [result2 isTrue], nil );	
}

@end
