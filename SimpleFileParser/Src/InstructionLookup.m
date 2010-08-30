//
//  InstructionLookup.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "InstructionLookup.h"
#import "YAMLParser.h"


@implementation InstructionLookup

+ (void)parseYAML {

	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"opcode" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	YAMLParser *ayp = [[YAMLParser alloc] initWithFilePath:filePath];
	


}

+ (NSDictionary *)infoForInstructionString:(NSString *)instruction {

//	NSDictionary *result = (NSDictionary *)CFDictionaryGetValue( _opcodeLookup, instruction );
//	if(!result)
//		[NSException raise:@"Unknown Opcode" format:@"Error: Cant find %@ in opcode lookup", instruction];
//	return result;
	return nil;
}

@end
