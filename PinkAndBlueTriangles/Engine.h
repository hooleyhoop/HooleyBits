//
//  Engine.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 13/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@class LWEnvelope;

@interface Engine : NSObject {

	double throttle;		// -1 to 1		0 is constant speed
	
	double maxSpeed;
	double maxAccel;
	
	double accel;
	double speed;
	
	// multiply y by max accel : multiply x by max speed.
	// Then for a given speed (x) read Accel (y) value
	// multiply my current throttle
	LWEnvelope *unitAccelerationCurve;
}

#pragma mark accessor methods
- (double)throttle;
- (void)setThrottle:(double)value;

- (double)maxSpeed;
- (void)setMaxSpeed:(double)value;
- (double)maxAccel;
- (void)setMaxAccel:(double)value;

- (double)speed;
- (double)accel;

@end
