//
//  SH2dPolyQuadraticTests.m
//  SHGeometryKit
//
//  Created by Steve Hooley on 07/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2dPolyQuadraticTests.h"
#import "SHGeometryKit.h"
#import "SH2DPolyQuadraticBezier.h"
#import "SH2dBezierPt.h"

/*
 *
*/
@implementation SH2dPolyQuadraticTests


// ===========================================================
// - setUp
// ===========================================================
- (void) setUp
{
}

// ===========================================================
// - tearDown
// ===========================================================
- (void) tearDown
{
}

// ===========================================================
// - testPolyQuadraticBezier
// ===========================================================
- (void) testPolyQuadraticBezier
{
	SH2DPolyQuadraticBezier *quadLine = [SH2DPolyQuadraticBezier polyQuadraticBezier];
	STAssertNotNil(quadLine, @"shouldnt be nil");
}

// ===========================================================
// - testpolyQuadraticBezierWithPoint
// ===========================================================
- (void) testpolyQuadraticBezierWithPoint
{
	SH2dBezierPt* qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [SH2DPolyQuadraticBezier polyQuadraticBezierWithPoint:qp1];
	STAssertNotNil(quadLine, @"shouldnt be nil");
}

#pragma mark init methods
// ===========================================================
// - testinit
// ===========================================================
- (void) testinit
{
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] init] autorelease];
	STAssertNotNil(quadLine, @"shouldnt be nil");
	STAssertTrue([quadLine isEmpty], @"line should be empty");
}

// ===========================================================
// - testInitWithPoint
// ===========================================================
- (void) testInitWithPoint
{
	id qp1 = [[[SH2dBezierPt alloc] initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	STAssertNotNil(quadLine, @"shouldnt be nil");
	STAssertFalse([quadLine isEmpty], @"line should not be empty");
}

#pragma mark action methods
#pragma mark Constructing paths
// ===========================================================
// - testmoveToPoint
// ===========================================================
- (void) testmoveToPoint
{
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] init] autorelease];
	SH2dBezierPt* qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	[quadLine moveToPoint:qp1];
	STAssertTrue([quadLine elementCount]==1, @"should only be 1 pt");
	STAssertTrue([quadLine length]==0.00, @"should be zero length");
	NSArray* allPoints = [quadLine allPoints];
	STAssertTrue([allPoints count]==1, @"should only be 1 pt");
	SH2dBezierPt* qp2 = [allPoints objectAtIndex:0];
	STAssertTrue([qp1 isEqualToBezierPt:qp2], @"these pts should be equal");
}

// ===========================================================
// - testlineToPoint
// ===========================================================
- (void) testlineToPoint
{
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] init] autorelease];
	SH2dBezierPt* qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	[quadLine moveToPoint:qp1];
	G3DTuple2d* tup2 = [G3DTuple2d tupleWithX:100 y:100];
	[quadLine lineToPoint:tup2];
	STAssertTrue([quadLine elementCount]==2, @"should only be 2 pt");
	STAssertTrue([quadLine length]>100.00, @"length should be over 100 but is %f", [quadLine length]);
}

// ===========================================================
// - testcurveToPoint
// ===========================================================
- (void) testcurveToPoint
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	SH2dBezierPt* qp2 = [[[SH2dBezierPt alloc]initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	SH2dBezierPt* qp3 = [[[SH2dBezierPt alloc]initWithBpX:75 bpY:420 cntrlPtX:150 cntrlPtY:10] autorelease];
	[quadLine curveToPoint:qp2];
	[quadLine curveToPoint:qp3];
	STAssertTrue([quadLine elementCount]==3, @"should only be 3 pt");
}

// ===========================================================
// - testcurveToPoint2
// ===========================================================
- (void) testcurveToPoint2
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	STAssertTrue([quadLine elementCount]==3, @"should only be 3 pt");
}

// not nesasrily making sense at the moment like it does in a line - pretty unnessary at the moment
// - (void) relativeLineToPoint:(SH2dBezierPt*)pt;  
// ===========================================================
// - testInsertPt
// ===========================================================
- (void) testInsertPt
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];

	id qp2 = [[[SH2dBezierPt alloc]initWithBpX:300 bpY:300 cntrlPtX:200 cntrlPtY:200] autorelease];
	[quadLine insertPt:qp2 atIndex:1];
	STAssertTrue([quadLine elementCount]==4, @"should only be 4 pt");
}

// ===========================================================
// - testremovePointAtIndex
// ===========================================================
- (void) testremovePointAtIndex
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	[quadLine removePointAtIndex:0];
	STAssertTrue([quadLine elementCount]==2, @"should only be 2 pt");
	STAssertFalse([quadLine isEmpty], @"line should not be empty");
}


// ===========================================================
// - testremoveAllPoints
// ===========================================================
- (void) testremoveAllPoints
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	[quadLine removeAllPoints];
	STAssertTrue([quadLine elementCount]==0, @"should only be 0 pt");
	STAssertTrue([quadLine isEmpty], @"line should not be empty");
}

#pragma mark Querying paths
// ===========================================================
// - testBounds
// ===========================================================
- (void) testBounds
{
	// test like a line segment
	SH2DPolyQuadraticBezier* aLine = [SH2DPolyQuadraticBezier polyQuadraticBezier];
	
	[aLine moveToPoint:[SH2dBezierPt bezPtWithBasePt:[G3DTuple2d tupleWithX:0.0 y:0.0]]];
	[aLine curveToPoint:[SH2dBezierPt bezPtWithBasePt:[G3DTuple2d tupleWithX:0.0 y:100.0]]];
	[aLine curveToPoint:[SH2dBezierPt bezPtWithBasePt:[G3DTuple2d tupleWithX:100.0 y:100.0]]];
	[aLine curveToPoint:[SH2dBezierPt bezPtWithBasePt:[G3DTuple2d tupleWithX:100.0 y:0.0]]];
	NSRect bounds = [aLine bounds];
	
	STAssertTrue(bounds.origin.x==0.0, @"is %f", bounds.origin.x);
	STAssertTrue(bounds.origin.y==0.0, @"is %f", bounds.origin.y);
	STAssertTrue(bounds.size.width==100.0, @"is %f", bounds.size.width);
	STAssertTrue(bounds.size.height==100.0, @"is %f", bounds.size.height);
	[aLine curveToPoint:[SH2dBezierPt bezPtWithBasePt:[G3DTuple2d tupleWithX:-100.0 y:-100.0]]];
	bounds = [aLine bounds];
	STAssertTrue(bounds.origin.x==-100.0, @"bounds error");
	STAssertTrue(bounds.origin.y==-100.0, @"bounds error");
	STAssertTrue(bounds.size.width==200.0, @"bounds error is%f",bounds.size.width);
	STAssertTrue(bounds.size.height==200.0, @"bounds error is %f",bounds.size.height);	
	
	// test like a curve segment
	aLine = [SH2DPolyQuadraticBezier polyQuadraticBezier];
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:0.0 cntrlPtY:100] autorelease];
	[aLine moveToPoint:qp1];
	
	[aLine curveToPoint:[G3DTuple2d tupleWithX:100.0 y:100.0] cntrlPt:[G3DTuple2d tupleWithX:100.0 y:0]];
	bounds = [aLine bounds];
	STAssertTrue(bounds.origin.x==0.0, @"bounds error");
	STAssertTrue(bounds.origin.y==0.0, @"bounds error");
	STAssertTrue(bounds.size.width==100.0, @"bounds error");
	STAssertTrue(bounds.size.height==100.0, @"bounds error");
	[aLine curveToPoint:[G3DTuple2d tupleWithX:-100.0 y:-100.0] cntrlPt:[G3DTuple2d tupleWithX:-50.0 y:-50.0]];
	bounds = [aLine bounds];
	STAssertTrue(bounds.origin.x==-100.0, @"bounds error");
	STAssertTrue(bounds.origin.y==-100.0, @"bounds error");
	STAssertTrue(bounds.size.width==200.0, @"bounds error is%f",bounds.size.width);
	STAssertTrue(bounds.size.height==200.0, @"bounds error is %f",bounds.size.height);	
}

// ===========================================================
// - testeval_quadr_bezier_spline
// ===========================================================
- (void) testeval_quadr_bezier_spline
{
	/* hmm, could be a private method */
	NSMutableArray* results = [NSMutableArray arrayWithCapacity:10];
	int i, count = 10;
	for(i=0;i<<count;i++){
		double result = eval_quadr_bezier_spline(i/10.0, 0.0, 50.0, 100.0);
		[results addObject:[NSNumber numberWithDouble:result]];
	}
	NSEnumerator* en = [results objectEnumerator];
	NSNumber* num;
	double x = -1.0;
	while(num=[en nextObject])
	{
		STAssertTrue([num doubleValue]>x, @"should be increasing");	
		x =[num doubleValue];
	}
}

// ===========================================================
// - testgetPointFor_u
// ===========================================================
- (void) testgetPointFor_u
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	
	G3DTuple2d* pt1 = [quadLine getPointFor_u:0.1];
	G3DTuple2d* pt2 = [quadLine getPointFor_u:0.5];
	G3DTuple2d* pt3 = [quadLine getPointFor_u:0.9];
	
	// dont know how to test yet
	STAssertTrue([pt1 x]>0, @"should be increasing");
	STAssertTrue([pt1 y]>0, @"should be increasing");
	STAssertTrue([pt2 x]>0, @"should be increasing");
	STAssertTrue([pt2 y]>0, @"should be increasing");
	STAssertTrue([pt3 x]>0, @"should be increasing");
	STAssertTrue([pt3 y]>0, @"should be increasing");
}

// ===========================================================
// - testGetPolyLineWithNParametricPoints
// ===========================================================
- (void) testGetPolyLineWithNParametricPoints
{
	/* Method 1 */
	
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	
	SH2DPolyLine* pl = [quadLine getPolyLineWithNParametricPoints:5];
	STAssertNotNil(pl, @"shouldnt be nil");
	STAssertTrue([pl elementCount]==5, @"should be 5 pts");	
}

// ===========================================================
// - testgetPolyLineWithMaxSegmentLength
// ===========================================================
- (void) testgetPolyLineWithMaxSegmentLength
{
	/* Method 2 */

	// - (SH2DPolyLine*) getPolyLineWithMaxSegmentLength:(double)l
	STFail(@"NOT DONE YET");
}

// ===========================================================
// - testGetPolyLineWithNEqualSpacedPoints
// ===========================================================
- (void) testGetPolyLineWithNEqualSpacedPoints
{
	/* Method 3 */

	// - (SH2DPolyLine*) getPolyLineWithNEqualSpacedPoints:(int)n
	STFail(@"NOT DONE YET");
}

// ===========================================================
// - testrecursive_QuadraticBezier
// ===========================================================
- (void) testrecursive_QuadraticBezier
{
// static void recursive_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, SH2DPolyLine* resultLine, double l )
	SH2DPolyLine* aPolyLine =  [SH2DPolyLine polyLine];
	recursive_QuadraticBezier( 0.0, 0.0,  50.0, 50.0, 100.0, 100.0, aPolyLine, 5.0); // send a ptr?
	NSArray* allPoints = [aPolyLine allPoints];
	int count = [allPoints count];
	STAssertTrue(count>10, @"is %i", count);
	double l = [aPolyLine lengthOfSegment:1];
	STAssertTrue(l<5.0, @"is %f", l);

	STAssertTrue([(G3DTuple2d*)[allPoints objectAtIndex:0] x]==0.0, @"is %f", [(G3DTuple2d*)[allPoints objectAtIndex:0] x]);
	STAssertTrue([(G3DTuple2d*)[allPoints objectAtIndex:0] y]==0.0, @"is %f", [(G3DTuple2d*)[allPoints objectAtIndex:0] y]);
	STAssertTrue([(G3DTuple2d*)[allPoints objectAtIndex:count-1] x]==100.0, @"is %f", [(G3DTuple2d*)[allPoints objectAtIndex:count-1] x]);
	STAssertTrue([(G3DTuple2d*)[allPoints objectAtIndex:count-1] y]==100.0, @"is %f", [(G3DTuple2d*)[allPoints objectAtIndex:count-1] y]);
}

// ===========================================================
// - testsplit_QuadraticBezier
// ===========================================================
- (void) testsplit_QuadraticBezier
{
// static void split_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, double u, double* outputArray12 )	
	double outpts[12];
	split_QuadraticBezier( 0.0, 0.0,  50.0, 50.0, 100.0, 100.00, 0.5, outpts); // send a ptr?
	STAssertTrue(outpts[0]==0.0, @"is %f", outpts[0]);
	STAssertTrue(outpts[1]==0.0, @"is %f", outpts[1]);
	
	STAssertTrue(outpts[4]==50.0, @"is %f", outpts[4]);
	STAssertTrue(outpts[5]==50.0, @"is %f", outpts[5]);

	STAssertTrue(outpts[6]==50.0, @"is %f", outpts[6]);
	STAssertTrue(outpts[7]==50.0, @"is %f", outpts[7]);
	
	STAssertTrue(outpts[10]==100.0, @"is %f", outpts[10]);
	STAssertTrue(outpts[11]==100.0, @"is %f", outpts[11]);
}


#pragma mark Accessing elements of a path
// ===========================================================
// - testelementCount
// ===========================================================
- (void) testelementCount
{
	// - (int) elementCount; 
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	STAssertTrue([quadLine elementCount]==3, @"line should not be empty");
	[quadLine removeAllPoints];
	STAssertTrue([quadLine elementCount]==0, @"line should not be empty");
}

// ===========================================================
// - testelementAtIndex
// ===========================================================
- (void) testelementAtIndex
{
	//- (SH2dBezierPt*) elementAtIndex:(int)i; 
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	SH2dBezierPt* pt1 = [quadLine elementAtIndex:1]; 
	G3DTuple2d* bp = [pt1 bPoint];
	G3DTuple2d* cp = [pt1 cntrlPoint];
	STAssertTrue([bp x]==100, @"line should not be empty");
	STAssertTrue([bp y]==100, @"line should not be empty");
	STAssertTrue([cp x]==150, @"line should not be empty");
	STAssertTrue([cp y]==150, @"line should not be empty");	
}

#pragma mark accessor methods
// ===========================================================
// - testallPoints
// ===========================================================
- (void) testallPoints
{
	// - (NSArray*) allPoints;
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	id qp2 = [[[SH2dBezierPt alloc]initWithBpX:100 bpY:100 cntrlPtX:150 cntrlPtY:150] autorelease];
	id qp3 = [[[SH2dBezierPt alloc]initWithBpX:200 bpY:200 cntrlPtX:250 cntrlPtY:250] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:qp2];
	[quadLine curveToPoint:qp3];
	
	NSArray* allPoints = [quadLine allPoints];
	STAssertTrue([[allPoints objectAtIndex:0] isEqualToBezierPt:qp1], @"line should not be empty");	
	STAssertTrue([[allPoints objectAtIndex:1] isEqualToBezierPt:qp2], @"line should not be empty");	
	STAssertTrue([[allPoints objectAtIndex:2] isEqualToBezierPt:qp3], @"line should not be empty");	
}

// ===========================================================
// - testlength
// ===========================================================
- (void) testlength
{
	//- (double)length;
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:2.0 cntrlPtY:2.0] autorelease];
	id qp2 = [[[SH2dBezierPt alloc]initWithBpX:100 bpY:100 cntrlPtX:102 cntrlPtY:102] autorelease];
	id qp3 = [[[SH2dBezierPt alloc]initWithBpX:200 bpY:200 cntrlPtX:202 cntrlPtY:202] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:qp2];
	[quadLine curveToPoint:qp3];
	
	double l1 = [quadLine lengthOfSegment:0];
	double l2 = [quadLine lengthOfSegment:1];
	double l3 = [quadLine length];
	double l4 = l1+l2;
	double approxLength = sqrt((100*100)+(100*100));
	STAssertTrue(l3==approxLength*2, @"%f is %f", approxLength*2, (float)l2);	
	STAssertTrue(l3>200 && l3<300, @"%f is %f", approxLength, (float)l3);	
}

// ===========================================================
// - testlengthOfSegment
// ===========================================================
- (void) testlengthOfSegment
{
	// - (double)lengthOfSegment:(int)secIndex;
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:2 cntrlPtY:2] autorelease];
	id qp2 = [[[SH2dBezierPt alloc]initWithBpX:100 bpY:100 cntrlPtX:102 cntrlPtY:102] autorelease];
	id qp3 = [[[SH2dBezierPt alloc]initWithBpX:200 bpY:200 cntrlPtX:202 cntrlPtY:202] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:qp2];
	[quadLine curveToPoint:qp3];
	double l = [quadLine lengthOfSegment:0];
	double approxLength = sqrt((100*100)+(100*100));
	STAssertTrue(l>140 && l<150, @"%f is %f", approxLength, (float)l);
	
	l = [quadLine lengthOfSegment:1];
	STAssertTrue(l>140 && l<150, @"%f is %f", approxLength, (float)l);	
}


// ===========================================================
// - testLineApproximationOfCurveSegment
// ===========================================================
- (void) testLineApproximationOfCurveSegment
{
	// SH2DPolyLine* lineApproximationOfCurveSegment( SH2dBezierPt *bez1, SH2dBezierPt *bez2,  int numberOfSegments )
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:2 cntrlPtY:2] autorelease];
	id qp2 = [[[SH2dBezierPt alloc]initWithBpX:100 bpY:100 cntrlPtX:102 cntrlPtY:102] autorelease];
	SH2DPolyLine* pl = lineApproximationOfCurveSegment(qp1, qp2, 5 );

	STAssertTrue([pl elementCount]==6, @"is %i", [pl elementCount]);
}

// ===========================================================
// - testisEmpty
// ===========================================================
- (void) testisEmpty
{
	id qp1 = [[[SH2dBezierPt alloc]initWithBpX:0 bpY:0 cntrlPtX:30 cntrlPtY:30] autorelease];
	SH2DPolyQuadraticBezier *quadLine = [[[SH2DPolyQuadraticBezier alloc] initWithPoint:qp1] autorelease];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:100 y:100] cntrlPt:[G3DTuple2d tupleWithX:150 y:150]];
	[quadLine curveToPoint:[G3DTuple2d tupleWithX:200 y:200] cntrlPt:[G3DTuple2d tupleWithX:250 y:250]];
	STAssertFalse([quadLine isEmpty], @"line should not be empty");
	[quadLine removeAllPoints];
	STAssertTrue([quadLine isEmpty], @"line should be empty");
}


@end
