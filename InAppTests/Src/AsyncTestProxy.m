//
//  AsyncTestProxy.m
//  InAppTests
//
//  Created by Steven Hooley on 13/02/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//

#import "AsyncTestProxy.h"
#import "TestHelp.h"
#import "FScript/FScript.h"


@implementation AsyncTestProxy

@synthesize resultProcessObject =_resultProcessObject;
@synthesize debugName=_debugName;
@synthesize boolExpressionBlock=_boolExpressionBlock, preAction=_preAction, postAction=_postAction;
@synthesize  recievesAsyncCallback = _recievesAsyncCallback;

- (void)dealloc {

	NSAssert(_remoteInvocation==nil, @"This shouldn't happen");
	NSAssert(_callbackOb==nil, @"This shouldn't happen");
	NSAssert(_resultProcessObject==nil, @"This shouldn't happen");

	[super dealloc];
}

#pragma mark ONE OF These must be called when action is finished - i dont care how you do it
- (void)cleanup {
	
	NSAssert(_boolExpressionBlock==nil, @"doh");
	NSAssert(_remoteInvocation==nil, @"doh");

	// -- do post action
	[_postAction value:self];
	[_postAction release];
	[_preAction release];

	[_callbackOb _callBackForASync:self];
	[_callbackOb release];
	_callbackOb = nil;
	
	[_resultProcessObject release];
	_resultProcessObject = nil;

	[_blockResult release];
	_blockResult = nil;

	[_debugName release];
	_debugName = nil;

//	[_resultMessage release];
//	_resultMessage = nil;
}

- (void)nextRunloopCycle_fire {
	[self performSelector:@selector(fire) withObject:nil afterDelay:0];
}

- (void)fire {
	
	[_preAction value:self];
	
	if(_remoteInvocation)
	{
		[_remoteInvocation invoke];
		if( [[_remoteInvocation methodSignature] methodReturnLength] ) {
			[_remoteInvocation getReturnValue:&_blockResult];
			[_blockResult retain];
		}
		[_remoteInvocation release];
		_remoteInvocation = nil;
	} else {
		NSAssert(_boolExpressionBlock, @"must have a block if we dont have an invocation?");
		_blockResult = [_boolExpressionBlock value];
		[_blockResult retain];
		[_boolExpressionBlock release];
		_boolExpressionBlock = nil;
	}
	// calls callback
	if(!_recievesAsyncCallback)
		[self cleanup];
}

- (void)setCallbackOb:(TestHelp *)val {
	_callbackOb = [val retain];
}

- (id)result {
	return _blockResult;
}

@end
