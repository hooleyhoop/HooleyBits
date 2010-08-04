//
//  AppDisassembly.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "AppDisassembly.h"
#import "OtoolDisassemblyParser.h"

@implementation AppDisassembly

+ (id)createFromOtoolOutput:(NSString *)fileString {

	id processedFile = [[[self alloc] initWithOtoolOutput:fileString] autorelease];
	return processedFile;
}

- (id)initWithOtoolOutput:(NSString *)fileString {

	self = [super init];
	if(self){

		_internalRepresentation = [[OtoolDisassemblyParser constructInternalRepresentation:fileString] retain];
	}
	return self;
}

- (void)dealloc {

	[_internalRepresentation release];

	[super dealloc];
}

@end
