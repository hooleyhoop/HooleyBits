//
//  Vehicle.h
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSpace.h"

@interface Vehicle : LocalSpace {
    float mass;    
    float maxSpeed;
    float maxForce;
    CGPoint velocity;
}

@end
