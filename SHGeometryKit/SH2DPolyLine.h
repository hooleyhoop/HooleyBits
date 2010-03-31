//
//  SHPolyLine.h
//  CurveInterpolatyion
//
//  Created by Steve Hooley on 24/01/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class G3DTuple2d;

/*
 * A SH2DPolyLine is a single polyline, therfore you cannot 'moveto' to start a new segment, it cannot be closed (that would be a shape)
*/
@interface SH2DPolyLine : NSObject {

	NSMutableArray* _allPoints;
	BOOL _isEmpty;
}


#pragma mark -
#pragma mark Creating an NSBezierPath object
#pragma mark class methods
+ (SH2DPolyLine*) polyLine;
+ (SH2DPolyLine*) polyLineWithPoint:(G3DTuple2d*)pt;

#pragma mark init methods
- (SH2DPolyLine*) init;
- (SH2DPolyLine*) initWithPoint:(G3DTuple2d*)pt;

#pragma mark action methods
- (void) splitAtU:(double) u into:(SH2DPolyLine*)line1 and:(SH2DPolyLine*) line2;

#pragma mark Constructing paths
- (void) moveToPoint:(G3DTuple2d*)pt; 
- (void) lineToPoint:(G3DTuple2d*)pt;
- (void) relativeLineToPoint:(G3DTuple2d*)pt;  

 -(void) insertPt:(G3DTuple2d*)pt atIndex:(int)i;
 -(int) insertPt:(G3DTuple2d*)pt atU:(double)u;

- (void) removePointAtIndex:(int)i;
- (void) removeAllPoints;

#pragma mark Applying transformations
// – transformUsingAffineTransform:  

#pragma mark Querying paths
- (NSRect) bounds; 
//- (G3DTuple2d*) nearestPoint:(G3DTuple2d*)pt;

- (G3DTuple2d*) getPointFor_u:(float)u; /* u lies between 0 and 1 */
- (NSArray*) get_n_EqualSpacedPointsAlongLength:(int)n;

#pragma mark Accessing elements of a path
- (int) elementCount;  
- (G3DTuple2d*) elementAtIndex:(int)i; 

#pragma mark accessor methods
- (NSArray*) allPoints;
- (double)length;
- (double)lengthOfSegment:(int)segIndex;
- (double)lengthAtU:(double)u;

- (BOOL) isEmpty;




@end
