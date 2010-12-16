//
//  PolygonRasterizer.m
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "PolygonRasterizer.h"
#import "HooPolygon.h"

#ifndef SQR
#define SQR(a) ((a)*(a))
#endif

float dotProduct( CGPoint p1, CGPoint p2 ) { return p1.x * p2.x + p1.y * p2.y; }
CGPoint subVectors( CGPoint p1, CGPoint p2 ) {
	return CGPointMake( p1.x-p2.x, p1.y-p2.y );
}
CGPoint scaleVector( CGFloat mult, CGPoint vec ) {
	return CGPointMake( vec.x*mult, vec.y*mult );
}
CGPoint addVectors( CGPoint p1, CGPoint p2 ) {
	return CGPointMake( p1.x+p2.x, p1.y+p2.y );
}
CGFloat length_squared( CGPoint p1, CGPoint p2 ) {
	return SQR(p1.x-p2.x) + SQR(p1.y-p2.y);
}
CGFloat distance( CGPoint p1, CGPoint p2 ){
	return sqrt(SQR(p1.x-p2.x) + SQR(p1.y-p2.y));
}

// Return minimum distance between line segment vw and point p
float minimum_distance( CGPoint v, CGPoint w, CGPoint p ) {
	
    const float l2 = length_squared(v, w);  // i.e. |w-v|^2 -  avoid a sqrt
    if (l2 == 0.0) 
		return distance(p, v);   // v == w case
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line. 
    // It falls where t = [(p-v) . (w-v)] / |w-v|^2
    const float t = dotProduct( subVectors(p,v), subVectors(w,v) ) / l2;
    if( t<0.0 )
		return distance(p, v);       // Beyond the 'v' end of the segment
    else if( t>1.0 )
		return distance(p, w);  // Beyond the 'w' end of the segment
    const CGPoint projection = addVectors( v, scaleVector( t, subVectors(w,v)));  // Projection falls on the segment
    return distance(p, projection);
}



#pragma mark -
@implementation PolygonRasterizer

static char pixelBuffer[30][30];
// static int _gridsize = 20;

- (void)setResolution:(NSUInteger)numerator in:(NSUInteger)denominator {
	
}

- (void)setPolygon:(HooPolygon *)poly {
	
	// leak
	_poly = [poly retain];
}

- (void)render {
	
	unsigned char mask_table[] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };

	// TODO: Always transpose the polygon to origin before drawing
	// Of course we will have too have some pixel space for anti aliasing
	
	// Create an image at least big enough to hold with anti-aliasing, take into account resolution tho

	CGRect bounds = [_poly boundsRect];
	NSUInteger width = bounds.size.width;
	NSUInteger height = bounds.size.height;
	
	NSPointerArray *allPts = [_poly pts];
	
	////// woah! temp - test each damn pixel
	// see which are inside
	for( NSUInteger y=0; y<height; y=y+20 ){
		for( NSUInteger x=0; x<width; x=x+20 ){
			double pt[2] = {x,y};
			
			int result = pointinpoly( pt, allPts );
			if(result){
				// Set the least significant bit to indicate it is inside
				pixelBuffer[y/20][x/20] |= mask_table[ 0 ];
			}
		}
	}
	
	// TODO: exclude any that are only partially inside
	// argg, The next stage depends on the previous, but i cant destroy that data,
	// so we need to put the result of this stage in a different bit
	for( NSUInteger y=0; y<30; y=y+1 ){
		for( NSUInteger x=0; x<30; x=x+1 ){
			// test if the pixel is entirely inside (at least if you dont include subpixel detail)
			// ie test each of the 4 corners. There may be a better test - i just donought know
			// this will CRASH if we have an edge pixel - which we must never have!
			if( ((pixelBuffer[y][x] & mask_table[0])!=0) &&

			   ((pixelBuffer[y+1][x+1] & mask_table[0])!=0) &&
			   ((pixelBuffer[y+1][x] & mask_table[0])!=0) &&
			   ((pixelBuffer[y][x+1] & mask_table[0])!=0)
			   )
			{
				// set bit 2 to indicate it is wholly inside
				pixelBuffer[y][x] |= mask_table[ 1 ];
			}
		}
	}
	
	// Calculate the distance of all outside points from the vector 
	for( NSUInteger y=0; y<height; y=y+20 ){
		for( NSUInteger x=0; x<width; x=x+20 ){
			BOOL isInside = ((pixelBuffer[y/20][x/20] & mask_table[1])!=0);
			if(isInside) {
				pixelBuffer[y/20][x/20] = (char)255;
			} else {
                
                NSUInteger numverts = [_poly numverts];
				CGFloat shortestDist = 255;
                for( NSUInteger i=0; i<numverts; i++ )
				{
					NSPointerArray *pts = [_poly pts];
					NSUInteger nextIndex = (i + 1) % numverts;
					CGPoint *pt1 = [pts pointerAtIndex:i];
					CGPoint *pt2 = [pts pointerAtIndex:nextIndex];
					CGPoint p = CGPointMake(x, y);
					CGFloat dist = minimum_distance( *pt1, *pt2, p );
					if(dist<shortestDist){
						shortestDist = dist;
                    }
                }
				NSAssert( shortestDist>=0 && shortestDist<=255, @"value out of bounds" );
				NSUInteger sd = floor(shortestDist);
				unsigned char sdc = sd;
				//NSLog(@"shortestDist = %i, %i", sd, (char)sd);
				pixelBuffer[y/20][x/20] = sdc;
			}
		}
	}
	
}

- (void)drawInContext:(CGContextRef)windowContext  {
	
	CGColorRef whiteCol = CGColorCreateGenericRGB( 1.0f, 1.0f, 1.0f, 1.0f );

	// TODO: This wont do this here, this will just plot each value in the pixel buffer
	for( NSUInteger j=0; j<30; j++ ){
		for( NSUInteger i=0; i<30; i++ ){
			unsigned char val = pixelBuffer[j][i];

			if( val==((unsigned char)255) ) {
				// CGContextSetFillColorWithColor( windowContext, whiteCol );
				// CGContextFillRect( windowContext, CGRectMake( i*20, j*20, 20., 20.));
			} else {
				// Wooooooah
				// Wooooooah
				// Wooooooah
				// Wooooooah stop making fucking colours
				NSUInteger intval = (NSUInteger)val;
				//NSLog(@"printing val %u", intval);
				CGFloat greyVal = intval/255.;
				CGColorRef greyCol = CGColorCreateGenericRGB(greyVal, greyVal, greyVal, 1.0f );
				CGContextSetFillColorWithColor( windowContext, greyCol );
				CGContextFillRect( windowContext, CGRectMake( i*20, j*20, 20., 20.));
				CGColorRelease(greyCol);
			}
		}
	}
	
	CGColorRelease(whiteCol);
}

static int pointinpoly( const double point[2], NSPointerArray *pgon ) {

    int crossings = 0;
    double x = point[X], y = point[Y];
	
	NSUInteger numverts = [pgon count];
    // for (numverts = 0; pgon[numverts][X] != -1 && numverts < MAXVERTS; numverts++) {
        /* just counting the vertexes */
    // }
	
	// Remember shape is closed, ie first pt also appears at the end
    for( NSUInteger i=0; i<(numverts-1); i++ )
	{
		NSUInteger nextIndex = (i+1) % numverts;
		CGPoint *vertexi = [pgon pointerAtIndex:i];
		CGPoint *vertexii = [pgon pointerAtIndex:nextIndex];
		
        double x1=vertexi->x; //pgon[i][X];
        double y1=vertexi->y; //pgon[i][Y];
        double x2=vertexii->x;
        double y2=vertexii->y;
        double d= (y-y1) * (x2-x1) - (x-x1) * (y2-y1);
		
        if ((y1 >= y) != (y2 >= y)) {
            crossings +=y2 - y1 >= 0 ? d >= 0 : d <= 0;
        }
        if (!d && fmin(x1,x2) <= x && x <= fmax(x1,x2)
            && fmin(y1,y2) <= y && y <= fmax(y1,y2)) {
            return 1;
        }
    }
    return crossings & 0x01;
}


@end
