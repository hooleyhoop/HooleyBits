//
//  NSScriptCommand.m
//  InAppTests
//
//  Created by steve hooley on 21/01/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "NSScriptCommand.h"


@implementation NSScriptCommand (HooleyScriptCommand)

- (id)sayWhatever {
	NSLog(@"Fuck yeah");
	return nil;
}

- (id)sayWhatever:(id)value {
	NSLog(@"Fuck yeah");
	return nil;
}

- (id)performDefaultImplementation {
	NSLog(@"og hete");
	return nil;
}

@end
