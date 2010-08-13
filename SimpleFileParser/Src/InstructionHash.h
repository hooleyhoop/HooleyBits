//
//  InstructionHash.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface InstructionHash : NSObject {

}

+ (void)prepare;
+ (InstructionHash *)cachedInstructionHash;

- (NSDictionary *)hashForInstruction:(NSString *)opcode;

@end
