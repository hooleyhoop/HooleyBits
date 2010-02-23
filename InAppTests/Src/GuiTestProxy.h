//
//  GuiTestProxy.h
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "AsyncTestProxy.h"

@class TestHelp, AsyncTests, FSBlock;

#pragma mark -
@interface GUITestProxy : AsyncTestProxy {
	
	NSString *_debugName;
	NSString *_resultMessage;
	BOOL _failCondition;
	BOOL _recievesAsyncCallback;
	
	// oh no where is this going?
	FSBlock *_boolExpressionBlock;
	NSObject *_blockResult;
}

@property (retain, readwrite) NSObject *blockResult;

+ (GUITestProxy *)wait;
+ (GUITestProxy *)doTo:(id)object selector:(SEL)method;
+ (GUITestProxy *)unlockTestRunner;
+ (GUITestProxy *)openMainMenuItem:(NSString *)menuName;
+ (GUITestProxy *)statusOfMenuItem:(NSString *)val1 ofMenu:(NSString *)val2;
+ (GUITestProxy *)doMenu:(NSString *)val1 item:(NSString *)val2;
+ (GUITestProxy *)assertDocumentCountIs:(NSUInteger)value;

- (void)setFailMSg:(NSString *)msg;
- (void)setFailCondition:(BOOL)value;

- (void)cleanup;

@end
