//
//  DelayedPerformer.m
//  InAppTests
//
//  Created by steve hooley on 18/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "DelayedPerformer.h"


@implementation DelayedPerformer

+ (void)delayedCallSelector:(SEL)selArg onObject:(id)target withArg:(id)arg afterDelay:(CGFloat)delayArg {

	NSParameterAssert(selArg);
	NSParameterAssert(target);

	[target performSelector:selArg withObject:arg afterDelay:delayArg];
}


@end
