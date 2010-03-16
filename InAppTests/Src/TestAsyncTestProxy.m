//
//  TestAsynvTestProxy.m
//  InAppTests
//
//  Created by Steven Hooley on 18/02/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//
#import "AsyncTestProxy.h"
#import "TestHelp.h"
#import "AsyncTests.h"

@interface TestAsyncTestProxy : SenTestCase {
	
	AsyncTestProxy *_testProxy;
}

@end

static NSAutoreleasePool *pool;

@implementation TestAsyncTestProxy

- (void)setUp {
	pool = [[NSAutoreleasePool alloc] init];
	_testProxy = [[AsyncTestProxy alloc] init];
}

- (void)tearDown {
	[_testProxy release];
	[pool release];
}

// Test that when we call fire we get a callback
- (void)testFire {
	
	id mockCallbackOb = MOCK(TestHelp);
	id mockResultAction = MOCK(NSInvocation);
	
	id mockFutureAction = MOCK(NSInvocation);
	[[mockFutureAction expect] invoke];
	[mockFutureAction retain];
	id mockFutureActionMethodSig = MOCK(NSMethodSignature);
	[[[mockFutureAction expect] andReturn:mockFutureActionMethodSig] methodSignature];
	NSUInteger returnValue = 0;
	[[[mockFutureActionMethodSig expect] andReturnValue:OCMOCK_VALUE(returnValue)] methodReturnLength];
	
	SwappedInIvar *swapIn1 = [SwappedInIvar swapFor:_testProxy :"_remoteInvocation" :mockFutureAction];

	[_testProxy setCallbackOb:mockCallbackOb];
	_testProxy.resultProcessObject = mockResultAction;
	
	[[mockCallbackOb expect] _callBackForASync:_testProxy];
	[_testProxy fire];
	
	[mockCallbackOb verify];
	[mockResultAction verify];
	[mockFutureAction verify];
	[mockFutureActionMethodSig verify];
	
	[swapIn1 putBackOriginal];
}

@end
