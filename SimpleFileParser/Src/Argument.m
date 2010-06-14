//
//  Argument.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Argument.h"
#import "BasicToken.h"

@implementation Argument

+ (id)emptyArgument {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	_allTokens = [[NSMutableArray array] retain];
	return self;
}

- (void)dealloc {
	[_allTokens release];
	[super dealloc];
}

- (void)addToken:(BasicToken *)tok {
	[_allTokens addObject:tok];
}

- (NSString *)output {
	
	NSString *outputString = @"";
	
	for( BasicToken *each in _allTokens ){
		if([outputString length]==0)
			outputString = [each outputString];
		else
			outputString = [NSString stringWithFormat:@"%@ %@", outputString, [each outputString]];
	}
	return outputString;
}

@end
