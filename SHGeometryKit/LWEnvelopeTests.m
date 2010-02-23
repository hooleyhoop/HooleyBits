//
//  LWEnvelopeTests.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 04/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "LWEnvelope.h"
#import "LWKey.h"

@interface LWEnvelopeTests : SenTestCase {
	
}

@end

@implementation LWEnvelopeTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testMakePDF {
	
	NSString *filePath = [@"/fuck.pdf" stringByExpandingTildeInPath];
	NSURL *outURL = [NSURL fileURLWithPath:filePath];

	CGFloat red[] = {1., 0.1, 0., 1. };
	CGRect mediaBox = CGRectMake(0,0,200,200);
	CGContextRef pdfContext = CGPDFContextCreateWithURL((CFURLRef)outURL, &mediaBox, NULL);
	STAssertTrue(pdfContext!=NULL, @"oops");
	
	CGContextBeginPage(pdfContext,&mediaBox);
	CGContextSaveGState(pdfContext);
	CGContextClipToRect(pdfContext, mediaBox);

	CGContextSetFillColorSpace(pdfContext, CGColorSpaceCreateDeviceRGB());
	CGContextSetStrokeColor(pdfContext, red);

	CGContextMoveToPoint(pdfContext,0,0);
	
	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0, 0)];
	[aLine curveToPoint:CGPointMake(100,200)];
	[aLine curveToPoint:CGPointMake(200,0)];
	
	for(int i=1; i<20; i++){
		CGFloat time = i*10;
		CGContextAddLineToPoint(pdfContext, time, [aLine evalAtTime:time]);
	}
	
	CGContextAddLineToPoint(pdfContext,10,10);
	CGContextClosePath(pdfContext);
	CGContextStrokePath(pdfContext);

	CGContextRestoreGState(pdfContext);
	CGContextEndPage(pdfContext);
	CGContextRelease(pdfContext);
}

- (void)testlWEnvelope {
	// + (LWEnvelope*) lWEnvelope

	LWEnvelope* aLine = [LWEnvelope lWEnvelope];
	STAssertNotNil(aLine, @"should be a valid object");
	STAssertEquals( aLine.nkeys, (NSUInteger)0, @"should be equal");
}

- (void)testlWEnvelopeWithPoint {
	// + (LWEnvelope*) lWEnvelopeWithPoint:(G3DTuple2d*)pt

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(10.0, 100.0)];
	STAssertNotNil(aLine, @"should be a valid object");
	STAssertEquals( aLine.nkeys, (NSUInteger)1, @"should be equal");
}

- (void)testinit {
	// - (id) init
	
	LWEnvelope* aLine = [[[LWEnvelope alloc] init] autorelease];
	STAssertNotNil(aLine, @"should be a valid object");
	STAssertEquals( aLine.nkeys, (NSUInteger)0, @"should be equal");
}

- (void)testinitWithPoint {
	// - (id) initWithPoint:(G3DTuple2d*)pt
		
	LWEnvelope* aLine = [[[LWEnvelope alloc] initWithPoint:CGPointMake(10.0, 100.0)] autorelease];
	STAssertNotNil(aLine, @"should be a valid object");
	STAssertEquals( aLine.nkeys, (NSUInteger)1, @"should be equal");
}

- (void)testEvalAtTime {
	// - (float)evalAtTime:(float)time

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(10, 10)];
	[aLine lineToPoint:CGPointMake(100,100)];
	[aLine lineToPoint:CGPointMake(200,0)];
	[aLine setPreBehavoir:5];
	
	NSArray *pts = [aLine ptsAsArray];
	for(LWKey *each in pts){
		[each setIncomingCurveBehavoir:(NSUInteger)3];
	}
	STAssertEqualsWithAccuracy( [aLine evalAtTime:0.0], (CGFloat)0., 0.01, @"no %f", [aLine evalAtTime:0.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:10.0], (CGFloat)10., 0.01, @"no %f", [aLine evalAtTime:10.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:20.0], (CGFloat)20., 0.01, @"no %f", [aLine evalAtTime:20.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:100.0], (CGFloat)100., 0.01, @"no %f", [aLine evalAtTime:100.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:150.0], (CGFloat)50., 0.01, @"no %f", [aLine evalAtTime:150.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:200.], (CGFloat)0., 0.01, @"no %f", [aLine evalAtTime:200.]);
}


- (void)testmoveToPoint {
	// - (void) moveToPoint:(G3DTuple2d*)pt

	LWEnvelope* aLine = [LWEnvelope lWEnvelope];
	[aLine moveToPoint:CGPointMake(10.0, 100.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)1, @"should be equal");
}

- (void)testlineToPoint {
	// - (void) lineToPoint:(G3DTuple2d*)pt

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(10.0, 100.0)];
	[aLine lineToPoint:CGPointMake(100.0, 1000.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)2, @"should be equal");
	
	/* check that we dont allow duplicate points */
	[aLine lineToPoint:CGPointMake(100.0, 1000.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)2, @"should be equal");
}

- (void)testCurveToPoint {
	// - (void)curveToPoint:(CGPoint)pt

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(10.0, 100.0)];
	[aLine curveToPoint:CGPointMake(100.0, 1000.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)2, @"should be equal %i", aLine.nkeys );

	/* check that we dont allow duplicate points */
	[aLine curveToPoint:CGPointMake(100.0, 1000.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)2, @"should be equal");
}

- (void)testCurveToPointCntrlPt {
	// - (void)curveToPoint:(G3DTuple2d*)bPt cntrlPt:(G3DTuple2d*)cPt

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0, 0)];
	[aLine curveToPoint:CGPointMake(100,100) cntrlPt:CGPointMake(0, 100)];
	[aLine curveToPoint:CGPointMake(200,0) cntrlPt:CGPointMake(100, 0)];

	NSArray *pts = [aLine ptsAsArray];
	for(LWKey *each in pts){
		[each setIncomingCurveBehavoir:(NSUInteger)2];
	}
	
	STAssertEqualsWithAccuracy( [aLine evalAtTime:0.0], (CGFloat)0., 0.01, @"no %f", [aLine evalAtTime:0.0]);
//	STAssertEqualsWithAccuracy( [aLine evalAtTime:10.0], (CGFloat)4.5, 0.01, @"no %f", [aLine evalAtTime:10.0]);
//	STAssertEqualsWithAccuracy( [aLine evalAtTime:20.0], (CGFloat)31., 0.01, @"no %f", [aLine evalAtTime:20.0]);
//	STAssertEqualsWithAccuracy( [aLine evalAtTime:100.0], (CGFloat)100., 0.01, @"no %f", [aLine evalAtTime:100.0]);
//	STAssertEqualsWithAccuracy( [aLine evalAtTime:150.0], (CGFloat)27.5, 0.01, @"no %f", [aLine evalAtTime:150.0]);
	STAssertEqualsWithAccuracy( [aLine evalAtTime:200.], (CGFloat)0., 0.01, @"no %f", [aLine evalAtTime:200.]);
	
	
	/* dont know how it handles control points yet */
}

- (void)testinsertPt {
	// - (void)insertPt:(G3DTuple2d*)pt atIndex:(int)i
		
	LWEnvelope* aLine = [LWEnvelope lWEnvelope];
	[aLine insertPt:CGPointMake(101.0, 100.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)1, @"should be equal");
	NSArray* allPts;
	
	[aLine insertPt:CGPointMake(1.0, 100.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)2, @"should be equal");
	allPts = [aLine ptsAsArray];

	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:0] x], (CGFloat)1.0, @"should be equal");
	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:1] x], (CGFloat)101.0, @"should be equal");

	[aLine insertPt:CGPointMake(55.0, 101.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)3, @"should be equal");

	allPts = [aLine ptsAsArray];
	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:0] x], (CGFloat)1.0, @"should be equal");
	STAssertEquals( (CGFloat)[(LWKey*)[allPts objectAtIndex:1] x], (CGFloat)55.0, @"%i", (CGFloat)[(LWKey*)[allPts objectAtIndex:1]x] );
	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:2] x], (CGFloat)101.0, @"should be equal");
	
	[aLine insertPt:CGPointMake(1000.0, 100.0)];
	STAssertEquals( aLine.nkeys, (NSUInteger)4, @"should be equal");
	allPts = [aLine ptsAsArray];
	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:3] x], (CGFloat)1000.0, @"should be equal");
}

- (void)testInsertPtAtIndex {
	// - (void)insertPt:(G3DTuple2d*)pt atIndex:(int)i

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(10.0, 100.0)];
	[aLine curveToPoint:CGPointMake(100.0, 1000.0)];
	
	[aLine insertPt:CGPointMake(0.0, 0.0) atIndex:0];
	STAssertEquals( aLine.nkeys, (NSUInteger)3, @"should be equal");
	
	[aLine insertPt:CGPointMake(111110.0, 111110.0) atIndex:1110];
	STAssertEquals( aLine.nkeys, (NSUInteger)4, @"should be equal");
}

- (void)testRemovePointAtIndex {
	// - (void) removePointAtIndex:(int)i

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0.0, 0.0)];
	[aLine lineToPoint:CGPointMake(10, 10)];
	[aLine lineToPoint:CGPointMake(20, 20)];
	[aLine lineToPoint:CGPointMake(30, 30)];
	[aLine lineToPoint:CGPointMake(40, 40)];
	STAssertEquals( aLine.nkeys, (NSUInteger)5, @"should be equal %i", aLine.nkeys );

	[aLine removePointAtIndex:0];
	NSArray* allPts = [aLine ptsAsArray];
	STAssertEquals( aLine.nkeys, (NSUInteger)4, @"should be equal %i", aLine.nkeys );
	STAssertEquals((CGFloat)[(LWKey*)[allPts objectAtIndex:0] x], (CGFloat)10.0, @"should be equal");
	
	[aLine removePointAtIndex:3];
	allPts = [aLine ptsAsArray];
	STAssertEquals( aLine.nkeys, (NSUInteger)3, @"should be equal");
	STAssertEquals( (CGFloat)[(LWKey*)[allPts objectAtIndex:2] x], (CGFloat)30.0, @"should be equal");
}

- (void)testRemoveAllPoints {
	// - (void)removeAllPoints
	
	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0.0, 0.0)];
	[aLine lineToPoint:CGPointMake(10, 10)];
	[aLine lineToPoint:CGPointMake(20, 20)];
	[aLine lineToPoint:CGPointMake(30, 30)];
	[aLine removeAllPoints];
	STAssertEquals( aLine.nkeys, (NSUInteger)0, @"should be equal %i", aLine.nkeys );
	STAssertNil([aLine key], @"should be nil");
}

- (void)testBounds {
	// - (NSRect)bounds

	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0.0, 0.0)];
	[aLine lineToPoint:CGPointMake(10, 10)];
	[aLine lineToPoint:CGPointMake(20, 20)];
	CGRect r = [aLine bounds];
	STAssertEquals((float)r.origin.x, (float)0, @"should be equal");
	STAssertEquals((float)r.origin.y, (float)0, @"should be equal");
	STAssertEquals((float)r.size.width, (float)20, @"should be equal");
	STAssertEquals((float)r.size.height, (float)20, @"should be equal");
}

- (void)testPtsAsArray {
	// - (NSArray *)ptsAsArray
	
	LWEnvelope* aLine = [LWEnvelope lWEnvelopeWithPoint:CGPointMake(0.0, 0.0)];
	[aLine lineToPoint:CGPointMake(10, 10)];
	[aLine lineToPoint:CGPointMake(20, 20)];
	[aLine lineToPoint:CGPointMake(30, 30)];
	[aLine lineToPoint:CGPointMake(40, 40)];
	[aLine lineToPoint:CGPointMake(50, 50)];
	[aLine lineToPoint:CGPointMake(60, 60)];
	[aLine lineToPoint:CGPointMake(70, 70)];
	
	NSArray* ar = [aLine ptsAsArray];
	STAssertEquals( [ar count], (NSUInteger)8, @"count is %i", [ar count]);
	STAssertEquals((CGFloat)[(LWKey *)[ar objectAtIndex:3] x], (CGFloat)30., @"should be equal");
}

@end
