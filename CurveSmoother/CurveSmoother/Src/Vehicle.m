//
//  Vehicle.m
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "Vehicle.h"


@implementation Vehicle

float mass;

Vector3 allForces;
Vector3 acceleration = new Vector3();
static Vector3 accelUp = new Vector3();
static final Vector3 globalUp = new Vector3(0.0F, 0.1F, 0.0F);
static Vector3 bankUp = new Vector3();
static Vector3 newAccel = new Vector3();
static float accelDamping = 0.7F;

- (id)init {
    self = [super init];
    if (self) {
        this.mass = 1.0F;
        this.maxSpeed = 1.0F;
        this.maxForce = 0.04F;
        this.velocity = new Vector3();
        this.allForces = new Vector3();
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)applyGlobalForce(Vector3 force) {
    this.allForces.setSum(this.allForces, force);
}

- (void)update() {
    
    this.allForces.setApproximateTruncate(this.maxForce);
    
    if (this.mass == 1.0F)
        newAccel.set(this.allForces);
    else
        newAccel.setScale(1.0F / this.mass, this.allForces);
    this.allForces.setZero();
    
    this.acceleration.setInterp(accelDamping, newAccel, this.acceleration);
    
    this.velocity.setSum(this.velocity, this.acceleration);
    this.velocity.setApproximateTruncate(this.maxSpeed);
    
    this.position.setSum(this.position, this.velocity);
    
    accelUp.setScale(0.5F, this.acceleration);
    bankUp.setSum(this.up, accelUp);
    bankUp.setSum(bankUp, globalUp);
    bankUp.setNormalize();
    
    float speed = this.velocity.magnitude();
    if (speed > 0.0F)
    {
        this.forward.setScale(1.0F / speed, this.velocity);
        this.side.setCross(this.forward, bankUp);
        
        this.up.setCross(this.side, this.forward);
    }
}

@end
