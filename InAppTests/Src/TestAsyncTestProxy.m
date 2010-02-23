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
#import <SHTestUtilities/SHTestUtilities.h>
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

@interface TestAsyncTestProxy : SenTestCase {
	
	AsyncTestProxy *_testProxy;
}

@end

@implementation TestAsyncTestProxy

- (void)setUp {
	_testProxy = [[AsyncTestProxy alloc] init];
}

- (void)tearDown {
	[_testProxy release];
}

- (void)testFire {
	
	id mockCallbackOb = MOCK(TestHelp);
	id mockResultAction = MOCK(NSInvocation);
	[_testProxy setCallbackOb:mockCallbackOb];
	_testProxy.resultProcessObject = mockResultAction;
	
	[_testProxy fire];
}

@end
