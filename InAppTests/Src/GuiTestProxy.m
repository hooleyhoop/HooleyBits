//
//  GuiTestProxy.m
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "GuiTestProxy.h"
#import "RunTests.h"
#import <SHShared/NSInvocation(ForwardedConstruction).h>
#import "TestHelp.h"
#import <FScript/Fscript.h>
#import "AsyncTests.h"

@implementation GUITestProxy
#pragma mark The Useful stuff

@synthesize blockResult = _blockResult;

+ (GUITestProxy *)wait {

	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy->_debugName = @"wait";
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation newRetainedInvocationWithTarget:aRemoteTestProxy
	invocationOut: &(aRemoteTestProxy->_remoteInvocation)] 
	 wait];
	
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* _waitTimerFire */
	aRemoteTestProxy->_recievesAsyncCallback = YES;

	return [aRemoteTestProxy autorelease];
}

// Fire a selector on an instance
+ (GUITestProxy *)doTo:(id)object selector:(SEL)method {
	
	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy->_debugName = @"doto";
	
	NSInvocation *inv = [NSInvocation newRetainedInvocationWithTarget:object 
													 invocationOut:&(aRemoteTestProxy->_remoteInvocation)];
	objc_msgSend(inv,method,nil);
	[aRemoteTestProxy->_remoteInvocation retain];
	return [aRemoteTestProxy autorelease];
}

// we lock directly, brut of course need to unlock asyncronously when all queued methods have finished
+ (GUITestProxy *)unlockTestRunner {
	
	GUITestProxy *aRemoteTestProxy = [[[GUITestProxy alloc] init] autorelease];
	aRemoteTestProxy->_debugName = @"unlockTestRunner";
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation newRetainedInvocationWithTarget: [RunTests class] 
								  invocationOut:&(aRemoteTestProxy->_remoteInvocation)] unlock:aRemoteTestProxy callback:@selector(cleanup)];
	[aRemoteTestProxy->_remoteInvocation retain];
		
	// When this is added to the queue it's callbackObject will be set
	// When the action has been process -_callBackForASync MUST be called on the _callbackOb to pop it off the queue
	//	[_callbackOb _callBackForASync:self];
	//	[_callbackOb release];
	//	_callbackOb = nil;
	
	return aRemoteTestProxy;
}

+ (GUITestProxy *)openMainMenuItem:(NSString *)menuName {
	
	GUITestProxy *aRemoteTestProxy = [[[GUITestProxy alloc] init] autorelease];
	aRemoteTestProxy->_debugName = @"openMainMenuItem";

	/* User info to pass to remote process */
	NSString *currentAppName = [[NSProcessInfo processInfo] processName];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 currentAppName, @"ProcessName",
								 menuName, @"MenuName",
								 nil];
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation newRetainedInvocationWithTarget: [NSDistributedNotificationCenter defaultCenter]
	invocationOut:&(aRemoteTestProxy->_remoteInvocation)] 
	 postNotificationName:@"hooley_distrbuted_notification"
	 object:@"openMenuItem"
	 userInfo:dict
	 deliverImmediately:NO
	 ];
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* IPC callback - Every async action must have a callback */
	aRemoteTestProxy->_recievesAsyncCallback = YES;	
	return aRemoteTestProxy;
}

+ (GUITestProxy *)statusOfMenuItem:(NSString *)val1 ofMenu:(NSString *)val2 {
	
	GUITestProxy *aRemoteTestProxy = [[[GUITestProxy alloc] init] autorelease];
	aRemoteTestProxy->_debugName = @"status of menu item";
	
	/* User info to pass to remote process */
	NSString *currentAppName = [[NSProcessInfo processInfo] processName];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 currentAppName, @"ProcessName",
								 val2, @"MenuName",
								 val1, @"MenuItemName",
								 nil];
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation newRetainedInvocationWithTarget:
	  [NSDistributedNotificationCenter defaultCenter] invocationOut:
	  &(aRemoteTestProxy->_remoteInvocation)] 
	 postNotificationName:@"hooley_distrbuted_notification"
	 object:@"statusOfMenuItem"
	 userInfo:dict
	 deliverImmediately:NO
	 ];
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* IPC callback */
	aRemoteTestProxy->_recievesAsyncCallback = YES;
	
	return aRemoteTestProxy;
}

+ (GUITestProxy *)doMenu:(NSString *)val1 item:(NSString *)val2 {
	
	GUITestProxy *aRemoteTestProxy = [[[GUITestProxy alloc] init] autorelease];
	aRemoteTestProxy->_debugName = @"do menu";
	
	/* User info to pass to remote process */
	NSString *currentAppName = [[NSProcessInfo processInfo] processName];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 currentAppName, @"ProcessName",
								 val1, @"MenuName",
								 val2, @"MenuItemName",
								 nil];
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation newRetainedInvocationWithTarget: [NSDistributedNotificationCenter defaultCenter] 
	invocationOut:&(aRemoteTestProxy->_remoteInvocation)] 
	 postNotificationName:@"hooley_distrbuted_notification"
	 object:@"doMenuItem"
	 userInfo:dict
	 deliverImmediately:NO
	 ];
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* IPC callback - Every async action must have a callback */
	aRemoteTestProxy->_recievesAsyncCallback = YES;
	
	return aRemoteTestProxy;
}

+ (GUITestProxy *)assertDocumentCountIs:(NSUInteger)value {
	//
//	-- make block to do document count
//	-- result(number) = block value
		
		
	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy->_debugName = @"assert Document Count Is";
	
	NSInvocation *inv;
//	inv = [NSInvocation newRetainedInvocationWithTarget:testCase
//						invocationOut:&(aRemoteTestProxy->_remoteInvocation)];	

	/* FScript reference */
	FSBlock *docCountBlock = _BLOCK(@"[((NSDocumentController sharedDocumentController) documents) count]");
	FSBlock *exprBlock = _BLOCK(@"[:block1 :arg1 | (block1 value) isEqualTo: arg1]");
	[(id)inv assertResultOfBlockIsTrue:exprBlock arg1:docCountBlock arg2:[NSNumber numberWithInt:value] msg:@"document count is wourong"];
	
	[aRemoteTestProxy->_remoteInvocation retain];
	return [aRemoteTestProxy autorelease];
}


#pragma mark -
- (void)dealloc {
	
	NSAssert(_resultMessage==nil, @"This shouldn't happen");
	
	self.blockResult = nil;

	[super dealloc];
}

- (void)setFailMSg:(NSString *)msg {
	_resultMessage = [msg retain];
}
- (void)setFailCondition:(BOOL)value {
	_failCondition = value;
}
//
//- (void)fire {
//
//	//-- addObserver
//	if(_recievesAsyncCallback)
//		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotifiedBack:) name:@"hooley_distrbuted_notification_callback" object:nil];
//
//	if(_remoteInvocation)
//	{
//		[_remoteInvocation invoke];
//		[_remoteInvocation release];
//		_remoteInvocation = nil;
//	} else {
//		NSAssert(_boolExpressionBlock, @"must have a block if we dont have an invocation?");
//		// so we got a result - know what?
//		_blockResult = [_boolExpressionBlock value];
//	}
//	// calls callback
//	if(!_recievesAsyncCallback)
//		[self cleanup];
//}

#pragma mark Hmm
- (void)_waitTimerFire:(id)value {
	[self cleanup];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"hooley_distrbuted_notification_callback" object:nil];
}
- (void)wait {
	[self performSelector:@selector(_waitTimerFire:) withObject:nil afterDelay:0.3];
}

//#pragma mark ONE OF These must be called when action is finished - i dont care how you do it
//- (void)cleanup {
//	
//	[_callbackOb _callBackForASync:self];
//	[_callbackOb release];
//	_callbackOb = nil;
//	[_resultMessage release];
//	_resultMessage = nil;
//}

- (oneway void)getNotifiedBack:(NSNotification *)eh {
	
	NSAssert(_callbackOb, @"Need a callback ob");
	NSAssert(_recievesAsyncCallback, @"Needs to be _recievesAsyncCallback");

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"hooley_distrbuted_notification_callback" object:nil];
	NSDictionary *dict = [eh userInfo];

	if( [[eh object] isEqualToString:@"statusOfMenuItem_callback"] )
	{
		NSString *resultStringValue = [dict valueForKey:@"resultValue"];
		BOOL result = NO;
		if(resultStringValue)
			result = [resultStringValue boolValue];
		
		// -- call callback with result and message
		if(_failCondition)
			[_callbackOb _callBackForASyncAssertTrue:result msg:_resultMessage helper:self];
		else
			[_callbackOb _callBackForASyncAssertFalse:result msg:_resultMessage helper:self];

	} else if( [[eh object] isEqualToString:@"openMenuItem_callback"] ) {
		
		// -- call callback with result and message
		[_callbackOb _callBackForASync:self];

	} else if( [[eh object] isEqualToString:@"doMenuItem_callback"] ) {

		// -- call callback with result and message
		[_callbackOb _callBackForASync:self];
	
	} else {
		[NSException raise:@"unknown IPC callback" format:@"%@", [eh object] ];
	}
	
	[_resultMessage release];
	_resultMessage = nil;
	[_callbackOb release];
	_callbackOb = nil;
}

@end

