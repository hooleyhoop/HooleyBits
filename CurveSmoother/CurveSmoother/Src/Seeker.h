//
//  Seeker.h
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Vehicle.h"

@interface Seeker : Vehicle {

    CGPoint target;
    CGPoint steering;
    CGPoint drawSteer;
    BOOL seek, touch;
}

@property (assign) CGPoint target;
@property (assign) BOOL touch;
@property (assign) BOOL seek;

- (void)steeringForSeekFlee:(CGPoint)v;

@end
