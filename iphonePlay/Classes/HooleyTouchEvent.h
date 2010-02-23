//
//  HooleyTouchEvent.h
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHooleyObject.h"


@interface HooleyTouchEvent : SHooleyObject {

	NSUInteger touchID;
	UITouch *_touch;
	CGPoint pt;
}

@property (readonly) UITouch *touch;
@property (readonly) NSUInteger touchID;
@property CGPoint pt;

+ (HooleyTouchEvent *)newTouchEventWithUITouch:(UITouch *)touch;

#pragma mark UTILITIES
double distanceBetweenPoints(CGPoint point1, CGPoint point2);
BOOL pointNearlyEqualToPoint(CGPoint point1, CGPoint point2);

- (id)initWithTouch:(UITouch *)touch;
- (double)distanceFromPoint:(CGPoint)ptLoc;
- (BOOL)locationIsNearlyEqualTo:(CGPoint)ptLoc;

@end
