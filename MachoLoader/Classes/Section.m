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
@synthesize sect_pointer=_sect_pointer;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(uint64)memAddr length:(uint64)len fileAddr:(uint64)fa {
	return [[[self alloc] initWithName:secName segment:segName start:memAddr length:len fileAddr:fa] autorelease];
}

- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(uint64)memAddr length:(uint64)len fileAddr:(uint64)fa {
	
	self = [super initWithName:name start:memAddr length:len];
	if(self){
		_segName = [segName retain];
		_sect_pointer = fa;
	}
	return self;
}

- (void)dealloc {

	[_segName release];
	[super dealloc];
}

@end
