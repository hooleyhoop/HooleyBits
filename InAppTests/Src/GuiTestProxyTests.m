//
//  GuitestProxyTests.m
//  InAppTests
//
//  Created by Steven Hooley on 15/03/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//

#import "GUITestProxy.h"
#import "DelayedPerformer.h"

@interface GuiTestProxyTests : SenTestCase {
	
}

@end

@implementation GuiTestProxyTests

// move to subclass? when working
//[RunTests lock];
//[_testHelper aSync:[GUITestProxy unlockTestRunner]];

// Better form of expectation?
//	[expectThat(app.alertView) should].exist;
//	[[app view:@"UIThreePartButton"] touch];
//	[expect that:mockTP equals:@"steven"]


- (void)_callBackForASync:(AsyncTestProxy *)futureProxy {
	
	FSBoolean *result = [futureProxy result];
	STAssertTrue( [result isEqual:[FSBoolean fsTrue]], nil);
}

- (void)test_documentCountIs {
	// + (GUITestProxy *)documentCountIs:(NSUInteger)intValue;

	GUITestProxy *futureProxy = [GUITestProxy documentCountIs:0];
	[futureProxy setCallbackOb:(id)self];
	[futureProxy fire];
}

- (void)test_lockTestRunner {
	//+ (GUITestProxy *)lockTestRunner
	//+ (GUITestProxy *)unlockTestRunner

	GUITestProxy *futureProxy1 = [GUITestProxy lockTestRunner];
	[futureProxy1 fire];
	
	GUITestProxy *futureProxy2 = [GUITestProxy unlockTestRunner];
	[futureProxy2 fire];
}

//+ (void)cuntDroppings {
//	NSLog(@"Hello");
//}
//
//+ (id)forwardingTargetForSelector:(SEL)aSelector {
//	return @"twat";
//}
//
//+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//
//	NSMethodSignature *methodSig = [super methodSignatureForSelector:aSelector];
//	if(!methodSig)
//		methodSig = [self methodSignatureForSelector:@selector(cuntDroppings)];
//	return methodSig;
//}
//+ (void)forwardInvocation:(NSInvocation *)anInvocation {
//
//	NSLog(@"oh really?");
//}

- (void)test_wait {

//	GUITestProxy *futureProxy = [GUITestProxy wait];
//	[futureProxy setCallbackOb:(id)self];
//	
//	OCMockObject *mockDelayedAction = MOCK([[DelayedPerformer class] class]);
//	
//	[GuiTestProxyTests hello];
//	
//	[[mockDelayedAction expect] hello];
//	[[mockDelayedAction expect] delayedCallSelector:@selector(_waitTimerFire:) onObject:futureProxy withArg:nil afterDelay:0.3f];
//
//	[futureProxy fire];
//	
//	[mockDelayedAction verify];
//	
//	// This has now scheduled a callback and clean on't be called untill it fires…
//	[futureProxy cleanup];
}

- (void)test_doMenu_item {
//	[GUITestProxy doMenu:@"File" item:@"New"];
}

- (void)test_statusOfMenuItem {
	// [GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"];
}
- (void)test_openMainMenuItem {
	// [GUITestProxy openMainMenuItem:@"File"];
}
- (void)test_doToSelector {
	// [GUITestProxy doTo:self selector:@selector(_callBackForASync:)];
}

// [_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];
// [_testHelper aSync:[GUITestProxy wait]]; // not viable to test!
//[_testHelper aSyncAssertTrue:[GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"] :@"Menu item -New- should be enabled"];
//[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
//	[_testHelper aSync:[GUITestProxy openMainMenuItem:@"File"]];
//	[_testHelper aSync:[GUITestProxy doTo:self selector:@selector(_testShit)]];

//	[_testHelper aSync:[GUITestProxy closeMainMenuItem:@"File"]];
//	[_testHelper aSync:[GUITestProxy selectItems2And3]];
//	[_testHelper aSync:[GUITestProxy dropFileOnTableView]];

@end
