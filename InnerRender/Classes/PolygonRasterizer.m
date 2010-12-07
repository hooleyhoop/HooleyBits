//
//  PolygonRasterizer.m
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "PolygonRasterizer.h"
#import "HooPolygon.h"


static char distanceFromVector(){
	return (char)100;
}


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
	
	////// woah! temp - test each damn pixel
	// see which are inside
	for( NSUInteger y=0; y<height; y=y+20 ){
		for( NSUInteger x=0; x<width; x=x+20 ){
			double pt[2] = {x,y};
			int result = pointinpoly( pt, [_poly pts] );
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
				NSLog(@"Inside %i", (int)(y/20));
			} else {
				pixelBuffer[y/20][x/20] = distanceFromVector();
			}
		}
	}
	
}

- (void)drawInContext:(CGContextRef)windowContext  {
	
	CGColorRef whiteCol = CGColorCreateGenericRGB( 1.0f, 1.0f, 1.0f, 1.0f );
	CGColorRef greyCol = CGColorCreateGenericRGB( 1.0f, 0.5f, 0.5f, 1.0f );

	// TODO: This wont do this here, this will just plot each value in the pixel buffer
	for( NSUInteger j=0; j<30; j++ ){
		for( NSUInteger i=0; i<30; i++ ){
			char val = pixelBuffer[j][i];
			NSLog(@"vale %i", val);
			if( val==((char)255) ) {
				CGContextSetFillColorWithColor( windowContext, whiteCol );
				CGContextFillRect( windowContext, CGRectMake( i*20, j*20, 20., 20.));
				// NSLog(@"yesy");
			} else {
				CGContextSetFillColorWithColor( windowContext, greyCol );
	//			CGContextFillRect( windowContext, CGRectMake( i*20, j*20, 20., 20.));
//				NSLog(@"No");
			}
		}
	}

	// TODO: Now draw the anti aliased pixels
	
	
	CGColorRelease(whiteCol);
	CGColorRelease(greyCol);
}

static int pointinpoly( const double point[2], double pgon[MAXVERTS][2] ) {

    int i, numverts, crossings = 0;
    double x = point[X], y = point[Y];
	
    for (numverts = 0; pgon[numverts][X] != -1 && numverts < MAXVERTS;
		 numverts++) {
        /* just counting the vertexes */
    }
	
    for (i = 0; i < numverts; i++) {
        double x1=pgon[i][X];
        double y1=pgon[i][Y];
        double x2=pgon[(i + 1) % numverts][X];
        double y2=pgon[(i + 1) % numverts][Y];
        double d=(y - y1) * (x2 - x1) - (x - x1) * (y2 - y1);
		
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
