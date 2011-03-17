//
//  Polygon.m
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HooPolygon.h"
#import "FreetypeTestShapes.h"
#import "ftmisc.h"
#import "ftimage.h"

@implementation HooPolygon

+ (HooPolygon *)complexTestPoly {
    
    struct FT_Outline_ *poly = makeSegmentedCirclePoly();
    return [[[HooPolygon alloc] initWithFreeTypePoly:poly] autorelease];
}

- (id)init {
	self = [super init];
    if( self ) {
        
        _ptArray = [[NSPointerArray pointerArrayWithWeakObjects] retain];
        
        CGPoint *p1 = malloc(sizeof(CGPoint));
        CGPoint *p2 = malloc(sizeof(CGPoint));
        CGPoint *p3 = malloc(sizeof(CGPoint));
        p1->x = 10.; 
        p1->y = 10.;
        p2->x = 250.; 
        p2->y = 300.;
        p3->x = 400.; 
        p3->y = 2.;
        [_ptArray addPointer:p1];
        [_ptArray addPointer:p2];
        [_ptArray addPointer:p3];
        [_ptArray addPointer:p1];
    }
    return self;
}

- (id)initWithFreeTypePoly:(struct FT_Outline_ *)poly {
    self = [super init];
    if( self ) {
        // ignore n_contours for now. doh
        for(int i=0;i<poly->n_points;i++){
            CGPoint *p1 = malloc(sizeof(CGPoint));
            p1->x = poly->points[i].x; 
            p1->y = poly->points[i].y;            
            [_ptArray addPointer:p1];
        }
    }
    return self;
}

- (void)dealloc {
    
    // remove all pointer shit
    
    [_ptArray release];
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
    
    CGPoint *p = [_ptArray pointerAtIndex:0];
	CGContextMoveToPoint( windowContext, p->x, p->y );
	for( int i=1; i<[self numverts]; i++ ) {
        p = [_ptArray pointerAtIndex:i];        
		CGContextAddLineToPoint( windowContext, p->x, p->y );
	}
	CGContextDrawPath( windowContext, kCGPathStroke );
	
	CGColorRelease(blackCol);
	CGColorRelease(whiteCol);
}

- (CGRect)boundsRect {
    NSLog(@"TODO:FIX THIS!");
	return CGRectMake( 0,0,600., 600.);
}

- (NSPointerArray *)pts {
	return _ptArray;
}

- (NSUInteger)numverts {
    return [_ptArray count];
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
