//
//  HooleyTouchEvent.m
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "HooleyTouchEvent.h"

static NSUInteger globalIDCounter = 0;

@implementation HooleyTouchEvent

@synthesize touchID;
@synthesize touch = _touch;
@synthesize pt;

#pragma mark UTILITIES
BOOL pointNearlyEqualToPoint(CGPoint point1, CGPoint point2) {

	const double accuracy = 0.5;
	double dist = distanceBetweenPoints(point1,point2);
	if( dist<accuracy )
		return YES;
	return NO;
}

double distanceBetweenPoints(CGPoint point1, CGPoint point2) {

	double dist = sqrt( pow(point2.x-point1.x, 2)+pow(point2.y-point1.y,2) );
	return dist;
}

+ (HooleyTouchEvent *)newTouchEventWithUITouch:(UITouch *)touch {

	HooleyTouchEvent *newTouchEvent = [[[HooleyTouchEvent alloc] initWithTouch:touch] autorelease];
	return newTouchEvent; 
}

- (id)initWithTouch:(UITouch *)touch {

	self = [super init];
	if(self){
		_touch = [touch retain];
		touchID = globalIDCounter++;
	}
	return self;
}

- (void)dealloc {
	
	[_touch release];
	[super dealloc];
}

- (double)distanceFromPoint:(CGPoint)ptLoc {

	CGPoint thisPtLoc = self.pt;
	double dist = distanceBetweenPoints( ptLoc, thisPtLoc );
	return dist;
}

- (BOOL)locationIsNearlyEqualTo:(CGPoint)ptLoc {
	
	CGPoint openPt = self.pt;
	if( pointNearlyEqualToPoint( openPt, ptLoc ) ){
		return YES;
	}
	return NO;
}

@end
