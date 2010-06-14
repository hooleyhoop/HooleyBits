//
//  StringCounter.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "StringCounter.h"


@implementation StringCounter

- (id)init {
	_allStrings = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc {
	[_allStrings release];
	[super dealloc];
}

- (void)add:(NSString *)val {
	
}

- (NSArray *)sortedCounts {
	return nil;
}

- (NSArray *)sortedStrings {
	return nil;
}
@end
