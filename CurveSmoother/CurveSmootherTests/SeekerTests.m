//
//  SeekerTests.m
//  CurveSmoother
//
//  Created by Steven Hooley on 23/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Seeker.h"

@interface SeekerTests : SenTestCase {
    Seeker *seeker, *fleer;
    int framesSinceTouch;
}

@end


@implementation SeekerTests

- (void)setUp {

    [super setUp];
    
    seeker = [[Seeker alloc] init];
    fleer = [[Seeker alloc] init];
    framesSinceTouch = 0;
}

- (void)tearDown {

    [seeker release];
    [fleer release];
    [super tearDown];
}

- (void)updateSeekers {
    
    [seeker update];
    //   seeker.draw(this.canvasG, this.scale);
    [fleer update];
    //   fleer.draw(this.canvasG, this.scale);
    
    [fleer setTouch: [seeker touch]];
    
    framesSinceTouch = ([seeker touch] ? framesSinceTouch + 1 : 0);
    if(framesSinceTouch > 15)
        [self resetSeekers];
}

// which is better ?
// seeker.setPosition.setUnitRandom()
// setUnitRandom( seeker.setPosition )

- (void)resetSeekers {
    
    [seeker setPosition: setUnitRandom()];
    [seeker setPosition: setScale(17.0F, this.seeker.position)];
    [seeker setPosition: setSum(this.viewCenter, this.seeker.position)];
    // [seeker setPosition.z = 0.0F];
     
    [seeker setVelocity: setUnitRandom()];
    [seeker setVelocity: setScale(this.seeker.maxSpeed, this.seeker.velocity)];
    // [seeker setVelocity.z = 0.0F;
    [seeker.target.set(this.viewCenter);
    [seeker.touch = false;

    [fleer.seek = false;
    [fleer setPosition.set(this.seeker.position);
    [fleer setVelocity.set(this.seeker.velocity);
    [fleer.target.set(this.viewCenter);
    [fleer.touch = false;
}

- (void)testSeek {

    [self resetSeekers];
    [self updateSeekers];
}


@end
