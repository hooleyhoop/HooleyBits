//
//  InstructionLookup.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface InstructionLookup : NSObject {

}

+ (void)testParseYAML;

+ (NSDictionary *)infoForInstructionString:(NSString *)instruction;

@end