//
//  HooleyTouchEventTests.m
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "HooleyTouchEvent.h"


@interface HooleyTouchEventTests : SenTestCase {
	
}

@end

@implementation HooleyTouchEventTests

- (void)testDistanceBetweenPoints {
	// double distanceBetweenPoints(CGPoint point1, CGPoint point2)
	
	CGPoint pt1 = CGPointMake(10.,10.);
	CGPoint pt2 = CGPointMake(5.,5.);
	CGPoint pt3 = CGPointMake(20.,20.);
	
	double diff1 = sqrt( pow(10-5, 2)+pow(10-5,2) );
	double diff2 = sqrt( pow(20-10, 2)+pow(20-10,2) );
	
	double calcDiff1 = distanceBetweenPoints(pt1, pt2);
	double calcDiff2 = distanceBetweenPoints(pt1, pt3);
	
	STAssertEqualsWithAccuracy ( calcDiff1, diff1, 0.03, @"should be about 7 - %f", (float)diff1 );
	STAssertEqualsWithAccuracy ( calcDiff2, diff2, 0.03, @"should be about 14 - %f", (float)diff2 );
}

- (void)testPointNearlyEqualToPoint {
	// BOOL pointNearlyEqualToPoint(CGPoint point1, CGPoint point2)
	
	CGPoint pt1 = CGPointMake(10.,10.);
	CGPoint pt2 = CGPointMake(10.2,9.8);
	CGPoint pt3 = CGPointMake(10.6,9.3);
	
	STAssertTrue( pointNearlyEqualToPoint(pt1,pt2), @"should be!" );
	STAssertTrue( pointNearlyEqualToPoint(pt2,pt1), @"should be!" );
	STAssertFalse( pointNearlyEqualToPoint(pt1,pt3), @"should be!" );
	STAssertFalse( pointNearlyEqualToPoint(pt3,pt1), @"should be!" );
}

- (void)testHooleyTouchEvent {
	
	HooleyTouchEvent *touch1 = [HooleyTouchEvent newTouchEvent];
	HooleyTouchEvent *touch2 = [HooleyTouchEvent newTouchEvent];
	HooleyTouchEvent *touch3 = [HooleyTouchEvent newTouchEvent];
	STAssertTrue( touch1.touchID!=touch2.touchID && touch2.touchID!=touch3.touchID, @"Unique touchID failure ");
}

- (void)testLocationIsNearlyEqualTo {
	//- (BOOL)locationIsNearlyEqualTo:(CGPoint)pt
	
	CGPoint pt1 = CGPointMake(10.,10.);
	CGPoint pt2 = CGPointMake(10.2,9.8);
	CGPoint pt3 = CGPointMake(10.6,9.3);
	
	HooleyTouchEvent *touch1 = [HooleyTouchEvent newTouchEvent];
	touch1.pt = pt1;
	
	STAssertTrue( [touch1 locationIsNearlyEqualTo:pt2], @"should be!" );
	STAssertFalse( [touch1 locationIsNearlyEqualTo:pt3], @"should be!" );
}

- (void)testDistanceFromPoint {
	// - (double)distanceFromPoint:(CGPoint)ptLoc
	
	CGPoint pt1 = CGPointMake(10.,10.);
	CGPoint pt2 = CGPointMake(5.,5.);
	CGPoint pt3 = CGPointMake(20.,20.);
	
	HooleyTouchEvent *touch1 = [HooleyTouchEvent newTouchEvent];
	touch1.pt = pt1;
	
	double diff1 = sqrt( pow(10-5, 2)+pow(10-5,2) );
	double diff2 = sqrt( pow(20-10, 2)+pow(20-10,2) );

	STAssertEqualsWithAccuracy ( [touch1 distanceFromPoint:pt2], diff1, 0.03, @"should be about 7 - %f", (float)diff1 );
	STAssertEqualsWithAccuracy ( [touch1 distanceFromPoint:pt3], diff2, 0.03, @"should be about 14 - %f", (float)diff2 );
}

@end
