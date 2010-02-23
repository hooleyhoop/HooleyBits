//
//  SetUpAndTearDownTests.m
//  iphonePlay
//
//  Created by steve hooley on 13/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "LogController.h"
#import "SHInstanceCounter.h"
#import "SwizzleList.h"

@interface SetupAndTearDownTests : NSObject {
	
}
@end

@implementation SetupAndTearDownTests

/* You need to have a modified google tests to run these */
+ (void)setUpTests {
	
	[SwizzleList setupSwizzles];
}


+ (void)tearDownTests {
	
	[SwizzleList tearDownSwizzles];
}

@end