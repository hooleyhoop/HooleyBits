//
//  RunLoopContext.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 05/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RunLoopContext.h"
#import "RunLoopSource.h"

@implementation RunLoopContext

- (id)initWithSource:(RunLoopSource *)src andLoop:(CFRunLoopRef)loop {

    self = [super init];
    if (self) {
		runLoop = loop;
		source = src
    }
    return self;
}

@end
