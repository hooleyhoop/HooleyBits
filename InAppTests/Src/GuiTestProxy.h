//
//  GuiTestProxy.h
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "AsyncTestProxy.h"

// @class TestHelp, AsyncTests, FSBlock;

#pragma mark -
@interface GUITestProxy : AsyncTestProxy {
	
//	NSString	*_resultMessage;
//	BOOL		_failCondition;
}

// @property (retain, readwrite) NSObject *blockResult;
+ (GUITestProxy *)lockTestRunner;
+ (GUITestProxy *)unlockTestRunner;

+ (GUITestProxy *)wait;
+ (GUITestProxy *)doTo:(id)object selector:(SEL)method;
+ (GUITestProxy *)openMainMenuItem:(NSString *)menuName;
+ (GUITestProxy *)statusOfMenuItem:(NSString *)val1 ofMenu:(NSString *)val2;
+ (GUITestProxy *)doMenu:(NSString *)val1 item:(NSString *)val2;
+ (GUITestProxy *)documentCountIs:(NSUInteger)intValue;

//- (void)setFailMSg:(NSString *)msg;
//- (void)setFailCondition:(BOOL)value;
//- (void)cleanup;

@end
