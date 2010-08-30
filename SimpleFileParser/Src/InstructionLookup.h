//
//  InstructionLookup.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface InstructionLookup : NSObject {

	NSDictionary *_conditionalsDict;
	NSDictionary *_branch_instructionsDict;
	NSDictionary *_normal_instructionsDict;
}

+ (void)parseYAML;

+ (NSDictionary *)infoForInstructionString:(NSString *)instruction;

@end
