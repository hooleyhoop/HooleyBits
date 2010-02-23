//
//  View_Base.m
//  iphonePlay
//
//  Created by steve hooley on 20/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "View_Base.h"


@implementation View_Base

@synthesize viewController;

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

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

@end
