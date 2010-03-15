//
//  AsyncTestProxy.m
//  InAppTests
//
//  Created by Steven Hooley on 13/02/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//

#import "AsyncTestProxy.h"
#import "TestHelp.h"


@implementation AsyncTestProxy

@synthesize resultProcessObject =_resultProcessObject;

- (void)dealloc {
	NSAssert(_remoteInvocation==nil, @"This shouldn't happen");
	NSAssert(_callbackOb==nil, @"This shouldn't happen");
	NSAssert(_resultProcessObject==nil, @"This shouldn't happen");

	[super dealloc];
}

#pragma mark ONE OF These must be called when action is finished - i dont care how you do it
- (void)cleanup {
	
	[_callbackOb _callBackForASync:self];
	[_callbackOb release];
	_callbackOb = nil;
	
	[_resultProcessObject release];
	_resultProcessObject = nil;

//	[_resultMessage release];
//	_resultMessage = nil;
}

- (void)nextRunloopCycle_fire {
	[self performSelector:@selector(fire) withObject:nil afterDelay:0];
}

- (void)fire {
	
	//-- addObserver
//	if(_recievesAsyncCallback)
//		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotifiedBack:) name:@"hooley_distrbuted_notification_callback" object:nil];
	
	if(_remoteInvocation)
	{
		[_remoteInvocation invoke];
		[_remoteInvocation release];
		_remoteInvocation = nil;
	} else {
//		NSAssert(_boolExpressionBlock, @"must have a block if we dont have an invocation?");
		// so we got a result - know what?
//		_blockResult = [_boolExpressionBlock value];
	}
	// calls callback
//	if(!_recievesAsyncCallback)
		[self cleanup];
}

- (void)setCallbackOb:(TestHelp *)val {
	_callbackOb = [val retain];
}

- (id)result {
	return nil;
}

@end
