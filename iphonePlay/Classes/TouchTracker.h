//
//  TouchTracker.h
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHooleyObject.h"
@class HooleyTouchEvent;

@interface TouchTracker : SHooleyObject {

	NSMutableArray *openTouches;
}

#pragma mark Action
- (HooleyTouchEvent *)beganTouch:(UITouch *)touch atLoc:(CGPoint)ptLoc;
- (HooleyTouchEvent *)movedTouch:(UITouch *)touch from:(CGPoint)prevPtLoc to:(CGPoint)ptLoc;
- (HooleyTouchEvent *)endedTouch:(UITouch *)touch at:(CGPoint)ptLoc prevPt:(CGPoint)prevPtLoc;

- (NSArray *)cancelAllTouches;

#pragma mark Accessor

- (HooleyTouchEvent *)nearestOpenTouchToPt:(CGPoint)ptLoc;
- (HooleyTouchEvent *)openTouchAlmostEqualToPt:(CGPoint)ptLoc;

- (NSUInteger)openTouchCount;

@end
