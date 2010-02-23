//
//  SHPolyLine.h
//  CurveInterpolatyion
//
//  Created by Steve Hooley on 24/01/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class G3DTuple2d, SH2DPolyLine;

/*
 * A SH2DPolyQuadraticBezier is a single polyline, therfore you cannot 'moveto' to start a new segment, it cannot be closed (that would be a shape)
 *
 * In a single segment the control point belongs to the first pt
*/
@class SH2dBezierPt;
@interface SH2DPolyQuadraticBezier : NSObject {

	NSMutableArray* _allPoints;
	BOOL _isEmpty; // change this to number of points!
}


#pragma mark -
#pragma mark Creating an NSBezierPath object
#pragma mark class methods
+ (SH2DPolyQuadraticBezier*) polyQuadraticBezier;
+ (SH2DPolyQuadraticBezier*) polyQuadraticBezierWithPoint:(SH2dBezierPt*)pt;

#pragma mark init methods
- (SH2DPolyQuadraticBezier*) init;
- (SH2DPolyQuadraticBezier*) initWithPoint:(SH2dBezierPt*)pt;

#pragma mark action methods
#pragma mark Constructing paths
- (void) moveToPoint:(SH2dBezierPt*)pt; /* watch out for differences in SH2dBezierPt arguments and G3DTuple2d arguments */

- (void) lineToPoint:(G3DTuple2d*)pt;

- (void) curveToPoint:(SH2dBezierPt*)pt;
- (void) curveToPoint:(G3DTuple2d*)bPt cntrlPt:(G3DTuple2d*)cPt;


// not nesasrily making sense at the moment like it does in a line - pretty unnessary at the moment
// - (void) relativeLineToPoint:(SH2dBezierPt*)pt;  

 -(void) insertPt:(SH2dBezierPt*)pt atIndex:(int)i;

- (void) removePointAtIndex:(int)i;
- (void) removeAllPoints;

#pragma mark Applying transformations
// transformUsingAffineTransform:  

#pragma mark Querying paths
- (NSRect) bounds; 
//- (G3DTuple2d*) nearestPoint:(G3DTuple2d*)pt;

double eval_quadr_bezier_spline(double u,double xa,double xb,double xc);

/* parametric interpolation - points will not be equally spaced in distance */
- (G3DTuple2d*) getPointFor_u:(float)u; /* u lies between 0 and 1 */

/* Method 1 */
/* gets n points for equal spaced values of u - the points will not be equally spaced tho */
- (SH2DPolyLine*) getPolyLineWithNParametricPoints:(int)n;

/* Method 2 */
/* Keeps subdividing segments until each segment is no longer than l */
- (SH2DPolyLine*) getPolyLineWithMaxSegmentLength:(double)l;

/* Method 3 */
/* tries to work out how to space parameters u so that each segment is equal length */
- (SH2DPolyLine*) getPolyLineWithNEqualSpacedPoints:(int)n;

// G3DTuple2d* getPtOnQuadraticBezierAtU( G3DTuple2d* bp1, G3DTuple2d* cntrl1, G3DTuple2d* bp2, double u);

#pragma mark utility
/* before you call this with a SH2DPolyLine make sure you have already moved to the first point */
void recursive_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, SH2DPolyLine* resultLine, double l );

- (void) splitAtU:(double)u into:(SH2DPolyQuadraticBezier*)line1 and:(SH2DPolyQuadraticBezier*) line2;

void split_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, double u, double* outputArray12 );

SH2DPolyLine* lineApproximationOfCurveSegment( SH2dBezierPt *bez1, SH2dBezierPt *bez2,  int numberOfSegments );

#pragma mark Accessing elements of a path
- (int) elementCount;  
- (SH2dBezierPt*) elementAtIndex:(int)i; 

#pragma mark accessor methods
- (NSArray*) allPoints;
- (double)length;
- (double)lengthOfSegment:(int)secIndex;
- (double)lengthAtU:(double)u;

- (BOOL) isEmpty;


@end
