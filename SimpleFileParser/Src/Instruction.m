//
//  Instruction.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 15/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Instruction.h"
#import "Argument.h"

@implementation Instruction

+ (id)instructionWithDict:(NSDictionary *)instrInfo {
	
	return [[[self alloc] initWithDict:instrInfo] autorelease];
}

- (id)initWithDict:(NSDictionary *)instrInfo {
	
	NSParameterAssert(instrInfo);

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

- (NSString *)printWithArgs:(NSArray *)args {
	
	NSString *resultString = [self name];
	if(resultString==nil || [resultString length]==0 )
		resultString = [self instruction];
	for( Argument *each in args ){
		resultString = [resultString stringByAppendingFormat:@" %@", [each output]];
	}
	return resultString;
}

@end
