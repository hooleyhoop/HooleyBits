//
//  C3DTMathTests.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 24/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import <sys/time.h>
#import <objc/objc-runtime.h>
#import <SenTestingKit/SenTestingKit.h>

/* get "real time" in seconds; take the
 first time we get called as a reference time of zero. */

// gettimeofday is microsecond accurate. for higher resolution (nanosecond) switch to http://developer.apple.com/library/mac/#qa/qa2004/qa1398.html

double sys_getrealtime(void) {
	
    static struct timev al then;
    struct timeval now;
    gettimeofday(&now, 0);
    if (then.tv_sec == 0 && then.tv_usec == 0) then = now;
    return ((now.tv_sec - then.tv_sec) + (1./1000000.) * (now.tv_usec - then.tv_usec));
}

@interface C3DTMathTests : SenTestCase {
	
}

@end

@implementation C3DTMathTests

// Hmm doesn't seem very accurate?
- (void)testVectorLength {
	// float vectorLength( const C3DTVector v )
	
	C3DTVector v1 = {{10.0f,10.0f,0.0f,1.0f}};
	float vecLength = vectorLength(v1);
	STAssertTrue( G3DCompareFloat( vecLength, 14.1f, 0.1f )==0, @"%f", vecLength );
}

- (void)testVectorNormalize {
	// C3DTVector vectorNormalize( C3DTVector v )

	C3DTVector v1 = {{10.0f,10.0f,0.0f,1.0f}};
	C3DTVector v2 = vectorNormalize(v1);
	
	STAssertFalse( v1.flts==v2.flts, nil );
	float vecLength = vectorLength(v2);
	STAssertTrue( G3DCompareFloat( vecLength, 1.0f, 0.1f)==0, @"%f", vecLength );
}

- (void)testVectorPerformance {
	
	// time for 2 seconds
	double startTime = sys_getrealtime();
	NSUInteger total  = 0;
	
	// Original way
	NSUInteger filterCount = 0;
	do {
		C3DTVector v1 = {{ random(),10.0f,0.0f,1.0f}};
		C3DTVector v2 = vectorNormalize(v1);
		total = total+v2.flts[0];
		filterCount++;
	} while( (sys_getrealtime()-startTime)<2.0 );
	
	NSLog(@"Old way %i", filterCount); 
	
	// GCC 64-bit
	/* With - debug */
	// 128,933,87 -- 129,281,65
	// release
	// 150,093,81 -- 150,068,17

	/* without */
	// debug build
	// 138,141,87 -- 138,094,06
	// release build
	// 164,150,50 -- 164,175,33
	// 164,455,46
	// 16448599
	
	// CLANG 64-bit Release
	// with 
	// 154,128,05
	
	// without
	// 193,800,11
	// 194,057,47
	// 193,574,62
}



@end







