//
//  AsyncTestProxy.h
//  InAppTests
//
//  Created by Steven Hooley on 13/02/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//
#import <SHShared/SHooleyObject.h>

@class TestHelp;
@interface AsyncTestProxy : SHooleyObject {

	NSInvocation	*_remoteInvocation;

	TestHelp		*_callbackOb;
	NSInvocation	*_resultProcessObject;
}

// encapsulates an action that the caller needs to do when we have called it back
// (it is nothing to do with us, we are just saving state fr the test)
@property (retain, readwrite) NSInvocation *resultProcessObject;

- (void)fire;

- (void)setCallbackOb:(TestHelp *)val;
- (id)result;

@end
