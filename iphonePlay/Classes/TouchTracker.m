//
//  TouchTracker.m
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "TouchTracker.h"
#import "HooleyTouchEvent.h"
#import "G3DFunctions.h"

@interface TouchTracker ()

- (HooleyTouchEvent *)findOpenTouch:(UITouch *)value;

@end

@implementation TouchTracker


#pragma mark Init
- (id)init {
	
	self=[super init];
    if(self) {
		openTouches = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
	
	[openTouches release];
    [super dealloc];
}

#pragma mark Action
- (HooleyTouchEvent *)beganTouch:(UITouch *)touch atLoc:(CGPoint)ptLoc {
	
	HooleyTouchEvent *newTouchEvent = [HooleyTouchEvent newTouchEventWithUITouch:touch];
	newTouchEvent.pt = ptLoc;
	[openTouches addObject: newTouchEvent];
	return newTouchEvent;
}

- (HooleyTouchEvent *)movedTouch:(UITouch *)touch from:(CGPoint)prevPtLoc to:(CGPoint)ptLoc {
	
	NSAssert( self.openTouchCount>=1, @"Must have an open touch if e are moving");
	
	//find prevPtLoc - Assert It
	// old way
	HooleyTouchEvent *currentTouch1 = [self openTouchAlmostEqualToPt:prevPtLoc];
		
	// new way 
	HooleyTouchEvent *currentTouch2 = [self findOpenTouch:touch];

	NSAssert(currentTouch2, @"new way should work!");
//	NSAssert(currentTouch2==currentTouch1, @"nwhich way i better? eh?");
	
	if(!currentTouch2){
		NSAssert(NO, @"THIS SHOULD NEVER HAPPEN USING THE NEW WAY");
		currentTouch2 = [self nearestOpenTouchToPt:prevPtLoc];
	}
	NSAssert(currentTouch2, @"Fucked Up! - cant find pt to move");
	
	// remove it (no need) - add ptLoc
	currentTouch2.pt = ptLoc;
	return currentTouch2;
}

- (HooleyTouchEvent *)endedTouch:(UITouch *)touch at:(CGPoint)ptLoc prevPt:(CGPoint)prevPtLoc {

	NSAssert( self.openTouchCount>=1, @"Must have an open touch if e are moving");

	// old way
	HooleyTouchEvent *currentTouch1 = [self openTouchAlmostEqualToPt:prevPtLoc];
	
	// new way
	HooleyTouchEvent *currentTouch2 = [self findOpenTouch:touch];

	NSAssert(currentTouch2, @"new way should work!");
//	NSAssert(currentTouch2==currentTouch1, @"nwhich way i better? eh?");
	
	if(!currentTouch2){
		NSAssert(NO, @"THIS SHOULD NEVER HAPPEN USING THE NEW WAY");
		currentTouch2 = [self nearestOpenTouchToPt:prevPtLoc];
	}
	[openTouches removeObjectIdenticalTo:currentTouch2];
	return currentTouch2;
}

- (NSArray *)cancelAllTouches {
	
	NSArray *touches = [[openTouches copy] autorelease];
	for(HooleyTouchEvent *each in touches){
		CGPoint openPt = each.pt;
		[self endedTouch:each.touch at:openPt prevPt:openPt];
	}
	return touches;
}

#pragma mark accessors
// new way
- (HooleyTouchEvent *)findOpenTouch:(UITouch *)value {

	HooleyTouchEvent *foundOpenTouch=nil;
	for(HooleyTouchEvent *each in openTouches){
		if( each.touch==value ){
			foundOpenTouch = each;
			break;
		}
	}
	return foundOpenTouch;
}

// old way
- (HooleyTouchEvent *)openTouchAlmostEqualToPt:(CGPoint)ptLoc {
	
	HooleyTouchEvent *foundOpenTouch=nil;
	for(HooleyTouchEvent *each in openTouches){
		if( [each locationIsNearlyEqualTo:ptLoc] ){
			foundOpenTouch = each;
			break;
		}
	}
	return foundOpenTouch;
}

- (HooleyTouchEvent *)nearestOpenTouchToPt:(CGPoint)ptLoc {
	
	NSAssert( self.openTouchCount>=1, @"Must have an open touch if e are moving");
	HooleyTouchEvent *nearestTouch = nil;
	double nearestDist = 99999.;
	for( HooleyTouchEvent *each in openTouches ){
		double dist = [each distanceFromPoint: ptLoc];
		if(dist<nearestDist){
			nearestDist = dist;
			nearestTouch = each;
		}
	}
	NSAssert( G3DCompareDouble(nearestDist, 99999.0f, 0.00001f)!=0 && nearestTouch!=nil, @"gone wrong somewhere");
	return nearestTouch;
}

- (NSUInteger)openTouchCount {
	return [openTouches count];
}

@end
