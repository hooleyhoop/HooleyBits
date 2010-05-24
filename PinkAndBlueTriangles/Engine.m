//
//  Engine.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 13/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Engine.h"
#import <SHGeometryKit/SHGeometryKit.h>

@implementation Engine


#pragma mark -
#pragma mark class methods

#pragma mark init methods
- (id)init {

	self = [super init];
	if(self) {
	
		unitAccelerationCurve = [[LWEnvelope lWEnvelopeWithPoint:CGPointMake(0.0f,1.0f)] retain];
		[unitAccelerationCurve lineToPoint:CGPointMake(1.0f, 0.0f)];
		
		
		// test some values
//		float one = [unitAccelerationCurve evalAtTime:0.5];
//		float two = [unitAccelerationCurve evalAtTime:0.2];
//		float three = [unitAccelerationCurve evalAtTime:0.7];
		
		throttle = 0.0;
		maxSpeed = 10.0;
		maxAccel = 2.0;
		accel = 0.0;
		speed = 0.0;

	}
	return self;
}

- (void)dealloc {

	[unitAccelerationCurve release];

	[super dealloc];
}


#pragma mark accessor methods
- (double)newSpeedAtTime {
	// multiply y by max accel : multiply x by max speed.
	// Then for a given speed (x) read Accel (y) value
	// multiply my current throttle
	return speed;
}

//=========================================================== 
// - speed
//=========================================================== 
- (double)speed {
	return speed;
}

//=========================================================== 
// - accel
//=========================================================== 
- (double)accel {
	return accel;
}

- (double)throttle {
	return throttle;
}

- (void)setThrottle:(double)value {
	if(value!=throttle){
		NSAssert(value>=-1.0 && value<=1.0, @"Throttle out of bounds");
		throttle = value;
	}
}

- (double)maxSpeed {
	return maxSpeed;
}

- (void)setMaxSpeed:(double)value {
	if(value!=maxSpeed){
		maxSpeed = value;
	}
}

- (double)maxAccel {
	return maxAccel;
}

- (void)setMaxAccel:(double)value {
	if(value!=maxAccel){
		maxAccel = value;
	}
}
	
	
	
	
@end
