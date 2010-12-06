//
//  Grid.m
//  InnerRender
//
//  Created by Steven Hooley on 06/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Grid.h"


@implementation Grid

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)windowContext  {
    
    CGContextSetFillColorWithColor( windowContext, blackCol );
	CGContextFillRect( windowContext, CGRectMake(0.0f,0.0f,1000.0f, 1000.0f));

    CGContextBeginPath( context );
	CGContextMoveToPoint( context, 0.0f, fontXHeight );
	CGContextAddLineToPoint( context, 200.0f, fontXHeight );
	CGContextDrawPath( context, kCGPathStroke );
}

@end
