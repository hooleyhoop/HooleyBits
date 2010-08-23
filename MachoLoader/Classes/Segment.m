//
//  Segment.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Segment.h"
#import "Section.h"
#import "MemoryBlockStore.h"

@implementation Segment

+ (id)name:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len {
	
	return [[[self alloc] initWithName:name start:memAddr length:len] autorelease];
}

- (id)initWithName:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len {

	self = [super initWithName:name start:memAddr length:len];
	if(self){
		_sectionStore = [[MemoryBlockStore alloc] init];
	}
	return self;
}

- (void)dealloc {

	[super dealloc];
}

- (void)insertSection:(Section *)sec {

	[_sectionStore insertMemoryBlock:sec];
}

- (Section *)sectionForAddress:(NSUInteger)memAddr {
	
	return (Section *)[_sectionStore blockForAddress:memAddr];
}

@end
