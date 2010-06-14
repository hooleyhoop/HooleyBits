//
//  ArgumentScanner.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "ArgumentScanner.h"
#import "Argument.h"
#import "BasicToken.h"

@implementation ArgumentScanner

+ (id)scannerWithTokens:(TokenArray *)tks {
	return [[[self alloc] initWithTokens:tks] autorelease];
}

- (id)initWithTokens:(TokenArray *)tks {
	
	// @"%eax,%es:(%eax)",

	allArguments = [[NSMutableArray arrayWithCapacity:2] retain];

	NSUInteger tokCount = [tks count];
	NSAssert(tokCount,@"Fuck - empty token array");
	
	Argument *currentArgument = [Argument emptyArgument];
	uint brkCount = 0;

	// -- scan tokens -- add to current token array
	for( NSUInteger i=0; i<tokCount; i++ )
	{
		BasicToken *tok = [tks tokenAtIndex:i];

		if( tok.type==openBracket)
			brkCount++;
		else if( tok.type==closeBracket )
			brkCount--;

		if( brkCount==0 && tok.type==comma){
			[allArguments addObject:currentArgument];
			currentArgument = [Argument emptyArgument];
		} else {
			[currentArgument addToken:tok];
		}
	}
	NSAssert( brkCount==0, @"Brackets must balance");

	[allArguments addObject:currentArgument];
	return self;
}

- (void)dealloc {
	[allArguments release];
	[super dealloc];
}

- (NSUInteger)count {
	return [allArguments count];
}

- (Argument *)argumentAtIndex:(NSUInteger)index {
	return [allArguments objectAtIndex:index];
}

@end
