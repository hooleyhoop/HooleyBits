//
//  SH2DPloyLineTests.m
//  CurveInterpolatyion
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//


//#import "SH2DPolyLine.h"
#include <math.h>
#import "SHGeometryKit.h"


#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>

@interface SH2DPolyLineTests : SenTestCase {
	
}

@end


@implementation SH2DPolyLineTests


// ===========================================================
// - setUp
// ===========================================================
- (void) setUp
{
	// STAssertNotNil(_nodeGraphModel, @"SHNodeTest ERROR.. Couldnt make a nodeModel");
}

// ===========================================================
// - tearDown
// ===========================================================
- (void) tearDown
{
}


//=========================================================== 
// + testPolyLine
//=========================================================== 
- (void) testPolyLine
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	STAssertNotNil(aLine, @"couldnt make a polyline");
}

//=========================================================== 
// + testPolyLineWithPoint
//=========================================================== 
- (void) testPolyLineWithPoint
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLineWithPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertNotNil(aLine, @"couldnt make a polyline");
}


#pragma mark init methods
// ===========================================================
// - testInit
// ===========================================================
- (void) testInit
{
	SH2DPolyLine* aLine = [[SH2DPolyLine alloc] init];
	STAssertNotNil(aLine, @"couldnt make a polyline");
}

// ===========================================================
// - testInitWithPoint
// ===========================================================
- (void) testInitWithPoint
{
	SH2DPolyLine* aLine = [[SH2DPolyLine alloc] initWithPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertNotNil(aLine, @"couldnt make a polyline");
}

#pragma mark action methods
// ===========================================================
// - testSplitAtUInto
// ===========================================================
- (void) testSplitAtUInto
{
	//void splitAtU:(double) u into:(SH2DPolyQuadraticBezier*)line1 and:(SH2DPolyQuadraticBezier*) line2
	SH2DPolyLine* aLine = [[SH2DPolyLine alloc] initWithPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100.0 y:100.0]];
	SH2DPolyLine* line1 = [SH2DPolyLine polyLine]; 
	SH2DPolyLine* line2 = [SH2DPolyLine polyLine];
	[aLine splitAtU:0.5 into:line1 and:line2];

	STAssertTrue((int)[line1 length]==70, @"length is %i but should be %i", (int)[line1 length], 70);
	STAssertTrue((int)[line2 length]==70, @"length is %i but should be %i", (int)[line2 length], 70);
}

#pragma mark Constructing paths
// ===========================================================
// - testMoveToPoint
// ===========================================================
- (void) testMoveToPoint
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:100 y:100]];
}

// ===========================================================
// - testLineToPoint
// ===========================================================
- (void) testLineToPoint
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	// test that we cant have consecutative pts in the same location
	STAssertEquals( [aLine elementCount], 2, @"element count is %i but should be %i", [aLine elementCount], 2);
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertEquals( [aLine elementCount], 2, @"element count is %i but should be %i", [aLine elementCount], 2);
}

// ===========================================================
// - testRelativeLineToPoint
// ===========================================================
- (void) testRelativeLineToPoint
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine relativeLineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	G3DTuple2d* secondPoint = [aLine elementAtIndex:2];
	STAssertTrue([secondPoint elements][0]==200, @"x is %f", [secondPoint elements][0]);
	STAssertTrue([secondPoint elements][1]==200, @"x is %f", [secondPoint elements][1]);
}

// ===========================================================
// - testInsertPoint
// ===========================================================
- (void) testInsertPoint
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine relativeLineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine insertPt:[G3DTuple2d tupleWithX:50 y:50] atIndex:1];
	G3DTuple2d* secondPoint = [aLine elementAtIndex:2];
	STAssertTrue([secondPoint elements][0]==100, @"x is %f", [secondPoint elements][0]);
	STAssertTrue([secondPoint elements][1]==100, @"x is %f", [secondPoint elements][1]);
}


// ===========================================================
// - testInsertPtAtU
// ===========================================================
 -(void) testInsertPtAtU
{
	// -(int) insertPt:(G3DTuple2d*)pt atU:(double)u
	
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:200 y:200]];
	
	/* easy cases */
	int r1 = [aLine insertPt:[G3DTuple2d tupleWithX:200 y:200] atU:0.25];
	int r2 = [aLine insertPt:[G3DTuple2d tupleWithX:200 y:200] atU:0.75];
	
	/* tougher cases */
	int r3 = [aLine insertPt:[G3DTuple2d tupleWithX:200 y:200] atU:0.0];
	int r4 = [aLine insertPt:[G3DTuple2d tupleWithX:200 y:200] atU:0.5];
	int r5 = [aLine insertPt:[G3DTuple2d tupleWithX:200 y:200] atU:0.9];

	STAssertTrue(r1==1, @"index is %i", r1);
	STAssertTrue(r2==3, @"index is %i", r2);
	STAssertTrue(r3==1, @"index is %i", r3);
	STAssertTrue(r4==3, @"index is %i", r4);
	STAssertTrue(r5==5, @"index is %i", r5);
}

// ===========================================================
// - testRemovePointAtIndex
// ===========================================================
- (void) testRemovePointAtIndex
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine relativeLineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertEquals( [aLine elementCount], 3, @"element count is %i but should be %i", [aLine elementCount], 3);
	[aLine removePointAtIndex:0];
	STAssertEquals( [aLine elementCount], 2, @"element count is %i but should be %i", [aLine elementCount], 2);
	[aLine removePointAtIndex:0];
	STAssertEquals( [aLine elementCount], 1, @"element count is %i but should be %i", [aLine elementCount], 1);
	G3DTuple2d* firstPoint = [aLine elementAtIndex:0];
	STAssertTrue([firstPoint elements][0]==200, @"x is %f", [firstPoint elements][0]);
	STAssertTrue([firstPoint elements][1]==200, @"x is %f", [firstPoint elements][1]);
	[aLine removePointAtIndex:0];
	STAssertEquals( [aLine elementCount], 0, @"element count is %i but should be %i", [aLine elementCount], 0);
	STAssertTrue([aLine isEmpty], @"line should not be empty");
}

// ===========================================================
// - testRemoveAllPoints
// ===========================================================
- (void) testRemoveAllPoints
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine removeAllPoints];
	STAssertTrue([aLine isEmpty], @"line should not be empty");
}

#pragma mark Querying paths
// ===========================================================
// - testBounds
// ===========================================================
- (void) testBounds
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:10 y:10]];
	NSRect bounds = [aLine bounds];
	STAssertTrue(bounds.origin.x==10, @"bounds error");
	STAssertTrue(bounds.origin.y==10, @"bounds error");
	STAssertTrue(bounds.size.width==0, @"bounds error");
	STAssertTrue(bounds.size.height==0, @"bounds error");
	[aLine lineToPoint:[G3DTuple2d tupleWithX:-100 y:-100]];
	bounds = [aLine bounds];
	STAssertTrue(bounds.origin.x==-100, @"bounds error");
	STAssertTrue(bounds.origin.y==-100, @"bounds error");
	STAssertTrue(bounds.size.width==110, @"bounds error is%f",bounds.size.width);
	STAssertTrue(bounds.size.height==110, @"bounds error is %f",bounds.size.height);	
}


// ===========================================================
// - testGetPointFor_u
// ===========================================================
- (void) testGetPointFor_u
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	// try a simple case from 0 to 100
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	G3DTuple2d* pt = [aLine getPointFor_u:0.5];
	STAssertTrue([pt elements][0]==50, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==50, @"x is %f", [pt elements][1]);
	pt = [aLine getPointFor_u:0];
	STAssertTrue([pt elements][0]==0, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==0, @"x is %f", [pt elements][1]);
	pt = [aLine getPointFor_u:1.0];
	STAssertTrue([pt elements][0]==100, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==100, @"x is %f", [pt elements][1]);	
	// try more complicated negative values
	[aLine removeAllPoints];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:-10 y:-10]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:10 y:10]];
	pt = [aLine getPointFor_u:0.5];
	STAssertTrue([pt elements][0]==0, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==0, @"x is %f", [pt elements][1]);
}

// ===========================================================
// - testGet_n_EqualSpacedPointsAlongLength
// ===========================================================
- (void) testGet_n_EqualSpacedPointsAlongLength
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	// try a simple case from 0 to 100
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	NSArray* allPts =  [aLine get_n_EqualSpacedPointsAlongLength:3];
	G3DTuple2d* pt = [allPts objectAtIndex:0];
	STAssertTrue([pt elements][0]==0, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==0, @"x is %f", [pt elements][1]);
	pt = [allPts objectAtIndex:1];
	STAssertTrue([pt elements][0]==50, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==50, @"x is %f", [pt elements][1]);
	pt = [allPts objectAtIndex:2];
	STAssertTrue([pt elements][0]==100, @"x is %f", [pt elements][0]);
	STAssertTrue([pt elements][1]==100, @"x is %f", [pt elements][1]);
}


#pragma mark Accessing elements of a path
// ===========================================================
// - testElementCount
// ===========================================================
- (void) testElementCount
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	STAssertEquals( [aLine elementCount], 1, @"element count is %i but should be %i", [aLine elementCount], 1);
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertEquals( [aLine elementCount], 2, @"element count is %i but should be %i", [aLine elementCount], 2);
}

// ===========================================================
// - testElementAtIndex
// ===========================================================
- (void) testElementAtIndex
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:1]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:25 y:100]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:1520 y:987]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:999 y:4045]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:36 y:72]];
	G3DTuple2d* thirdPoint = [aLine elementAtIndex:3];
	STAssertTrue([thirdPoint elements][0]==1520, @"x is %f", [thirdPoint elements][0]);
	STAssertTrue([thirdPoint elements][1]==987, @"x is %f", [thirdPoint elements][1]);
}

#pragma mark accessor methods

// ===========================================================
// - testLength
// ===========================================================
- (void) testLength
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:45.0 y:45.0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:85.0 y:85.0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	double length = [aLine length];
	double lengthShouldBe = sqrt(100*100+100*100);
	STAssertTrue(length==lengthShouldBe, @"length is %f but should be %f", length, lengthShouldBe);
}

// ===========================================================
// - testLengthOfSegment
// ===========================================================
- (void) testLengthOfSegment
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:200 y:200]];
	
	// segments are numbered 0,1,2,3,4 etc.
	double lengthOfSeg = [aLine lengthOfSegment:1];
	STAssertTrue(lengthOfSeg==sqrt(SQR(100)+SQR(100)), @"length is %f but should be %f", lengthOfSeg, sqrt(SQR(100)+SQR(100)));
}

// ===========================================================
// - testLengthAtU
// ===========================================================
- (void) testLengthAtU
{
	// - (double)lengthAtU:(double)u

	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:0 y:0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:45.0 y:45.0]];
	[aLine lineToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	double length = [aLine length];
	STAssertTrue([aLine lengthAtU:0.0]==0.0, @"length is %f but should be %f", [aLine lengthAtU:0.0], 0);
	STAssertTrue([aLine lengthAtU:1.0]==length, @"length is %f but should be %f", [aLine lengthAtU:1.0], length);
	STAssertTrue([aLine lengthAtU:0.5]==length/(double)2, @"length is %f but should be %f", [aLine lengthAtU:0.5], length/(double)2);
}

// ===========================================================
// - testIsEmpty
// ===========================================================
- (void) testIsEmpty
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	[aLine moveToPoint:[G3DTuple2d tupleWithX:100 y:100]];
	STAssertFalse([aLine isEmpty], @"line should not be empty");
}



@end
