//
//  TestNSInvocation_testFutures.m
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "AsyncTests.h"
#import "NSInvocation_testFutures.h"

@interface TestNSInvocation_testFutures : SenTestCase {
	
}

@end


@implementation TestNSInvocation_testFutures

//  Test that we build an invocation that calls back to our test class (STAsserts need to be on the test class) with the correct arguments
- (void)test_assertEqualObjectsInvocation_expectedResult {
	//+ (NSInvocation *)_assertEqualObjectsInvocation:(TestHelp *)tests expectedResult:(id)ob2

	NSString *expectedResult = @"steven";
	
	id mockTests = MOCK(AsyncTests);
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assert_arg1:nil arg2:expectedResult ofBlock:OCMOCK_ANY failMsg:nil];
	
	NSInvocation *equalBlock = [NSInvocation_testFutures _assertEqualObjectsInvocation:mockTests expectedResult:expectedResult];
	[equalBlock invoke];
	
	[mockTests verify];
}

- (void)test_assertFailInvocation { 
	//+ (NSInvocation *)_assertFailInvocation:(TestHelp *)tests

	id mockTests = MOCK(AsyncTests);
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assert_arg1:nil ofBlock:OCMOCK_ANY failMsg:nil];
	
	NSInvocation *equalBlock = [NSInvocation_testFutures _assertFailInvocation:mockTests];
	[equalBlock invoke];
	
	[mockTests verify];
}

- (void)test_assertTrueInvocation {
	//+ (NSInvocation *)_assertTrueInvocation:(TestHelp *)tests

	id mockTests = MOCK(AsyncTests);
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assert_arg1:nil ofBlock:OCMOCK_ANY failMsg:nil];
	
	NSInvocation *equalBlock = [NSInvocation_testFutures _assertTrueInvocation:mockTests];
	[equalBlock invoke];
	
	[mockTests verify];
}

- (void)test_assertResultNilInvocation {
	//+ (NSInvocation *)_assertResultNilInvocation:(TestHelp *)tests

	id mockTests = MOCK(AsyncTests);
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assert_arg1:nil ofBlock:OCMOCK_ANY failMsg:nil];
	
	NSInvocation *equalBlock = [NSInvocation_testFutures _assertResultNilInvocation:mockTests];
	[equalBlock invoke];
	
	[mockTests verify];
}

- (void)test_assertResultNotNilInvocation {
	//+ (NSInvocation *)_assertResultNotNilInvocation:(TestHelp *)tests

	id mockTests = MOCK(AsyncTests);
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assert_arg1:nil ofBlock:OCMOCK_ANY failMsg:nil];
	
	NSInvocation *equalBlock = [NSInvocation_testFutures _assertResultNotNilInvocation:mockTests];
	[equalBlock invoke];
	
	[mockTests verify];
}

@end
