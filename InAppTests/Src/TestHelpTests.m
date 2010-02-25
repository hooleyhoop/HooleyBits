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

- (void)setUp {
	_th = [[TestHelp makeWithTest:self] retain];
}

- (void)tearDown {
	[_th release];
}

//-- push test proxies onto a queue, these will be evaluated in order, they can be asynchronous, they will finish completely before next starts
//
//-- test order
//-- test asynchronous
//
//-- so you build a block, push it onto the stack, execute it later it returns a result
//
//-- ignore the result
//-- assert result is true
//-- assert result is false

//-- assert result is equal to another result
- (void)testAssertResultIsEaualToAnotherResult {
	// - (void)aSyncAssertEqual:(AsyncTestProxy *)testProxy :(id)someOtherObject

// Expected behavoir
//	-queue
//	-fire
//	-waitForCallback
//	-process result

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] fire];

	/* call the method */
	[_th aSyncAssertEqual:mockTP :@"steven"];
	[mockTP verify];

	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	[[[mockTP expect] andReturn:@"steven"] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

- (void)testAssertEqualObjectsBlock {
	//- (NSInvocation *)assertEqualObjectsBlock
	
	NSInvocation *equalBlock = [_th _assertEqualObjectsBlock];
	[equalBlock invoke];
}

// Better form of expectation?
//	[expectThat(app.alertView) should].exist;
//	[[app view:@"UIThreePartButton"] touch];


//	[expect that:mockTP equals:@"steven"]

//	[_th aSyncAssertTrue:[GUITestProxy documentCountIs:0]];


@end
