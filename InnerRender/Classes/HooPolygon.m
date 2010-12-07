//
//  Polygon.m
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HooPolygon.h"


@implementation HooPolygon

static int ptCount = 3;

static double p1[2] = {10.,10.};
static double p2[2] = {300.,300.};
static double p3[2] = {600.,2.};

static double pts[4][2] = { {10.,10.}, {250.,300.}, {400.,2.}, {10.,10.} };

static int _height = 600;
static int _width = 600;

- (id)init {
	self = [super init];
    if( self ) {
//		addPt:
//		addPt:
//		addPt:		
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)windowContext  {

	CGColorRef blackCol = CGColorCreateGenericRGB( 1.0f, 0.0f, 0.0f, 1.0f );
	CGColorRef whiteCol = CGColorCreateGenericRGB( 1.0f, 1.0f, 1.0f, 1.0f );
	
    CGContextSetFillColorWithColor( windowContext, blackCol );
	CGContextSetStrokeColorWithColor( windowContext, blackCol );	

	// draw each line
	CGContextBeginPath( windowContext );
	CGContextSetAllowsAntialiasing( windowContext, true );
	CGContextSetLineWidth( windowContext, 1.0f );	
	CGContextDrawPath( windowContext, kCGPathStroke );
	CGContextMoveToPoint( windowContext, pts[0][0], pts[0][1] );
	for( int i=1; i<ptCount; i++ ) {
		CGContextAddLineToPoint( windowContext, pts[i][0], pts[i][1] );
	}
	CGContextAddLineToPoint( windowContext, pts[0][0], pts[0][1] );
	CGContextDrawPath( windowContext, kCGPathStroke );

	// draw each pt
	for( int i=0; i<ptCount; i++ ) {
		double px = pts[i][0];
		double py = pts[i][1];
		
		CGContextFillRect( windowContext, CGRectMake( px, py, 5., 5.));
	}
	
	CGColorRelease(blackCol);
	CGColorRelease(whiteCol);
}

- (CGRect)boundsRect {
	return CGRectMake( 0,0,_width, _height);
}

- (double (*)[2])pts {
	return pts;
}

//int pnpoly( int nvert, float *vertx, float *verty, float testx, float testy )
//{
//	int i, j, c = 0;
//	for (i = 0, j = nvert-1; i < nvert; j = i++) {
//		if ( ((verty[i]>testy) != (verty[j]>testy)) &&
//			(testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
//			c = !c;
//	}
//	return c;
//}




@end
