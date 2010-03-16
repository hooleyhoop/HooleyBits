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

//-- test asynchronous
//-- test order
- (void)testtAsyncOrder {

	OCMockObject *mockTP1 = MOCK(AsyncTestProxy);
	OCMockObject *mockTP2 = MOCK(AsyncTestProxy);
	OCMockObject *mockTP3 = MOCK(AsyncTestProxy);
	
	[[mockTP1 expect] setResultProcessObject:[OCMArg any]];
	[[mockTP2 expect] setResultProcessObject:[OCMArg any]];
	[[mockTP3 expect] setResultProcessObject:[OCMArg any]];

	[[mockTP1 expect] setCallbackOb:_th];
	[[mockTP2 expect] setCallbackOb:_th];
	[[mockTP3 expect] setCallbackOb:_th];
	
	// fire will only be called on the first item until we do the callback
	[[mockTP1 expect] nextRunloopCycle_fire];
	
	[_th aSyncAssertResultNil:(id)mockTP1];
	[_th aSyncAssertResultNil:(id)mockTP2];
	[_th aSyncAssertResultNil:(id)mockTP3];

	[mockTP1 verify];
	[mockTP2 verify];
	[mockTP3 verify];

	/* callback 1 */
	id mockResultAction = MOCK(NSInvocation);

	[[[mockTP1 expect] andReturn:nil] result];
	[[[mockTP1 expect] andReturn:mockResultAction] resultProcessObject];
	[[mockResultAction expect] invoke];
	[[mockTP2 expect] nextRunloopCycle_fire];
	[_th _callBackForASync:(id)mockTP1];	
		
	[mockResultAction verify];
	[mockTP1 verify];
	[mockTP2 verify];
	[mockTP3 verify];

	/* callback 2 */
	[[mockTP3 expect] nextRunloopCycle_fire];
	[[mockResultAction expect] invoke];
	[[[mockTP2 expect] andReturn:nil] result];
	[[[mockTP2 expect] andReturn:mockResultAction] resultProcessObject];
	[_th _callBackForASync:(id)mockTP2];

	[mockResultAction verify];
	[mockTP1 verify];
	[mockTP2 verify];
	[mockTP3 verify];

	/* callback 3 */
	[[mockResultAction expect] invoke];
	[[[mockTP3 expect] andReturn:nil] result];
	[[[mockTP3 expect] andReturn:mockResultAction] resultProcessObject];
	[_th _callBackForASync:(id)mockTP3];	

	[mockResultAction verify];
	[mockTP1 verify];
	[mockTP2 verify];
	[mockTP3 verify];
}

#pragma mark New Async Assertions
- (void)testAsync {
	// - (void)aSync:(AsyncTestProxy *)testProxyFuture

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] nextRunloopCycle_fire];

	[_th aSync:mockTP];

	[mockTP verify];

	[[[mockTP expect] andReturn:nil] result];
	[[[mockTP expect] andReturn:nil] resultProcessObject];

	[_th _callBackForASync:mockTP];

	[mockTP verify];
}


- (void)test_aSyncAssertResultNotNil {
// - (void)aSyncAssertResultNotNil:(AsyncTestProxy *)someKindOfMagicObject

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] nextRunloopCycle_fire];
	
	/* call the method */
	OCMockObject *mockResult = MOCK(NSObject);
	[_th aSyncAssertResultNotNil:mockTP];
	[mockTP verify];
	
	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	[[[mockTP expect] andReturn:mockResult] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	
	// dificult to test that we swap in the result because we swap in a new pointer to it
	[[mockResultAction expect] setArgument:[OCMArg anyPointer] atIndex:2];
	
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

//-- ignore the result
- (void)test_aSyncAssertResultNil {
	// - (void)aSyncAssertResultNil:(AsyncTestProxy *)someKindOfMagicObject

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] nextRunloopCycle_fire];
	
	/* call the method */
	[_th aSyncAssertResultNil:mockTP];
	[mockTP verify];
	
	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	[[[mockTP expect] andReturn:nil] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

//-- assert result is true
- (void)test_aSyncAssertTrue {
	// - (void)aSyncAssertTrue:(AsyncTestProxy *)someKindOfMagicObject
	
	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] nextRunloopCycle_fire];
	
	/* call the method */
	[_th aSyncAssertTrue:mockTP ];
	[mockTP verify];
	
	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	FSBoolean *fakeResult = [FSBoolean fsTrue];
	[[[mockTP expect] andReturn:fakeResult] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	[[mockResultAction expect] setArgument:[OCMArg anyPointer] atIndex:2];
	
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

//-- assert result is false
- (void)test_aSyncAssertFalse {
	// - (void)aSyncAssertFalse:(AsyncTestProxy *)someKindOfMagicObject

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] nextRunloopCycle_fire];
	
	/* call the method */
	[_th aSyncAssertFalse:mockTP ];
	[mockTP verify];
	
	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	FSBoolean *fakeResult = [FSBoolean fsFalse];
	[[[mockTP expect] andReturn:fakeResult] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	[[mockResultAction expect] setArgument:[OCMArg anyPointer] atIndex:2];
	
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

//-- assert result is equal to another result
- (void)test_aSyncAssertEqual {
	// - (void)aSyncAssertEqual:(AsyncTestProxy *)testProxy :(id)someOtherObject

// Expected behavoir
//	-queue
//	-fire
//	-waitForCallback
//	-swap result into result invocation, fire result invocation

	id mockTP = MOCK(AsyncTestProxy);
	[[mockTP expect] setCallbackOb:_th];
	[[mockTP expect] setResultProcessObject:[OCMArg any]];
	[[mockTP expect] nextRunloopCycle_fire];

	/* call the method */
	[_th aSyncAssertEqual:mockTP :@"steven"];
	[mockTP verify];

	/* although we -fired, the mock isn't going to call back on it's own - simulate the callback */
	NSString *fakeResult = @"steven";
	[[[mockTP expect] andReturn:fakeResult] result];
	
	id mockResultAction = MOCK(NSInvocation);
	[[mockResultAction expect] invoke];
	[[[mockTP expect] andReturn:mockResultAction] resultProcessObject];
	[[mockResultAction expect] setArgument:[OCMArg anyPointer] atIndex:2]; 
	[_th _callBackForASync:mockTP];
	
	[mockResultAction verify];
	[mockTP verify];
}

// Better form of expectation?
//	[expectThat(app.alertView) should].exist;
//	[[app view:@"UIThreePartButton"] touch];


//	[expect that:mockTP equals:@"steven"]

//	[_th aSyncAssertTrue:[GUITestProxy documentCountIs:0]];


@end
