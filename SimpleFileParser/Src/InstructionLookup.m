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

- (id)init {
	
	self = [super init];
	if(self){
	}
	return self;
}

- (void)dealloc {

	[_conditionalsDict release];
	[_branch_instructionsDict release];
	[_normal_instructionsDict release];
	[super dealloc];
}

- (void)parseYAML {

	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"opcode" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	YAMLParser *ayp = [[YAMLParser alloc] initWithFilePath:filePath];
	CFMutableDictionaryRef root = [ayp rootDictionary];

	_conditionalsDict = (NSDictionary *)CFDictionaryGetValue( root, @"conditionals" );
	_branch_instructionsDict = (NSDictionary *)CFDictionaryGetValue( root, @"branch_instructions" );
	_normal_instructionsDict = (NSDictionary *)CFDictionaryGetValue( root, @"normal_instructions" );
	[_conditionalsDict retain];
	[_branch_instructionsDict retain];
	[_normal_instructionsDict retain];
}

- (NSDictionary *)infoForInstructionString:(NSString *)instruction {

//	NSDictionary *result = (NSDictionary *)CFDictionaryGetValue( _opcodeLookup, instruction );
//	if(!result)
//		[NSException raise:@"Unknown Opcode" format:@"Error: Cant find %@ in opcode lookup", instruction];
//	return result;
	return nil;
}

@end
