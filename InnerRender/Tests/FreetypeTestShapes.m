//
//  FreetypeTestShapes.m
//  InnerRender
//
//  Created by Steven Hooley on 14/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "FreetypeTestShapes.h"
#import "ftmisc.h"
#import "ftimage.h"
#import "HoboMaths.h"

@implementation FreetypeTestShapes

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

struct FT_Outline_ *allocSpaceForShape( int numberOfContours, int numberOfPts ) {
    
    struct FT_Outline_ *outline = calloc( 1, sizeof(struct FT_Outline_) );
    struct  FT_Vector_ *pts = calloc( numberOfPts, sizeof(struct  FT_Vector_) );
    char *ptTags = calloc( numberOfContours, 1 );
    short *contours = calloc( numberOfContours, sizeof(short) );
    // fill in pts
    // fill in tags
    // fill in contours
    outline->points = pts;
    outline->tags = ptTags;
    outline->contours = contours;
    outline->n_contours = numberOfContours;
    outline->n_points = numberOfPts;
    outline->flags = 0;
    return outline;
}

void freeSpaceForShape( struct FT_Outline_ *outline ) {
    
    free( outline->points ); outline->points = NULL;
    free( outline->tags ); outline->tags = NULL;
    free( outline->contours ); outline->contours = NULL;
    outline->n_contours = 0;
    outline->n_points = 0;
    free(outline);
}

struct FT_Outline_ *makeSimplePoly() {
    
    int contourCount = 1;
    int points = 4;    
    struct FT_Outline_ *outline = allocSpaceForShape( contourCount, points );
    
    /* Populate the regular glyph Points array */
    outline->points[0].x = 0 *64;
    outline->points[0].y = 0 *64;
    
    outline->points[1].x = 300 *64;
    outline->points[1].y = 20 *64;
    
    outline->points[2].x = 399 *64 ;
    outline->points[2].y = 399 *64;
    
    outline->points[3].x = 20 *64;
    outline->points[3].y = 350 *64;
	
	// bit 0 = on curve or not
	// if bit 0==0, ie. is off curve, ie, is control pt, bit 1=third-order Bézier arc control point if set (postscript), and a second-order control point if unset (truetype). 
    // If bit~2 is set, bits 5-7 contain the drop-out mode
	// Bits 3 and~4 are reserved for internal purposes
	outline->tags[0] = 1; 
    outline->tags[1] = 1;
    outline->tags[2] = 1;
    outline->tags[3] = 1;
    
    outline->contours[0] = points-1; // shape 0 is pt 0 to contour[0], shape 1 is the next pt to contour[1]

    //outline.flags = FT_OUTLINE_HIGH_PRECISION; //0x104 ? // FT_OUTLINE_OWNER, FT_OUTLINE_EVEN_ODD_FILL (only smooth rasterizer), FT_OUTLINE_REVERSE_FILL, FT_OUTLINE_HIGH_PRECISION, FT_OUTLINE_SINGLE_PASS, etc
    
    return outline;
}

// you need to release the poly
struct FT_Outline_ *makeSegmentedCirclePoly() {
    
    int contourCount = 1;
    int lineSegments = 100;
    //int ptCount = lineSegments-1; // assuming auto closed    
    struct FT_Outline_ *complexOutLine = allocSpaceForShape( contourCount, lineSegments );
    
    // fill in some points - for a closed shape
    complexOutLine->contours[0] = lineSegments-1;
    float angle = (360.0f/lineSegments);
    
    float rad = 100.0f;
    float centrex = 200, centrey = 200;
    
    // for 4 sections, add start, assuming contour is automatically closed, so we miss off the last point
    // ie n pts gives n+1 sections (assuming it is closed automatically - verify this)
    for( int i=0; i<lineSegments; i++ ) {
        float theta = i*angle;
        float x, y;
        polarDegreesToCart( rad, theta, &x, &y );
        NSLog(@"x>%f, y>%f",x,y);
		complexOutLine->points[i].x = 64*(x+centrex);
		complexOutLine->points[i].y = 64*(y+centrey);
        complexOutLine->tags[i] = 1;
    }
    
    return complexOutLine;
}

@end
