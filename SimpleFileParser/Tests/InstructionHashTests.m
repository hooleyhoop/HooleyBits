//
//  InstructionHashTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "InstructionHash.h"

@interface InstructionHashTests : SenTestCase {
	
}

@end


@implementation InstructionHashTests


- (void)testStuff {
	
	[InstructionHash prepare];
	InstructionHash *iH = [InstructionHash cachedInstructionHash];
	
	NSDictionary *insDict = [iH hashForInstruction:@"mov"];
}

@end
