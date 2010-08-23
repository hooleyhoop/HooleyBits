//
//  Section.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Section.h"


@implementation Section

@synthesize segmentName=_segName;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len {
	return [[[self alloc] initWithName:secName segment:segName start:memAddr length:len] autorelease];
}

- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len {
	
	self = [super initWithName:name start:memAddr length:len];
	if(self){
		_segName = [segName retain];
	}
	return self;
}

- (void)dealloc {

	[_segName release];
	[super dealloc];
}

@end
