//
//  DebugCodeLine.m
//  MachoLoader
//
//  Created by Steven Hooley on 21/11/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DebugCodeLine.h"
#import "Argument.h"

@implementation DebugCodeLine

+ (id)lineWithAddress:(NSUInteger)addressInt instruction:(id)inst args:(id)arg {
	
	DebugCodeLine *cl = [[[DebugCodeLine alloc] initWithAddress:addressInt instruction:inst args:arg] autorelease];
	return cl;
}

- (id)initWithAddress:(NSUInteger)addressInt instruction:(id)inst args:(id)arg {
	
	self = [super init];
	if(self){
		_address = addressInt;
		_numberOfArgs = [arg count];
		if(_numberOfArgs==1){
			Argument *argOne = ((Argument *)[arg objectAtIndex:0]);
			if( [argOne isJunk]==YES )
				_junkLine = YES;
		}
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}


@end
