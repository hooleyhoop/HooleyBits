//
//  AsyncTestProxy.h
//  InAppTests
//
//  Created by Steven Hooley on 13/02/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//
#import <SHShared/SHooleyObject.h>

@class TestHelp, FSBlock;
@interface AsyncTestProxy : SHooleyObject {

	NSString		*_debugName;	// can be used to track which action we are doing

	// we use one or the other
	NSInvocation	*_remoteInvocation;
	FSBlock			*_boolExpressionBlock, *_preAction, *_postAction;

	TestHelp		*_callbackOb;
	NSInvocation	*_resultProcessObject;
	
	NSObject		*_blockResult;
	
	BOOL			_recievesAsyncCallback;
}

// encapsulates an action that the caller needs to do when we have called it back
// (it is nothing to do with us, we are just saving state fr the test)
@property (retain, readwrite) NSInvocation *resultProcessObject;
@property (retain, readwrite) NSString *debugName;
@property (retain, readwrite) FSBlock *boolExpressionBlock, *preAction, *postAction;
@property (readwrite) BOOL recievesAsyncCallback;

- (void)nextRunloopCycle_fire;
- (void)fire;

- (void)setCallbackOb:(TestHelp *)val;
- (id)result;

- (void)cleanup;

@end
