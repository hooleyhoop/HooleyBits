//
//  TestHelpTests.m
//  InAppTests
//
//  Created by steve hooley on 12/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "AsyncTests.h"
#import "TestHelp.h"
#import "AsyncTestProxy.h"

@interface TestHelpTests : AsyncTests {
	
	TestHelp *_th;
}

@end


@implementation TestHelpTests

static NSAutoreleasePool *pool;

- (void)setUp {
	pool = [[NSAutoreleasePool alloc] init];
	_th = [[TestHelp makeWithTest:self] retain];
}

- (void)tearDown {
	[_th release];
	[pool release];
}

//-- push test proxies onto a queue, these will be evaluated in order, they can be asynchronous, they will finish completely before next starts
//-- so you build a block, push it onto the stack, execute it later it returns a result

//-- test order
- (void) {
	
}

//-- test asynchronous
- (void) {
	
}

//-- ignore the result
- (void) {
	
}

//-- assert result is true
- (void) {
	
}

//-- assert result is false
- (void) {
	
}

//-- assert result is equal to another result
- (void)testAssertResultIsEqualToAnotherResult {
	// - (void)aSyncAssertEqual:(AsyncTestProxy *)testProxy :(id)someOtherObject

// Expected behavoir
//	-queue
//	-fire
//	-waitForCallback
//	-swap result into result invocation, fire result invocation

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] fire];

	/* call the method */
	[_th aSyncAssertEqual:mockTP :@"steven"];
	[mockTP verify];

	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	NSString *fakeResult = @"steven";
	[[[mockTP expect] andReturn:fakeResult] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	[[mockResultAction expect] setArgument:fakeResult atIndex:2];

	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

// Test that we build an invocation that calls back to our test class (STAsserts need to be on the test class) with the correct arguments
- (void)testAssertEqualObjectsBlock {
	//- (NSInvocation *)assertEqualObjectsBlock
	
	NSString *expectedResult = @"steven";
	
	id mockTests = MOCK(AsyncTests);
	SwappedInIvar *swapIn = [SwappedInIvar swapFor:_th :"_tests" :mockTests];
	
	// We expect the first arg of the invocation to be empty because the result wouldn't be availbale at this stage
	[[mockTests expect] assertResultOfBlockIsTrue:OCMOCK_ANY arg1:nil arg2:expectedResult msg:nil];
	
	NSInvocation *equalBlock = [_th _assertEqualObjectsInvocationWithDefferedResultProxy:nil expectedResult:expectedResult];
	[equalBlock invoke];
	
	[mockTests verify];
	[swapIn putBackOriginal];
}

- (void)test_assertEqualObjectsBlock {
	// - (FSBlock *)_assertEqualObjectsBlock

	FSBlock *blk = [_th _assertEqualObjectsBlock];
	id result1 = [blk value:@"Steven" value:@"Steven"];	
	STAssertTrue( [result1 isTrue], nil );
	
	id result2 = [blk value:@"Steven" value:@"Barry"];
	STAssertFalse( [result2 isTrue], nil );
}


// Better form of expectation?
//	[expectThat(app.alertView) should].exist;
//	[[app view:@"UIThreePartButton"] touch];


//	[expect that:mockTP equals:@"steven"]

//	[_th aSyncAssertTrue:[GUITestProxy documentCountIs:0]];


@end
