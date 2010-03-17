//
//  GuitestProxyTests.m
//  InAppTests
//
//  Created by Steven Hooley on 15/03/2010.
//  Copyright 2010 BestBefore. All rights reserved.
//

#import "GUITestProxy.h"

@interface GuiTestProxyTests : SenTestCase {
	
}

@end

@implementation GuiTestProxyTests

// move to subclass? when working
//[RunTests lock];
//[_testHelper aSync:[GUITestProxy unlockTestRunner]];

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

- (void)test_wait {

	GUITestProxy *futureProxy = [GUITestProxy wait];
	[futureProxy setCallbackOb:(id)self];
	[futureProxy fire];
}

// [_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];
// [_testHelper aSync:[GUITestProxy wait]];

//[_testHelper aSyncAssertTrue:[GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"] :@"Menu item -New- should be enabled"];
//[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
//	[_testHelper aSync:[GUITestProxy openMainMenuItem:@"File"]];
//	[_testHelper aSync:[GUITestProxy closeMainMenuItem:@"File"]];
//	[_testHelper aSync:[GUITestProxy selectItems2And3]];
//	[_testHelper aSync:[GUITestProxy dropFileOnTableView]];
//	[_testHelper aSync:[GUITestProxy doTo:self selector:@selector(_testShit)]];

@end
