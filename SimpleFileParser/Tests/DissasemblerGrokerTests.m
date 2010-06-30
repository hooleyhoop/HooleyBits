//
//  DissasemblerGroker.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DissasemblerGroker.h"
#import "iMakeCodeBlocks.h"

@interface DissasemblerGrokerTests : SenTestCase {
	
}

@end

@implementation DissasemblerGrokerTests

- (void)testLineRecognition {
	
	NSCharacterSet *wsp = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	OCMockObject *mockLineEater	= MOCKFORPROTOCOL(iMakeCodeBlocks);

	DissasemblerGroker *groker = [DissasemblerGroker groker];
	[groker setDelegate:(id)mockLineEater];
	
	// first the header
	[groker process:@"/Applications/Sibelius 6-386.app/Contents/MacOS/Sibelius 6:"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged==YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker process:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker process:@"md5: bbc028591fda410a7b0665e9c332a576"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker process:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker process:@"(__TEXT,__text) section"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker process:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	// start a named function
	NSString *funcName1 = @"start:";
	[groker process:funcName1];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );
	
	NSString *codeLine1 = @"	+0	00002ac0  6a00					  pushl		  $0x00";
	[[mockLineEater expect] newCodeBlockWithName:funcName1];
	[[mockLineEater expect] addCodeLine:[codeLine1 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine1];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];
	
	NSString *codeLine2 = @"	+2	00002ac2  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] addCodeLine:[codeLine2 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine2];
	STAssertTrue( groker.state==NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	NSString *codeLine3 = @"	+4	00002ac4  83e4f0				  andl		  $0xf0,%esp";
	[[mockLineEater expect] addCodeLine:[codeLine3 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine3];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	[groker process:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	// Start an anon function
	NSString *codeLine4 = @"+0	00002aea  55					  pushl		  %ebp";
	[[mockLineEater expect] newCodeBlockWithName:nil];
	[[mockLineEater expect] addCodeLine:[codeLine4 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine4];
	STAssertTrue( groker.state == ANON_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	NSString *codeLine5 = @"+1	00002aeb  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] addCodeLine:[codeLine5 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine5];
	STAssertTrue( groker.state == ANON_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	[groker process:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	NSString *funcName2 = @"-(BOOL)[PSPluginCocoaWindow windowShouldClose:]";
	[groker process:funcName2];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	NSString *codeLine6 = @"+1	00002aeb  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] newCodeBlockWithName:funcName2];
	[[mockLineEater expect] addCodeLine:[codeLine6 stringByTrimmingCharactersInSet:wsp]];
	[groker process:codeLine6];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];
}

// start new function
// add line to new function
@end
