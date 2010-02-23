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

#pragma mark Tests are done in order
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

#pragma mark callbacks for async tests on complete
- (void)_callBackForASyncAssertTrue:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {
	
	STAssertTrue(value, msg);
	
//	[(id)inv assertResultOfBlockIsTrue:exprBlock arg1:docCountBlock arg2:[NSNumber numberWithInt:value] msg:@"document count is wourong"];
	
	[self _popWaitingAsyncTest:someKindOfMagicObject];
}

- (void)_callBackForASyncAssertFalse:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject {

	STAssertFalse(value, msg);
	[self _popWaitingAsyncTest:someKindOfMagicObject];
}

#pragma mark USE THESE to do async tests
- (void)aSync:(AsyncTestProxy *)someKindOfMagicObject {
	
	NSParameterAssert(someKindOfMagicObject);
	
	[self _pushWaitingAsyncTest:someKindOfMagicObject];
}

- (void)aSyncAssertTrue:(AsyncTestProxy *)someKindOfMagicObject :(NSString *)msg {
	
	NSParameterAssert(someKindOfMagicObject);
	NSParameterAssert(msg);
	
	[someKindOfMagicObject setFailMSg:msg];
	[someKindOfMagicObject setFailCondition:true];
	[self _pushWaitingAsyncTest:someKindOfMagicObject];
}

- (void)aSyncAssertFalse:(AsyncTestProxy *)someKindOfMagicObject :(NSString *)msg {

	NSParameterAssert(someKindOfMagicObject);
	NSParameterAssert(msg);
	
	[someKindOfMagicObject setFailMSg:msg];
	[someKindOfMagicObject setFailCondition:false];
	[self _pushWaitingAsyncTest:someKindOfMagicObject];
}

#pragma mark New Stuff
- (void)_startCallbackTimer {
	
}
- (void)_stopCallbackTimer {
	
}

- (void)aSyncAssertEqual:(AsyncTestProxy *)testProxy :(id)someOtherObject {

	//	-waitForCallback
	// make a block to be executed on callback
	// Dont keep state here - pass the callback object into testProxy for storage
//	FSBlock *exprBlock = _BLOCK(@"[:blockArg1 :arg1 | (blockArg1 value) isEqualTo: arg1]");
//	FSBlock *callbackBlock  = _BLOCK(@"[[:arg1 :arg2 | assertResultOfBlockIsTrue: blk1 arg1: arg2: msg: ");

	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	NSInvocation *callbackInvocation;
	[[NSInvocation makeRetainedInvocationWithTarget:_tests invocationOut:&callbackInvocation]	 
	 assertResultOfBlockIsTrue:@""
	 arg1:@""
	 arg2:@""
	 msg:@"oop"
	 ];
	
	// this needs to retain inv
	testProxy.resultProcessObject = callbackInvocation;

	//	-queue
	//	-fire
	[self _pushWaitingAsyncTest:testProxy];

	[self _startCallbackTimer];
}

- (void)_callBackForASync:(AsyncTestProxy *)someKindOfMagicObject {

	[self _stopCallbackTimer];

	//	-process result
	id result = someKindOfMagicObject.result;
	id resultProcessObject = someKindOfMagicObject.resultProcessObject;
	[resultProcessObject invoke];

	[self _popWaitingAsyncTest:someKindOfMagicObject];
}


@end

