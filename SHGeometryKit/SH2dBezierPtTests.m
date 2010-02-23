//
//  SH2dBezierPtTests.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 06/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2dBezierPtTests.h"
#import "SHGeometryKit.h"

@implementation SH2dBezierPtTests


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

//=========================================================== 
//  testInitWithBasePt
//=========================================================== 
- (void) testInitWithBasePt
{
	G3DTuple2d *p1 = [G3DTuple2d tupleWithX:100 y:1100];
	SH2dBezierPt* bpt = [[[SH2dBezierPt alloc] initWithBasePt:p1] autorelease];
	STAssertNotNil(bpt, @"shouldnt be nil");
}


//=========================================================== 
//  testInitWithBasePtAndCntrlPt
//===========================================================
- (void) testInitWithBasePtAndCntrlPt
{
	G3DTuple2d *p1 = [G3DTuple2d tupleWithX:100 y:1100];
	G3DTuple2d *p2 = [G3DTuple2d tupleWithX:200 y:200];
	SH2dBezierPt* bpt = [[[SH2dBezierPt alloc] initWithBasePt:p1 CntrlPt:p2] autorelease];
	STAssertNotNil(bpt, @"shouldnt be nil");
}

//=========================================================== 
//  testInitWithBasePpXAndBpY
//=========================================================== 
- (void) testInitWithBasePpXAndBpY
{
	SH2dBezierPt* bpt = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100] autorelease];
	STAssertNotNil(bpt, @"shouldnt be nil");
}

//=========================================================== 
//  testInitWithBasePpXAndBpYcntrlPtXcntrlPtY
//=========================================================== 
- (void) testInitWithBasePpXAndBpYcntrlPtXcntrlPtY
{
	SH2dBezierPt* bpt = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	STAssertNotNil(bpt, @"shouldnt be nil");
}

//=========================================================== 
//  testIsEqualToBezierPt
//=========================================================== 
- (void) testIsEqualToBezierPt
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	SH2dBezierPt* bpt2 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];

	STAssertTrue([bpt1 isEqualToBezierPt:bpt2], @"should be equal");
}

//=========================================================== 
//  testcopyWithZone
//=========================================================== 
- (void) testcopyWithZone
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	SH2dBezierPt* bpt2 = [bpt1 copy];
	STAssertTrue([bpt1 isEqualToBezierPt:bpt2], @"should be equal");
}

//=========================================================== 
//  testsetBPoint
//=========================================================== 
- (void) testsetBPoint
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	G3DTuple2d *p1 = [G3DTuple2d tupleWithX:50 y:50];
	[bpt1 setBPoint:p1];
	STAssertTrue([[bpt1 bPoint] isEqualToTuple:p1], @"should be equal");
}

//=========================================================== 
//  testcntrlPoint
//===========================================================
- (void) testcntrlPoint
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	G3DTuple2d *p1 = [G3DTuple2d tupleWithX:50 y:50];
	[bpt1 setCntrlPoint:p1];
	STAssertTrue([[bpt1 cntrlPoint] isEqualToTuple:p1], @"should be equal");
}

//=========================================================== 
//  testsetCntrlPoint
//===========================================================
- (void) testsetCntrlPoint
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	G3DTuple2d *p1 = [G3DTuple2d tupleWithX:50 y:50];
	[bpt1 setCntrlPoint:p1];
	STAssertTrue([[bpt1 cntrlPoint] isEqualToTuple:p1], @"should be equal");
}

//=========================================================== 
//  testlinePoint
//===========================================================
- (void) testlinePoint
{
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	STAssertTrue([bpt1 linePoint]==NO, @"should be equal");

	SH2dBezierPt* bpt2 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100] autorelease];
	STAssertTrue([bpt2 linePoint]==YES, @"should be equal");
}

//=========================================================== 
//  testcurvePoint
//===========================================================
- (void) testcurvePoint
{
// - (BOOL)curvePoint 
	SH2dBezierPt* bpt1 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100 cntrlPtX:200 cntrlPtY:200] autorelease];
	STAssertTrue([bpt1 curvePoint]==YES, @"should be equal");
	SH2dBezierPt* bpt2 = [[[SH2dBezierPt alloc] initWithBpX:100 bpY:100] autorelease];
	STAssertTrue([bpt2 curvePoint]==NO, @"should be equal");
}

@end
