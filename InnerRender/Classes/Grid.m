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
	self = [super init];
    if( self ) {
		_gridsize = 20;
		_width = 600;
		_height = 600;
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)windowContext  {
    
	CGColorRef blackCol = CGColorCreateGenericRGB( 1.0f, 1.0f, 1.0f, 1.0f );

    //CGContextSetFillColorWithColor( windowContext, blackCol );
	// CGContextFillRect( windowContext, CGRectMake(0.0f,0.0f,1000.0f, 1000.0f));
	CGContextSetStrokeColorWithColor( windowContext, blackCol );
	CGContextSetAllowsAntialiasing( windowContext, false );
	CGContextSetLineWidth( windowContext, 0.5f );
	
	CGContextBeginPath( windowContext );

	// draw verticles
	for( NSUInteger x=0; x<_height; x=x+_gridsize ){

		CGContextMoveToPoint( windowContext, 0.0f, x );
		CGContextAddLineToPoint( windowContext, _height, x );
	}
	// draw horizontals
	for( NSUInteger y=0; y<_width; y=y+_gridsize ){
		
		CGContextMoveToPoint( windowContext, y, 0 );
		CGContextAddLineToPoint( windowContext, y, _width );
	}
	
	CGContextDrawPath( windowContext, kCGPathStroke );
	
	CGColorRelease(blackCol);	
}

@end
