//
//  RegisterLookup.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 29/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RegisterLookup.h"
#import "YAMLParser.h"


@implementation RegisterLookup

- (id)init {
	
	self = [super init];
	if(self){
	}
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (void)parseYAML {

	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"registers" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	YAMLParser *ayp = [[YAMLParser alloc] initWithFilePath:filePath];
	CFMutableDictionaryRef root = [ayp rootDictionary];
	
	[ayp release];
}

@end
