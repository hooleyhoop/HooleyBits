//
//  DebugCodeLine.m
//  MachoLoader
//
//  Created by Steven Hooley on 21/11/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DebugCodeLine.h"


@implementation DebugCodeLine

+ (id)lineWithAddress:(NSUInteger)addressInt instruction:(id)inst args:(id)arg {
	
	DebugCodeLine *cl = [[[DebugCodeLine alloc] initWithAddress:addressInt] autorelease];
	return cl;
}

- (id)initWithAddress:(NSUInteger)addressInt {
	
	self = [super init];
	if(self){
		_address = addressInt;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

@end
