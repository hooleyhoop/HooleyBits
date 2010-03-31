//
//  Window_Base.m
//  iphonePlay
//
//  Created by steve hooley on 13/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "Window_Base.h"


@implementation Window_Base

- (id)initWithFrame:(CGRect)frame {
	self=[super initWithFrame:frame];
    if(self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self=[super initWithCoder:aDecoder];
    if(self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
