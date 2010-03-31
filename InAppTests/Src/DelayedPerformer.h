//
//  DelayedPerformer.h
//  InAppTests
//
//  Created by steve hooley on 18/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//


@interface DelayedPerformer : NSObject {

}

+ (void)delayedCallSelector:(SEL)selArg onObject:(id)target withArg:(id)arg afterDelay:(CGFloat)delayArg;

@end
