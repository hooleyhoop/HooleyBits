//
//  InstructionHash.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "InstructionHash.h"
#import "InstructionLookup.h"
#import "Instruction.h"


@implementation InstructionHash

			 
+ (InstructionHash *)cachedInstructionHash {
	
	static InstructionHash *_cached;
	if(_cached==nil)
		_cached = [[InstructionHash alloc] init];
	return _cached;
}

+ (Instruction *)instructionForOpcode:(NSString *)opcode {
	
	return [[self cachedInstructionHash] instructionForOpcode:opcode];
}

+ (NSDictionary *)hashForInstruction:(NSString *)opcode {

	NSDictionary *instrInfo = [InstructionLookup infoForInstructionString:opcode];
	return instrInfo;
}

- (id)init {

	self = [super init];
	if(self){
		_cachedInstructions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_cachedInstructions release];
	[super dealloc];
}

- (Instruction *)instructionForOpcode:(NSString *)opcode {
	
	NSParameterAssert(opcode);
	Instruction *insr = [_cachedInstructions objectForKey:opcode]; 
	if( insr==nil ) {
		NSDictionary *instrInfo = [InstructionHash hashForInstruction:opcode];
		insr = [Instruction instructionWithDict:instrInfo];
		[_cachedInstructions setObject:insr forKey:opcode];
	}
	NSAssert(insr, @"grunch");
	return insr;
}

@end
