//
//  SimpleNote.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/21/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "SimpleNote.h"


@implementation SimpleNote

@synthesize pitch=_pitch, velocity=_velocity;

+ (SimpleNote *)noteWithPitch:(CGFloat)c1 velocity:(CGFloat)c2 {
	SimpleNote *note = [[SimpleNote alloc] initWithPitch:c1 velocity:c2];
	return [note autorelease];
}

- (id)initWithPitch:(CGFloat)c1 velocity:(CGFloat)c2 {

	self = [super init];
	if(self){
		_pitch = c1;
		_velocity = c2;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {

	self = [super init];
	if(self) {
		_pitch = [coder decodeFloatForKey:@"pitch"];
		_velocity =	[coder decodeFloatForKey:@"velocity"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {

	[coder encodeFloat:_pitch forKey:@"pitch"];
	[coder encodeFloat:_velocity forKey:@"velocity"];
}

@end
