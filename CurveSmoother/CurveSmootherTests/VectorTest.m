//
//  VectorTest.m
//  CurveSmoother
//
//  Created by Steven Hooley on 21/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Accelerate/Accelerate.h>


@interface VectorTest : SenTestCase {
@private
    
}

@end

@implementation VectorTest

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testMe {
    
    vFloat vflts = {10.0f,20.0f,30.0f,40.0f};

    STFail(@"yay", nil);
}
@end
