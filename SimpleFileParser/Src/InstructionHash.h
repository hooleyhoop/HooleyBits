//
//  InstructionHash.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class Instruction;

@interface InstructionHash : NSObject {

	NSMutableDictionary *_cachedInstructions;
}


+ (Instruction *)instructionForOpcode:(NSString *)opcode;

- (Instruction *)instructionForOpcode:(NSString *)opcode;

@end
