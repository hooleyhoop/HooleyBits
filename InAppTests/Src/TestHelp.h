//
//  TestHelp.h
//  InAppTests
//
//  Created by steve hooley on 08/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import <SHShared/SHooleyObject.h>

@class GUITestProxy, AsyncTests, AsyncTestProxy;
#pragma mark -
@interface TestHelp : SHooleyObject {

	NSMutableArray	*_objectsAwaitingCallbacks;
	AsyncTests		*_tests;
}

@property (readonly) AsyncTests *tests;

+ (id)makeWithTest:(AsyncTests *)value;
- (id)initWithTests:(AsyncTests *)value;

- (void)_callBackForASync:(AsyncTestProxy *)someKindOfMagicObject;
- (void)_callBackForASyncAssertTrue:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject;
- (void)_callBackForASyncAssertFalse:(BOOL)value msg:(NSString *)msg helper:(AsyncTestProxy *)someKindOfMagicObject;

- (void)aSync:(AsyncTestProxy *)someKindOfMagicObject;
- (void)aSyncAssertTrue:(AsyncTestProxy *)someKindOfMagicObject :(NSString *)msg;
- (void)aSyncAssertFalse:(AsyncTestProxy *)someKindOfMagicObject :(NSString *)msg;

#pragma mark New Stuff
- (NSInvocation *)_assertEqualObjectsInvocationWithDefferedResultProxy:(AsyncTestProxy *)notUsed expectedResult:(id)ob2;
- (void)aSyncAssertEqual:(AsyncTestProxy *)testProxy :(id)someOtherObject;

@end
