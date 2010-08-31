//
//  LinesInStringIterator.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "LinesInStringIterator.h"


@implementation LinesInStringIterator

@synthesize consumer = _consumer;


+ (void)feedLines:(NSString *)fileString to:(NSObject<iConsumeLines> *)consumer {
	
	LinesInStringIterator *lineIterator = [LinesInStringIterator iteratorWithString:fileString];
	[lineIterator setConsumer:consumer];
	[lineIterator doIt];
}


+ (id)iteratorWithString:(NSString *)val {
	return [[[self alloc] initWithString:val] autorelease];
}

- (id)initWithString:(NSString *)val {
	
	self = [super init];
	if(self)
	{
		_fileString = [val retain];
	}
	return self;
}

- (void)dealloc {
	
	[_fileString release];
	[_consumer release];

	[super dealloc];
}

- (void)doIt {
	
	void (^enumerateBlock)(NSString *, BOOL *) = ^(NSString *line, BOOL *stop) {
		[_consumer eatLine:line];
	};
	[_fileString enumerateLinesUsingBlock:enumerateBlock];
	[_consumer noMoreLines];
}

@end
