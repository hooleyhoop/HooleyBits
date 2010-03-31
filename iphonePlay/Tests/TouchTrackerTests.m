//
//  TouchTrackerTests.m
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "TouchTracker.h"
#import "HooleyTouchEvent.h"

@interface TouchTrackerTests : SenTestCase {
	
	TouchTracker *tracker;
}

@end

@implementation TouchTrackerTests

- (void)setUp {
	
	tracker = [[TouchTracker alloc] init];
}

- (void)tearDown {
	
	[tracker release];
}

- (void)testOppenTouchAlmostEqualToPt {
	// - (HooleyTouchEvent *)openTouchAlmostEqualToPt:(CGPoint)ptLoc 
	
	HooleyTouchEvent *touch = [tracker beganTouch:CGPointMake(50.,50.)];
	STAssertNotNil(touch, @"Should have made a touch");
	STAssertNotNil( [tracker openTouchAlmostEqualToPt:CGPointMake(49.8, 50.25)], @"should have a pt");
	STAssertEqualObjects( touch, [tracker openTouchAlmostEqualToPt:CGPointMake(49.8, 50.25)], @"should be the same");
	STAssertNil( [tracker openTouchAlmostEqualToPt:CGPointMake(48.8, 51.25)], @"This should be too far");
}

- (void)testOpenTouchCount {
	// - (NSUInteger)openTouchCount;

	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count");
	[tracker beganTouch:CGPointMake(50.,50.)];
	STAssertTrue([tracker openTouchCount]==1, @"Messed up touch count");
}

- (void)testNearestOpenTouchToPt {
	//- (HooleyTouchEvent *)nearestOpenTouchToPt:(CGPoint)ptLoc
	
	HooleyTouchEvent* touch1 = [tracker beganTouch:CGPointMake(50.,50.)];
	HooleyTouchEvent* touch2 = [tracker beganTouch:CGPointMake(60.,60.)];
	HooleyTouchEvent* touch3 = [tracker beganTouch:CGPointMake(70.,70.)];
	STAssertNotEqualObjects(touch1,touch3, @"should be different");
	
	HooleyTouchEvent *nearestOpenTouch = [tracker nearestOpenTouchToPt:CGPointMake(63.,63.)];
	STAssertNotNil(nearestOpenTouch, @"gone wrong");
	STAssertEqualObjects( nearestOpenTouch, touch2, @"should be" );

	CGPoint returnedPt = nearestOpenTouch.pt;	
	STAssertEqualsWithAccuracy( (float)returnedPt.x, 60.f, 0.03f, @"should be" );
	STAssertEqualsWithAccuracy( (float)returnedPt.y, 60.f, 0.03f, @"should be" );
}

- (void)testTouchyNess {
	
	/* Simple Case */
	HooleyTouchEvent* touch1Start = [tracker beganTouch:CGPointMake(50.,50.)];
	STAssertTrue([tracker openTouchCount]==1, @"Messed up touch count");
	
	HooleyTouchEvent* touch2Start = [tracker beganTouch:CGPointMake(55.,50.)];
	STAssertTrue([tracker openTouchCount]==2, @"Messed up touch count");
	
	HooleyTouchEvent* touch1End = [tracker endedTouchAt:CGPointMake(50.,50.) prevPt:CGPointMake(50.,50.)];
	STAssertTrue([tracker openTouchCount]==1, @"Messed up touch count");
	STAssertEqualObjects( touch1Start, touch1End, @"should be" );

	HooleyTouchEvent* touch2End = [tracker endedTouchAt:CGPointMake(60.,50.) prevPt:CGPointMake(55.,50.)];
	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count %i", [tracker openTouchCount]);
	STAssertEqualObjects( touch2Start, touch2End, @"should be" );

	/* Simple Movement */
	// Movment but no discontinuity
	HooleyTouchEvent* touch3Start = [tracker beganTouch:CGPointMake(50.,50.)];
	STAssertNotEqualObjects( touch3Start, touch1Start, @"Yikes! Should be a new object");
	HooleyTouchEvent* touch3Moved = [tracker movedFrom:CGPointMake(50.,50.) to:CGPointMake(5.,47.)];
	STAssertEqualObjects( touch3Start, touch3Moved, @"should be" );
	HooleyTouchEvent* touch3Ended = [tracker endedTouchAt:CGPointMake(5.,47.) prevPt:CGPointMake(5.,47.)];
	STAssertEqualObjects( touch3Moved, touch3Ended, @"should be" );
	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count");
	
	/* Complex */
	// Start and end with discontinuity
	HooleyTouchEvent* touch4Start = [tracker beganTouch:CGPointMake(15.,30.)];
	HooleyTouchEvent* touch4Ended = [tracker endedTouchAt:CGPointMake(6.,30.) prevPt:CGPointMake(15.,37.)];
	STAssertEqualObjects( touch4Start, touch4Ended, @"should be" );
	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count");
	
	/* Complex movement */
	// Start end move with discontinuity - use data below
	HooleyTouchEvent* touch5Start = [tracker beganTouch:CGPointMake(15.,30.)];
	HooleyTouchEvent* touch5Moved = [tracker movedFrom:CGPointMake(15.,37.) to:CGPointMake(5.,47.)];
	HooleyTouchEvent* touch5Ended = [tracker endedTouchAt:CGPointMake(6.,30.) prevPt:CGPointMake(15.,37.)];
	STAssertEqualObjects( touch5Start, touch5Moved, @"should be" );
	STAssertEqualObjects( touch5Moved, touch5Ended, @"should be" );
	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count");
}

- (void)testCancelAllTouches {
	// - (void)cancelAllTouches;
	
	[tracker beganTouch:CGPointMake(50.,50.)];
	[tracker beganTouch:CGPointMake(60.,60.)];
	[tracker beganTouch:CGPointMake(70.,70.)];
	[tracker movedFrom:CGPointMake(50.,50.) to:CGPointMake(5.,47.)];

	NSArray *cancelledTouches = [tracker cancelAllTouches];
	STAssertTrue([cancelledTouches count]==3, @"Messed up touch count");
	STAssertTrue([tracker openTouchCount]==0, @"Messed up touch count");
}

@end

//Broken Touch data
//-----------------
//
//View_main.m:51 - Info: Touch Began (19.000000, 35.000000), (19.000000, 35.000000)
//View_main.m:79 - Info: Touch Ended (20.000000, 35.000000), (19.000000, 37.000000)
//
//View_main.m:51 - Info: Touch Began (11.000000, 9.000000), (11.000000, 9.000000)
//View_main.m:79 - Info: Touch Ended (10.000000, 9.000000), (11.000000, 17.000000)
//
//View_main.m:51 - Info: Touch Began (12.000000, 13.000000), (12.000000, 13.000000)
//View_main.m:79 - Info: Touch Ended (12.000000, 13.000000), (12.000000, 16.000000)
//
//View_main.m:51 - Info: Touch Began (5.000000, 4.000000), (5.000000, 4.000000)
//View_main.m:79 - Info: Touch Ended (3.000000, 4.000000), (5.000000, 6.000000)
//
//View_main.m:51 - Info: Touch Began (28.000000, 16.000000), (28.000000, 16.000000)
//View_main.m:63 - Info: Touch Moved Frm (28.000000, 16.000000) to (5.000000, 47.000000)
//View_main.m:79 - Info: Touch Ended (5.000000, 47.000000), (5.000000, 48.000000)
//
//View_main.m:51 - Info: Touch Began (42.000000, 9.000000), (42.000000, 9.000000)
//View_main.m:63 - Info: Touch Moved Frm (42.000000, 9.000000) to (28.000000, 14.000000)
//View_main.m:63 - Info: Touch Moved Frm (28.000000, 14.000000) to (13.000000, 19.000000)
//View_main.m:79 - Info: Touch Ended (13.000000, 19.000000), (13.000000, 20.000000)
//
//View_main.m:51 - Info: Touch Began (15.000000, 30.000000), (15.000000, 30.000000)
//View_main.m:79 - Info: Touch Ended (6.000000, 30.000000), (15.000000, 37.000000)