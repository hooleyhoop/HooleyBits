//
//  RunTests.m
//  InAppTests
//
//  Created by Steven Hooley on 06/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RunTests.h"
#import <SenTestingKit/SenTestSuite.h>
#import <SenTestingKit/SenTestSuiteRun.h>
#import <SHShared/NSInvocation(ForwardedConstruction).h>
#import <SHTestUtilities/NSInvocation_testHelpers.h>

static int _psn;
static RunTests *_shared;

#pragma mark -
@interface FF : SHooleyObject {
id _target;
SEL _selector;
NSArray *_args;	
}
@property (retain,readwrite) id target;
@property (readwrite) SEL selector;
@property (retain, readwrite) NSArray *args;
+ (id)target:(id)target selector:(SEL)selector args:(NSArray *)vals;
@end

@implementation FF
@synthesize target=_target, selector=_selector, args=_args;
+ (id)target:(id)target selector:(SEL)selector args:(NSArray *)vals {
	FF *stub = [[[FF alloc] init] autorelease];
	[stub setTarget:target];
	[stub setSelector:selector];
	[stub setArgs:vals];
	return stub;
}

- (void)dealloc {
	[_target release];
	[_args release];
	[super dealloc];
}

- (void)setTarget:(id)value {
	_target = [value retain];
}

- (void)setSelector:(SEL)value {
	_selector = value;
}

- (void)setArgs:(NSArray *)value {
	_args = [value retain];
}

@end

#pragma mark -
@implementation RunTests

@synthesize var1=_var1;
@synthesize var2=_var2;

//+ (RunTests *)shared {
//	return _shared;
//}
//
//+ (void)addException:(NSException *)anException {
//	[[RunTests shared]->_testRun addException:anException];
//}
+ (void)startLockTimer {
	// TODO: implement this!
}

+ (void)cancelLockTimer {
	// TODO: implement this!
}

static BOOL _locked;
+ (BOOL)isLocked {
	return _locked;
}
+ (void)lock {
	NSAssert(NO==_locked, @"lock errror - cant lock");
	_locked =YES;
	[self startLockTimer];
}
+ (void)unlock:(id)callee callback:(SEL)method {

	NSAssert(YES==_locked, @"lock errror - cant unlock");
	[self cancelLockTimer];
	[callee performSelector:method];
	_locked =NO;
}

- (id)init {

	self = [super init];
	if(self){
		_queuedActions = [[NSMutableArray array] retain];
		_arg_placeHolder = [NSObject new];
		_shared = self;
	}
	return self;
}

- (void)dealloc {
	
	[_queuedActions release];
	[super dealloc];
}

- (void)store:(id)value to:(NSString*)key {
	[self setValue:value forKey:key];
}

+ (NSString *)heya:(NSString *)val {
	return([val stringByAppendingFormat:@"chicken"]);
}

- (void)awakeFromNib {
	NSLog(@"WHAT HE");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	/* Test cases */	
	id stub11 = [FF target:self selector:@selector(store:to:) args:[NSArray arrayWithObjects:@"Steveiee", @"var1", nil]];
	[self pushAction:stub11];

	id stub1 = [FF target:[self class] selector:@selector(heya:) args:[NSArray arrayWithObjects:@"<var1", nil]];
	[self pushAction:stub1];

	id stub2 = [FF target:[self class] selector:@selector(heya:) args:[NSArray arrayWithObjects:_arg_placeHolder, nil]];
	[self pushAction:stub2];
	/* End test cases */

	// Just this one test suite for now
	SenTestSuite *mySuiteOfTests = [SenTestSuite testSuiteForBundlePath:[[NSBundle bundleForClass:[self class]] bundlePath]];
	testSuiteRun = [[SenTestSuiteRun testRunWithTest:mySuiteOfTests] retain];

	// mySuiteOfTests setUp
	id setUpSuite = [FF target:mySuiteOfTests selector:@selector(setUp) args:nil];
	[self pushAction:setUpSuite];
	
	// testSuiteRun start
	id startSuiteRun = [FF target:testSuiteRun selector:@selector(start) args:nil];
	[self pushAction:startSuiteRun];
	
	NSArray *allTests = [mySuiteOfTests performSelector:@selector(tests)];
	for( id eachTestCaseSuite in allTests ) 
	{
		id testRunWithTest = [FF target:NSClassFromString(@"SenTestSuiteRun") selector:@selector(testRunWithTest:) args:[NSArray arrayWithObject:eachTestCaseSuite]];
		[self pushAction:testRunWithTest];

		// store SenTestSuiteRun *testRun to @"var1"
		id varStor1 = [FF target:self selector:@selector(store:to:) args:[NSArray arrayWithObjects:_arg_placeHolder, @"var1", nil]];
		[self pushAction:varStor1];

		// [eachTestCaseSuite setUp];
		id setUpTestCaseSuite = [FF target:eachTestCaseSuite selector:@selector(setUp) args:nil];
		[self pushAction:setUpTestCaseSuite];
		
		// [testRun start];
		id startTestRun = [FF target:@"<var1" selector:@selector(start) args:nil];
		[self pushAction:startTestRun];
		
		NSArray *tests2 = [eachTestCaseSuite performSelector:@selector(tests)];
		for( SenTestCase *eachTestCase in tests2 ) 
		{
			// SenTestCaseRun *testCaseRun = [SenTestCaseRun testRunWithTest:eachTestCase];
			id testCaseRun = [FF target:NSClassFromString(@"SenTestCaseRun") selector:@selector(testRunWithTest:) args:[NSArray arrayWithObjects:eachTestCase, nil]];
			[self pushAction:testCaseRun];

			// store SenTestCaseRun *testCaseRun to @"var2"
			id varStor2 = [FF target:self selector:@selector(store:to:) args:[NSArray arrayWithObjects:_arg_placeHolder, @"var2", nil]];
			[self pushAction:varStor2];
			
			// RUN THE ACTUAL TEST
			// TODO: EXPAND This into 2 runs
			// > [eachTestCase performTest:testCaseRun];
			id testRun1 = [FF target:eachTestCase selector:@selector(performTest_begin:) args:[NSArray arrayWithObjects:@"<var2", nil]];
			[self pushAction:testRun1];			
			
			id testRun2 = [FF target:eachTestCase selector:@selector(performTest_end:) args:[NSArray arrayWithObjects:@"<var2", nil]];
			[self pushAction:testRun2];		
			
			// [(SenTestSuiteRun *)testRun addTestRun:testCaseRun];
			id addTestRun = [FF target:@"<var1" selector:@selector(addTestRun:) args:[NSArray arrayWithObjects:@"<var2", nil]];
			[self pushAction:addTestRun];	
			
			// clean up stored var arg2
			// TODO: make a method on self to clean up arg2

		} // End each test
		
		// [testRun stop];
		id stopTestRun = [FF target:@"<var1" selector:@selector(stop) args:nil];
		[self pushAction:stopTestRun];
		
		// [eachTestCaseSuite tearDown];
		id tearDownTestCaseSuite = [FF target:eachTestCaseSuite selector:@selector(tearDown) args:nil];
		[self pushAction:tearDownTestCaseSuite];
		
		// [(SenTestSuiteRun *)testSuiteRun addTestRun:testRun];
		id addTestRun = [FF target:testSuiteRun selector:@selector(addTestRun:) args:[NSArray arrayWithObjects:@"<var1", nil]];
		[self pushAction:addTestRun];	
	
	} // End each suite

	// [testSuiteRun stop];
	id stopSuiteRun = [FF target:testSuiteRun selector:@selector(stop) args:nil];
	[self pushAction:stopSuiteRun];	

	// [mySuiteOfTests tearDown];
	id tearDownUpSuite = [FF target:mySuiteOfTests selector:@selector(tearDown) args:nil];
	[self pushAction:tearDownUpSuite];

	
	
	
	/* Launch the background App */
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *guiFiddler = [mainBundle pathForResource:@"GUIFiddler" ofType:nil];
	NSCAssert(guiFiddler, @"cant find guiFiddler");
	
	/* is GUIFiddler already running? */
	BOOL alreadyRunning = NO;

	if(!alreadyRunning){
		_task = [[NSTask alloc] init];
		[_task setLaunchPath:guiFiddler];
		int appID = [[NSProcessInfo processInfo] processIdentifier];
		[_task setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%i",appID]]]; 
		[_task launch];
		_psn = [_task processIdentifier];
		NSLog(@"Task is running? %i %i", _psn, [_task isRunning]);
	}
	_timer = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES] retain];
}

- (OSStatus)quitApplicationWithPSN:(ProcessSerialNumber)processPSN {
	
    OSStatus err;
    AppleEvent event, reply;
	
//    err = AEBuildAppleEvent(kCoreEventClass, kAEQuitApplication,
//                            typeApplicationBundleID, 
//                            bundleIDString, strlen(bundleIDString),
//                            kAutoGenerateReturnID, kAnyTransactionID,
//                            &event, NULL, "");
	 
	err = AEBuildAppleEvent( kCoreEventClass, kAEQuitApplication, typeProcessSerialNumber, &processPSN, sizeof(ProcessSerialNumber), kAutoGenerateReturnID, kAnyTransactionID, &event, NULL,"");
	
    if (err == noErr) {
  //     err = AESendMessage(&event, &reply, kAENoReply, kAEDefaultTimeout);
		err = AESendMessage( &event, &reply, kAENoReply, kAEDefaultTimeout );	

	//	err = AESend( &event, &reply, kAEAlwaysInteract+kAENoReply, kAENormalPriority, kNoTimeOut, nil, nil );	

        (void)AEDisposeDesc(&event);
    }
    return err;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	
	if(!_task){
		[NSException raise:@"we didnt start task!" format:@""];
	} else {
		ProcessSerialNumber serialNum;
		OSStatus err = GetProcessForPID(_psn, &serialNum);
		if(err!=noErr)
			NSLog(@"hmm");
		[self quitApplicationWithPSN:serialNum];
		[_task terminate];
		[_task waitUntilExit];
		[_task release];
	}
}

+ (void)arggShit {
	NSLog(@"arggShit");
}

- (void)pushAction:(id)value {
	[_queuedActions addObject:value];
}

- (void)startNextAction {
	
	if([_queuedActions count])
	{
		// NSLog(@"new action from stack");
		_actionInProgress = YES;

		NSInvocation *nextAction;
		NSMethodSignature *methodSig;
		id actionObject = [_queuedActions objectAtIndex:0];

		if([actionObject isKindOfClass:[FF class]]){

			// Build the invocation
			FF *nextActionPrototype = actionObject;
			id storedTarget = nextActionPrototype.target;

			if(storedTarget==_arg_placeHolder)
				storedTarget = _previousResult;
			else if([storedTarget respondsToSelector:@selector(isEqualToString:)]) {
				if([storedTarget isEqualToString:@"<var1"])
					storedTarget = _var1;
				else if([storedTarget isEqualToString:@"<var2"])
					storedTarget = _var2;
			}

			methodSig = [storedTarget methodSignatureForSelector:nextActionPrototype.selector];
			NSInvocation *customInv = [NSInvocation invocationWithMethodSignature:methodSig];
			[customInv setTarget:storedTarget];
			[customInv setSelector:nextActionPrototype.selector];
			nextAction = customInv;
			
			// pass in arguments
			NSUInteger i=2;
			for( id each in nextActionPrototype.args ){
				
				if(each==_arg_placeHolder)
					each = _previousResult;
				else if([each respondsToSelector:@selector(isEqualToString:)]) {
					if([each isEqualToString:@"<var1"])
						each = _var1;
					else if([each isEqualToString:@"<var2"])
						each = _var2;
				}
				
				[customInv setArgument:&each atIndex:i];
				i++;
			}
			[_queuedActions replaceObjectAtIndex:0 withObject:customInv];
			
		} else {
			NSAssert( [actionObject isKindOfClass:[NSInvocation class]], @"cant queue any other types of objects?");
			nextAction = actionObject;
			
			// replace placeholder argument with previous value
			methodSig = [nextAction methodSignature];
			NSUInteger num = [methodSig numberOfArguments];
			for( NSUInteger i=2; i<num; i++ )
			{
				id argument;
				[nextAction getArgument:&argument atIndex:i];
				
				if( argument==_arg_placeHolder){
					NSLog(@"replacing argument %@ with %@", _arg_placeHolder, _previousResult);
					[nextAction setArgument:&_previousResult atIndex:i];
				}
			}
		}
		
		// call the queued method
		@try {
			[nextAction invoke];
		}@catch(id exception) {
			NSLog(@"%@", exception);
		}
		// handle a returned object
		NSUInteger length = [methodSig methodReturnLength];
		if( length )
		{
			[_previousResult autorelease];
			// buffer = (void *)malloc(length);
			[nextAction getReturnValue:&_previousResult];
			[_previousResult retain];
		}
	}
}

- (void)completeAction {
	
	NSAssert([_queuedActions count], @"Must be - how can we complete?");
//	NSInvocation *finishedAction = (NSInvocation *)[_queuedActions objectAtIndex:0];
//	if( YES==[finishedAction isTestMethod] ){
//		NSInvocation *testCompletetion = [finishedAction prependSelector:@"_"];
//		[testCompletetion invoke];
//	}
	[_queuedActions removeObjectAtIndex:0];
	_actionInProgress = NO;
}

- (void)doNextAction {
	
	if( !_actionInProgress )
	{
		if( ![RunTests isLocked] ) {
			// if the test is asyncronous it can lock the global RunTests to prevent a new test from beggining
			[self startNextAction];
		} else {
		//	NSLog(@"waiting...");
		}
	}
	else {
		[self completeAction];
	}
}

- (void)timerFire:(id)value {
	[self doNextAction];
}


@end
