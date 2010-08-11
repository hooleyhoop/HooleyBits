//
//  SourceLineCategorizerTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SourceLineCategorizer.h"
#import "iParseSrc.h"

@interface SourceLineCategorizerTests : SenTestCase {
	
}

@end

@implementation SourceLineCategorizerTests

- (void)setUp {
	
}

- (void)tearDown {
	
}

- (void)testLineRecognition {
	
	NSCharacterSet *wsp = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	OCMockObject *mockLineEater	= MOCKFORPROTOCOL(iParseSrc);

	SourceLineCategorizer *groker = [SourceLineCategorizer grokerWithDelegate:(id)mockLineEater];
	
	// first the header
	[groker eatLine:@"/Applications/Sibelius 6-386.app/Contents/MacOS/Sibelius 6:"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged==YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker eatLine:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker eatLine:@"md5: bbc028591fda410a7b0665e9c332a576"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker eatLine:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker eatLine:@"(__TEXT,__text) section"];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	[groker eatLine:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	// start a named function
	NSString *funcName1 = @"start:";
	[groker eatLine:funcName1];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );
	
	NSString *codeLine1 = @"	+0	00002ac0  6a00					  pushl		  $0x00";
	[[mockLineEater expect] processSrcLine:funcName1 type:BLOCK_TITLE];
	[[mockLineEater expect] processSrcLine:[codeLine1 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine1];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];
	
	NSString *codeLine2 = @"	+2	00002ac2  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] processSrcLine:[codeLine2 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine2];
	STAssertTrue( groker.state==NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	NSString *codeLine3 = @"	+4	00002ac4  83e4f0				  andl		  $0xf0,%esp";
	[[mockLineEater expect] processSrcLine:[codeLine3 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine3];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	[groker eatLine:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	// Start an anon function
	NSString *codeLine4 = @"+0	00002aea  55					  pushl		  %ebp";
	[[mockLineEater expect] processSrcLine:nil type:BLOCK_TITLE];
	[[mockLineEater expect] processSrcLine:[codeLine4 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine4];
	STAssertTrue( groker.state == ANON_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	NSString *codeLine5 = @"+1	00002aeb  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] processSrcLine:[codeLine5 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine5];
	STAssertTrue( groker.state == ANON_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == NO, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];

	[groker eatLine:@""];
	STAssertTrue( groker.state == NO_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	NSString *funcName2 = @"-(BOOL)[PSPluginCocoaWindow windowShouldClose:]";
	[groker eatLine:funcName2];
	STAssertTrue( groker.state == TEXT, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target==nil, nil );

	NSString *codeLine6 = @"+1	00002aeb  89e5					  movl		  %esp,%ebp";
	[[mockLineEater expect] processSrcLine:funcName2 type:BLOCK_TITLE];
	[[mockLineEater expect] processSrcLine:[codeLine6 stringByTrimmingCharactersInSet:wsp] type:BLOCK_LINE];
	[groker eatLine:codeLine6];
	STAssertTrue( groker.state == NAMED_FUNCTION, nil );
	STAssertTrue( groker.stateChanged == YES, nil );
	STAssertTrue( groker.target!=nil, nil );
	[mockLineEater verify];
}

// start new function
// add line to new function
@end
