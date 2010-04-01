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

@interface TestHelp() 
- (void)_doNextAction;
- (void)_startCallbackTimer:(NSString *)debugLabel;
- (void)_stopCallbackTimer;
@end

#pragma mark -
@implementation TestHelp

@synthesize tests=_tests;
@synthesize callbackTimer=_callbackTimer;

+ (NSTimer *)makeCallbackTimer:(TestHelp *)targetArg debugInfo:(NSString *)arg {

	NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:targetArg selector:@selector(_callbackTimeout:) userInfo:arg repeats:NO];
	return newTimer;
}

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
- (void)_doNextAction {
	
	AsyncTestProxy *next = [_objectsAwaitingCallbacks objectAtIndex:0];
	[self _startCallbackTimer:next.debugName];	
	[next nextRunloopCycle_fire];
}

- (void)_pushWaitingAsyncTest:(AsyncTestProxy *)someKindOfMagicObject {
	
	NSParameterAssert(someKindOfMagicObject);

	// it retains us
	[someKindOfMagicObject setCallbackOb:self];
	
	// we retain it
	[_objectsAwaitingCallbacks addObject:someKindOfMagicObject];
	
	// -- if queue was empty do this one immediately
	if( 1==[_objectsAwaitingCallbacks count] ) {
		[self _doNextAction];
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
		[self _doNextAction];
	}
}

#pragma mark OLD - callbacks for async tests on complete
//- (void)_callBackForASyncAssertTrue:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {
//	
//	STAssertTrue(value, msg);
//	
////	[(id)inv assertResultOfBlockIsTrue:exprBlock arg1:docCountBlock arg2:[NSNumber numberWithInt:value] msg:@"document count is wourong"];
//	
//	[self _popWaitingAsyncTest:someKindOfMagicObject];
//}
//
//- (void)_callBackForASyncAssertFalse:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {
//
//	STAssertFalse(value, msg);
//	[self _popWaitingAsyncTest:someKindOfMagicObject];
//}

#pragma mark OLD - USE THESE to do async tests


//- (void)aSyncAssertTrue:(GUITestProxy *)someKindOfMagicObject :(NSString *)msg {
//	
//	NSParameterAssert(someKindOfMagicObject);
//	NSParameterAssert(msg);
//	
//	[someKindOfMagicObject setFailMSg:msg];
//	[someKindOfMagicObject setFailCondition:true];
//	[self _pushWaitingAsyncTest:someKindOfMagicObject];
//}

#pragma mark New Stuff
- (void)_startCallbackTimer:(NSString *)debugLabel {
	NSAssert(!_callbackTimer, @"gone wrong dickhead");
	self.callbackTimer = [TestHelp makeCallbackTimer:self debugInfo:debugLabel];
}

- (void)_stopCallbackTimer {

	[_callbackTimer invalidate];
	self.callbackTimer = nil;
}

- (void)_callbackTimeout:(NSTimer *)arg {
	[NSException raise:@"Unrecoverable Timeout" format:@"I was trying to do.. %@", [arg userInfo]];
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
- (void)aSync:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	[self _pushWaitingAsyncTest:testProxyFuture];
}

- (void)aSyncAssertResultNotNil:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertResultNotNilInvocation:_tests];
	[self _pushWaitingAsyncTest: testProxyFuture];
}

- (void)aSyncAssertResultNil:(AsyncTestProxy *)testProxyFuture {
	
	NSParameterAssert(testProxyFuture);
	testProxyFuture.resultProcessObject = [NSInvocation_testFutures _assertResultNilInvocation:_tests];
	[self _pushWaitingAsyncTest: testProxyFuture];
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
}

@end

