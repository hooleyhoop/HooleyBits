//
//  GuiTestProxy.m
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "GuiTestProxy.h"
#import "DelayedPerformer.h"
#import <SHShared/NSInvocation(ForwardedConstruction).h>
#import "FScript/FScript.h"

@implementation GUITestProxy
#pragma mark The Useful stuff

+ (GUITestProxy *)wait {

	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy.debugName = @"wait";
	
	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
	[[NSInvocation makeRetainedInvocationWithTarget:aRemoteTestProxy
	invocationOut: &(aRemoteTestProxy->_remoteInvocation)] 
	 wait];
	
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* _waitTimerFire */
	aRemoteTestProxy.recievesAsyncCallback = YES;

	return [aRemoteTestProxy autorelease];
}

// Fire a selector on an instance
+ (GUITestProxy *)doTo:(id)object selector:(SEL)method {
	
	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy->_debugName = @"doto";
	
	NSInvocation *inv = [NSInvocation makeRetainedInvocationWithTarget:object 
													 invocationOut:&(aRemoteTestProxy->_remoteInvocation)];
	objc_msgSend(inv,method,nil);
	[aRemoteTestProxy->_remoteInvocation retain];
	return [aRemoteTestProxy autorelease];
}

//// we lock directly, brut of course need to unlock asyncronously when all queued methods have finished
//+ (GUITestProxy *)unlockTestRunner {
//	
//	GUITestProxy *aRemoteTestProxy = [[[GUITestProxy alloc] init] autorelease];
//	aRemoteTestProxy->_debugName = @"unlockTestRunner";
//	
//	/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
//	[[NSInvocation makeRetainedInvocationWithTarget: [RunTests class] 
//								  invocationOut:&(aRemoteTestProxy->_remoteInvocation)] unlock:aRemoteTestProxy callback:@selector(cleanup)];
//	[aRemoteTestProxy->_remoteInvocation retain];
//		
//	// When this is added to the queue it's callbackObject will be set
//	// When the action has been process -_callBackForASync MUST be called on the _callbackOb to pop it off the queue
//	//	[_callbackOb _callBackForASync:self];
//	//	[_callbackOb release];
//	//	_callbackOb = nil;
//	
//	return aRemoteTestProxy;
//}
- (void)_setUpDistributedNotificationStuff {
	
	self.preAction = _BLOCK(@"[:arg1 | (NSDistributedNotificationCenter defaultCenter) addObserver:arg1 selector:#getNotifiedBack: name:'hooley_distrbuted_notification_callback' object:nil]");
	self.postAction = _BLOCK(@"[:arg1 | (NSDistributedNotificationCenter defaultCenter) removeObserver:arg1 name:'hooley_distrbuted_notification_callback' object:nil]");
	
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
	[[NSInvocation makeRetainedInvocationWithTarget: [NSDistributedNotificationCenter defaultCenter]
	invocationOut:&(aRemoteTestProxy->_remoteInvocation)] 
	 postNotificationName:@"hooley_distrbuted_notification"
	 object:@"openMenuItem"
	 userInfo:dict
	 deliverImmediately:NO
	 ];
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* IPC callback - Every async action must have a callback */
	aRemoteTestProxy->_recievesAsyncCallback = YES;

	[aRemoteTestProxy _setUpDistributedNotificationStuff];

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
	[[NSInvocation makeRetainedInvocationWithTarget:
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
	
	[aRemoteTestProxy _setUpDistributedNotificationStuff];

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
	[[NSInvocation makeRetainedInvocationWithTarget: [NSDistributedNotificationCenter defaultCenter] 
	invocationOut:&(aRemoteTestProxy->_remoteInvocation)] 
	 postNotificationName:@"hooley_distrbuted_notification"
	 object:@"doMenuItem"
	 userInfo:dict
	 deliverImmediately:NO
	 ];
	[aRemoteTestProxy->_remoteInvocation retain];
	
	/* IPC callback - Every async action must have a callback */
	aRemoteTestProxy->_recievesAsyncCallback = YES;
	
	[aRemoteTestProxy _setUpDistributedNotificationStuff];

	return aRemoteTestProxy;
}

// set up a delayed action
// fire will be called on this
+ (GUITestProxy *)documentCountIs:(NSUInteger)intValue {

	GUITestProxy *aRemoteTestProxy = [[GUITestProxy alloc] init];
	aRemoteTestProxy.debugName = @"assert Document Count Is";
	
	// As this doesnt need to capture any arguments i am going to use the FScript block instead of the invocation
	NSString *exprString = [NSString stringWithFormat:@"[(((NSDocumentController sharedDocumentController) documents) count) isEqualToNumber: (NSNumber numberWithInt: %i)]", intValue];
	FSBlock *exprBlock = _BLOCK(exprString);

	aRemoteTestProxy.boolExpressionBlock = exprBlock;
	return [aRemoteTestProxy autorelease];
}


#pragma mark -

//- (void)setFailMSg:(NSString *)msg {
//	_resultMessage = [msg retain];
//}
//- (void)setFailCondition:(BOOL)value {
//	_failCondition = value;
//}

#pragma mark Hmm
- (void)_waitTimerFire:(id)value {

	[self cleanup]; // clean up calls our callback, der..
}

- (void)wait {
	
	[DelayedPerformer delayedCallSelector:@selector(_waitTimerFire:) onObject:self withArg:nil afterDelay:0.3f];
}

- (oneway void)getNotifiedBack:(NSNotification *)eh {
	
	NSAssert(_callbackOb, @"Need a callback ob");
	NSAssert(_recievesAsyncCallback, @"Needs to be _recievesAsyncCallback");

	NSDictionary *dict = [eh userInfo];
	if( [[eh object] isEqualToString:@"statusOfMenuItem_callback"] )
	{
		NSString *resultStringValue = [dict valueForKey:@"resultValue"];
		BOOL result = NO;
		if(resultStringValue)
			result = [resultStringValue boolValue];
		_blockResult = result ? [FSBoolean fsTrue] : [FSBoolean fsFalse];
		
		// -- call callback with result and message
//		if(_failCondition)
//			[_callbackOb _callBackForASyncAssertTrue:result msg:_resultMessage helper:self];
//		else
//			[_callbackOb _callBackForASyncAssertFalse:result msg:_resultMessage helper:self];

	} else if( [[eh object] isEqualToString:@"openMenuItem_callback"] ) {
		
		// -- call callback with result and message
//		[_callbackOb _callBackForASync:self];
//
	} else if( [[eh object] isEqualToString:@"doMenuItem_callback"] ) {

//		// -- call callback with result and message
//		[_callbackOb _callBackForASync:self];
//	
	} else {
		[NSException raise:@"unknown IPC callback" format:@"%@", [eh object] ];
	}
	
//	[_resultMessage release];
//	_resultMessage = nil;
//	[_callbackOb release];
//	_callbackOb = nil;
	
		
	[self cleanup];
}

@end

