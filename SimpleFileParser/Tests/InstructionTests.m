//
//  InstructionTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 15/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//



@interface InstructionTests : SenTestCase {
	
}

@end


@implementation InstructionTests

- (void)testBasicInstructionOps {

	NSString *testInstruction = @"movb";
	NSString *replaceMent = [Hmm findReplacement:testInstruction];
	
	STAssertTrue( [replaceMent isEqualToString:@"move"], nil);
}


@end
