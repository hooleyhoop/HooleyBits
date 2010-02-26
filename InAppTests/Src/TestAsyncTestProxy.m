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
	[_testProxy setCallbackOb:mockCallbackOb];
	_testProxy.resultProcessObject = mockResultAction;
	
	[[mockCallbackOb expect] _callBackForASync:_testProxy];
	[_testProxy fire];
}

@end
