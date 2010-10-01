//
//  DisassemblyChecker.m
//  MachoLoader
//
//  Created by Steven Hooley on 01/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DisassemblyChecker.h"


@implementation DisassemblyChecker

- (id)initWithPath:(NSString *)aPath {
	
	self = [super init];
	if(self) {
		_filePath = [aPath retain];
	}
	return self;
}

- (void)dealloc {
	[_filePath release];
	[super dealloc];
}

@end
