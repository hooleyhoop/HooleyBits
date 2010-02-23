//
//  RunTests.h
//  InAppTests
//
//  Created by Steven Hooley on 06/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class SenTestSuiteRun;

@interface RunTests : NSObject {

	NSTimer							*_timer;
	
	NSMutableArray					*_queuedActions;
	
	id								_arg_placeHolder;
	id								_previousResult;
	
	NSTask							*_task;
	
	SenTestSuiteRun					*testSuiteRun;
	BOOL							_actionInProgress;
	
	id _var1, _var2;
}

@property (retain, readwrite, nonatomic) id var1;
@property (retain, readwrite, nonatomic) id var2;

+ (void)lock;
+ (void)unlock:(id)callee callback:(SEL)method;
//+ (void)addException:(NSException *)anException;

- (void)pushAction:(id)value;

@end
