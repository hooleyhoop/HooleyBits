//
//  AunitTest.m
//  InAppTests
//
//  Created by steve hooley on 07/01/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <SHShared/NSInvocation(ForwardedConstruction).h>
#import <SenTestingKit/SenTestCase.h>
#import <SHTestUtilities/SHTestUtilities.h>

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

- (void)testMenuItems { 

	[_testHelper aSync:[GUITestProxy lockTestRunner]];
	
	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
	[dc closeAllDocumentsWithDelegate:nil didCloseAllSelector:nil contextInfo:nil];
	
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
	
	[_testHelper aSyncAssertTrue:[GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"]];
	
	[_testHelper aSyncAssertFalse:[GUITestProxy statusOfMenuItem:@"Close" ofMenu:@"File"]];
	
	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
	
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];
	
	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"Close"]];
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
	
	[_testHelper aSync:[GUITestProxy unlockTestRunner]];
}

- (void)aaaatestDropDownMenuButton {

	[_testHelper aSync:[GUITestProxy lockTestRunner]];
	
	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
	[dc closeAllDocumentsWithDelegate:nil didCloseAllSelector:nil contextInfo:nil];
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];
	
	[_testHelper aSyncAssertEqual:[GUITestProxy dropDownMenuButtonText] :@"male" ];
	[_testHelper aSync:[GUITestProxy selectPopUpButtonItem:@"female"]];
	[_testHelper aSyncAssertEqual:[GUITestProxy dropDownMenuButtonText] :@"female" ];
	
	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"Close"]];
	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
	[_testHelper aSync:[GUITestProxy unlockTestRunner]];
}

//-- send to GUIFiddler applescript to call and arguments - return Notification to call with results
//-- GUIFiddler runs appescript and sends a return Notification with result
//-- assert the result is what we expected
- (void)disabled_testShit {
	
	// move to subclass? when working
	[_testHelper aSync:[GUITestProxy lockTestRunner]];

//	NSDocumentController *dc = [NSDocumentController sharedDocumentController];
//	[dc closeAllDocumentsWithDelegate:nil didCloseAllSelector:nil contextInfo:nil];
//
//	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
//	
//	[_testHelper aSyncAssertTrue:[GUITestProxy statusOfMenuItem:@"New" ofMenu:@"File"]];
//	
//	[_testHelper aSyncAssertFalse:[GUITestProxy statusOfMenuItem:@"Close" ofMenu:@"File"]];
//	
//	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"New"]];
//	
//	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:1]];
//
//	[_testHelper aSync:[GUITestProxy doMenu:@"File" item:@"Close"]];
//	[_testHelper aSyncAssertTrue:[GUITestProxy documentCountIs:0]];
		
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






@end
