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

			 
+ (InstructionHash *)cachedInstructionHashWithLookup:(InstructionLookup *)lookup {
	
	static InstructionHash *_cached;
	if(_cached==nil)
		_cached = [[InstructionHash alloc] initWithLookup:lookup];
	return _cached;
}

//+ (Instruction *)instructionForOpcode:(NSString *)opcode {
//	
//	return [[self cachedInstructionHash] instructionForOpcode:opcode];
//}
//
//+ (NSDictionary *)hashForInstruction:(NSString *)opcode {
//
//	NSDictionary *instrInfo = [_instructionLookup infoForInstructionString:opcode];
//	return instrInfo;
//}

- (id)initWithLookup:(InstructionLookup *)lookup {

	self = [super init];
	if(self){
		_instructionLookup = [lookup retain];
		_cachedInstructions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_instructionLookup release];
	[_cachedInstructions release];

	[super dealloc];
}

- (Instruction *)instructionForOpcode:(NSString *)opcode {
	
	NSParameterAssert(opcode);
	Instruction *insr = nil;
	@synchronized(self)
    {
		insr = [_cachedInstructions objectForKey:opcode]; 
		if( insr==nil ) {
			NSDictionary *instrInfo = [_instructionLookup infoForInstructionString:opcode];
			insr = [Instruction instructionWithDict:instrInfo];
			NSAssert(insr, @"no insr");
			[_cachedInstructions setObject:insr forKey:opcode];
		}
	}
	NSAssert(insr, @"grunch");
	return insr;
}

@end
