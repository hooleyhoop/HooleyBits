//
//  AunitTest.m
//  InAppTests
//
//  Created by steve hooley on 07/01/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "RunTests.h"
#import <SHShared/NSInvocation(ForwardedConstruction).h>
#import <SenTestingKit/SenTestCase.h>
#import "TestHelp.h"
#import "GUITestProxy.h"
#import "AsyncTests.h"

@interface AunitTest : AsyncTests {
	TestHelp *_testHelper;
}


@end

#pragma mark -
@implementation AunitTest

- (void)setUp {
	_testHelper = [[TestHelp makeWithTest:self] retain];
}

- (void)tearDown {
	[_testHelper release];
}

//-- send to GUIFiddler applescript to call and arguments - return Notification to call with results
//-- GUIFiddler runs appescript and sends a return Notification with result
//-- assert the result is what we expected
- (void)testShit {

	// move to subclass? when working
//cunt	[_testHelper aSync:[GUITestProxy lockTestRunner]];

//cunt	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
//cunt	[dc closeAllDocumentsWithDelegate:nil didCloseAllSelector:nil contextInfo:nil];

//cunt	[_testHelper aSyncAssertTrue:[GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"]];
//cunt	[_testHelper aSyncAssertFalse:[GUITestProxy statusOfMenuItem:@"Close" ofMenu:@"File"]];
	
//cunt	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
//cunt	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];

//cunt	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"Close"]];
//cunt	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
	
//	[_testHelper aSync:[GUITestProxy wait]];

//	[_testHelper aSync:[GUITestProxy openMainMenuItem:@"File"]];
//	[_testHelper aSync:[GUITestProxy wait]];

// 	STAssertTrue( 0==[[dc documents] count], @"should have made a new doc" );

//	[_testHelper aSync:[GUITestProxy closeMainMenuItem:@"File"]];


	
//	[_testHelper aSync:[GUITestProxy selectItems2And3]];

//	[_testHelper aSync:[GUITestProxy dropFileOnTableView]];


//	STFail(@"ARRRRRRRRRRRGGGGGGGGGGGGGGGGGGGG");
//	STAssertTrue(NO,@"hmm");
	
//	[_testHelper aSync:[GUITestProxy doTo:self selector:@selector(_testShit)]];

	[_testHelper aSync:[GUITestProxy unlockTestRunner]];
}

- (void)_testShit {

//	NSLog(@"aaa");
//	STAssertTrue( NO,@"hmm" );
	NSLog(@"aaa");

}


- (void)testShat {
	NSLog(@"wohh");
}






@end
