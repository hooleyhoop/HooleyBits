//
//  LineStore.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "LineStore.h"


@implementation LineStore

- (id)init {

	self = [super init];
	if(self){
		_lineStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[_lineStore release];
	[super dealloc];
}

- (NSUInteger)insertionIndexFor:(Line *)arg {
	return 0;
}

- (void)pushLine:(Line *)arg {
	[_lineStore addObject:arg];
}

- (void)insertLine:(Line *)arg {
	
	NSUInteger ind = [self insertionIndexFor:arg];
	
}

@end
