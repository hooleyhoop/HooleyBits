//
//  TestHelp.m
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "TestHelp.h"
#import "GUITestProxy.h"
#import "AsyncTests.h"
#import <SHShared/SHShared.h>
#import "NSInvocation_testFutures.h"

#pragma mark -
@implementation TestHelp

@synthesize tests=_tests;

+ (id)makeWithTest:(AsyncTests *)value {
	
	NSParameterAssert(value);
	TestHelp *th = [[[TestHelp alloc] initWithTests:value] autorelease];
	return th;
}

- (id)initWithTests:(AsyncTests *)value {
	
	NSParameterAssert(value);
	self = [super init];
	if(self){
		_tests = value;
		_objectsAwaitingCallbacks = [[NSMutableArray array] retain];
	}
	return self;
}

- (void)dealloc {
	
	NSAssert([_objectsAwaitingCallbacks count]==0, @"Still waiting on some objects to callback?");
	[_objectsAwaitingCallbacks release];
	[super dealloc];
}

- (void)failWithException:(NSException *)anException {
	NSLog(@"%@, %@ - %@",[anException name],[anException reason], [anException userInfo]);
}

#pragma mark OLD - Tests are done in order
- (void)_pushWaitingAsyncTest:(AsyncTestProxy *)someKindOfMagicObject {
	
	NSParameterAssert(someKindOfMagicObject);

	// it retains us
	[someKindOfMagicObject setCallbackOb:self];
	
	// we retain it
	[_objectsAwaitingCallbacks addObject:someKindOfMagicObject];
	
	// -- if queue was empty do this one immediately
	if(1==[_objectsAwaitingCallbacks count]) {
		NSAssert( [_objectsAwaitingCallbacks objectAtIndex:0]==someKindOfMagicObject, @"are you having a laugh?");
		[someKindOfMagicObject fire];
	}
}

- (void)_popWaitingAsyncTest:(AsyncTestProxy *)someKindOfMagicObject {
	
	NSParameterAssert(someKindOfMagicObject);

	[[someKindOfMagicObject retain] autorelease];
	NSAssert( [_objectsAwaitingCallbacks objectAtIndex:0]==someKindOfMagicObject, @"are you having a laugh?");
	NSAssert( [_objectsAwaitingCallbacks indexOfObject:someKindOfMagicObject]==0, @"are you having a laugh?");
	[_objectsAwaitingCallbacks removeObject:someKindOfMagicObject];
	
	// -- do the next queued action
	if([_objectsAwaitingCallbacks count]){
		AsyncTestProxy *next = [_objectsAwaitingCallbacks objectAtIndex:0];
		[next performSelector:@selector(fire) withObject:nil afterDelay:0];
	}
}

#pragma mark OLD - callbacks for async tests on complete
- (void)_callBackForASyncAssertTrue:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {
	
	STAssertTrue(value, msg);
	
//	[(id)inv assertResultOfBlockIsTrue:exprBlock arg1:docCountBlock arg2:[NSNumber numberWithInt:value] msg:@"document count is wourong"];
	
	[self _popWaitingAsyncTest:someKindOfMagicObject];
}

- (void)_callBackForASyncAssertFalse:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {

	STAssertFalse(value, msg);
	[self _popWaitingAsyncTest:someKindOfMagicObject];
}

#pragma mark OLD - USE THESE to do async tests
- (void)aSync:(AsyncTestProxy *)someKindOfMagicObject {
	
	NSParameterAssert(someKindOfMagicObject);
	
	[self _pushWaitingAsyncTest:someKindOfMagicObject];
}

- (void)aSyncAssertTrue:(GUITestProxy *)someKindOfMagicObject :(NSString *)msg {
	
	NSParameterAssert(someKindOfMagicObject);
	NSParameterAssert(msg);
	
	[someKindOfMagicObject setFailMSg:msg];
	[someKindOfMagicObject setFailCondition:true];
	[self _pushWaitingAsyncTest:someKindOfMagicObject];
}

#pragma mark New Stuff
- (void)_startCallbackTimer {
	//TODO: check in that downloaded stuff..
}
- (void)_stopCallbackTimer {
	//TODO: check in that downloaded stuff..
}

- (void)insertResultArg:(id *)result intoInvocation:(NSInvocation *)inv {
	
	NSParameterAssert(*result);
	NSParameterAssert(inv);
	[inv setArgument:result atIndex:2];
}

- (void)_callBackForASync:(AsyncTestProxy *)someKindOfMagicObject {
	
	[self _stopCallbackTimer];
	
	//	-process result
	id result = someKindOfMagicObject.result;
	id resultProcessObject = someKindOfMagicObject.resultProcessObject;
	if( resultProcessObject )
	{
		if(result){
			[self insertResultArg:&result intoInvocation:resultProcessObject];
		}
		[resultProcessObject invoke];
	}
	
	[self _popWaitingAsyncTest:someKindOfMagicObject];
}

#pragma mark New Assertions

- (void)aSyncAssertResultNotNil:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertResultNotNilInvocation:_tests];
	[self _pushWaitingAsyncTest: testProxyFuture];
	[self _startCallbackTimer];
}

- (void)aSyncAssertResultNil:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertResultNilInvocation:_tests];
	[self _pushWaitingAsyncTest: testProxyFuture];
	[self _startCallbackTimer];
}

- (void)aSyncAssertTrue:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	
	// make a block to be executed on callback
	// Dont keep state here - pass the callback object into testProxyFuture for storage
	
	// Build the inv to call whe the callback is reached. this needs to retain inv
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertTrueInvocation:_tests];
	
	//	-queue
	//	-fire
	[self _pushWaitingAsyncTest: testProxyFuture];
	
	[self _startCallbackTimer];
}

- (void)aSyncAssertFalse:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	
	// make a block to be executed on callback
	// Dont keep state here - pass the callback object into testProxyFuture for storage
	
	// Build the inv to call whe the callback is reached. this needs to retain inv
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertFailInvocation:_tests];

	//	-queue
	//	-fire
	[self _pushWaitingAsyncTest: testProxyFuture];
	
	[self _startCallbackTimer];
}

- (void)aSyncAssertEqual:(AsyncTestProxy *)testProxyFuture :(id)someOtherObject {

	NSParameterAssert(testProxyFuture);
	NSParameterAssert(someOtherObject);

	// make a block to be executed on callback
	// Dont keep state here - pass the callback object into testProxyFuture for storage

	// Build the inv to call whe the callback is reached. this needs to retain inv
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertEqualObjectsInvocation:_tests expectedResult:someOtherObject];

	//	-queue
	//	-fire
	[self _pushWaitingAsyncTest:testProxyFuture];

	[self _startCallbackTimer];
}

@end

