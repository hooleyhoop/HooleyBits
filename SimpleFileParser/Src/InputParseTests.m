//
//  InputParseTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "InputParse.h"
#import "iConsumeLines.h"

@interface InputParseTests : SenTestCase <iConsumeLines> {
	
	NSMutableArray *_consumedLines;
}

@end


@implementation InputParseTests

- (void)setUp {
	_consumedLines = [[NSMutableArray array] retain];
}

- (void)tearDown {
	[_consumedLines release];
}

- (void)eatLine:(NSString *)val {
	[_consumedLines addObject:val];
}

- (void)testParseLines {
	
	InputParse *parser = [InputParse parserWithString:@"You are \n\n a son of a gun \n \n and i hope this works"];
	
	NSArray *expectedResults = [NSArray arrayWithObjects:
								@"You are ",
								@"",
								@" a son of a gun ",
								@" ",
								@" and i hope this works",
								nil];
	
	[parser setConsumer:self];
	[parser doIt];

	for (NSUInteger i=0; i<[expectedResults count]; i++)
	{
		NSString *parsedLine = [_consumedLines objectAtIndex:i];
		NSString *expectedLine = [expectedResults objectAtIndex:i];
		STAssertTrue( [parsedLine isEqualToString:expectedLine], @"%@ ----- %@", parsedLine, expectedLine );
	}

}

@end


