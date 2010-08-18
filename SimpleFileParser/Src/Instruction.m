//
//  Instruction.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 15/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Instruction.h"


@implementation Instruction

+ (id)instructionWithDict:(NSDictionary *)instrInfo {
	
	return [[[self alloc] initWithDict:instrInfo] autorelease];
}

- (id)initWithDict:(NSDictionary *)instrInfo {
	
	self = [super init];
	if(self){
		_values = instrInfo;
	}
	return self;
}

- (NSString *)name {
	return [_values objectForKey:@"name"];
}

- (NSString *)instruction {
	return [_values objectForKey:@"instruction"];
}
@end
