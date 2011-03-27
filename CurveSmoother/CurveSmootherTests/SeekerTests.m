//
//  SeekerTests.m
//  CurveSmoother
//
//  Created by Steven Hooley on 23/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Seeker.h"
#include "2DVectorOps.h"

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

- (void)resetSeekers {
    
    CGPoint viewCenter = CGPointMake( 200, 200 );
    
    [seeker setPosition: setUnitRandom()];
    [seeker setPosition: setScale(17.0F, seeker.position)];
    [seeker setPosition: setSum( viewCenter, seeker.position)];
    
    [seeker setVelocity: setUnitRandom()];
    [seeker setVelocity: setScale( seeker.maxSpeed, seeker.velocity)];
    
    seeker.target = viewCenter;
    seeker.touch = NO;
    
    fleer.seek = NO;
    [fleer setPosition: seeker.position];
    [fleer setVelocity: seeker.velocity];
    fleer.target = viewCenter;
    fleer.touch = NO;
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


- (void)testSeek {

    [self resetSeekers];
    [self updateSeekers];
}


@end
