//
//  SHNamedMemoryBlock.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHMemoryBlock.h"
#import "SHNamedMemoryBlock.h"

@implementation SHNamedMemoryBlock

@synthesize name=_name;

- (id)initWithName:(NSString *)name start:(char *)memAddr length:(uint64)len {
	
	self = [super initWithStart:memAddr length:len];
	if(self){
		_name = [name retain];
	}
	return self;
}

- (void)dealloc {
	
	[_name release];
	[super dealloc];
}


@end
