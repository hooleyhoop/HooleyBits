//
//  VeryLargePtrTableTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import <sys/time.h>
#import <objc/objc-runtime.h>
#import "Line.h"
#import <CHDataStructures/CHRedBlackTree.h>

// gettimeofday is microsecond accurate. for higher resolution (nanosecond) switch to http://developer.apple.com/library/mac/#qa/qa2004/qa1398.html
double sys_getrealtime(void) {
	
    static struct timeval then;
    struct timeval now;
    gettimeofday(&now, 0);
    if (then.tv_sec == 0 && then.tv_usec == 0) then = now;
    return ((now.tv_sec - then.tv_sec) + (1./1000000.) * (now.tv_usec - then.tv_usec));
}

@interface VeryLargePtrTableTests : SenTestCase {
	
}

@end


@implementation VeryLargePtrTableTests


- (void)testShit {
	
	// Store 1 million lines
	NSUInteger limit = 1000000;
	NSMutableArray *lineStore = [NSMutableArray arrayWithCapacity:1000000];
	for( NSUInteger i=0; i<limit; i++ ){
		[lineStore addObject:[Line lineWithAddress:i*10]];
	}
	// 1.741815 secs
	
	// find insertion point for an object near the end of the array
	Line *insertObject = [Line lineWithAddress:999999*10];

	NSUInteger low = 0;
	NSUInteger high  = [lineStore count];
	NSUInteger index = low;

    while( index < high ) {
        const NSUInteger mid = (index + high)/2;
        id test = [lineStore objectAtIndex: mid];
		NSInteger result = [test compareAddress:insertObject];
        if ( result < 0) {
            index = mid + 1;
        } else {
            high = mid;
        }
    }
	// 0.011398 secs

	/*
	 *
	 */
	/* Try funny data structure */
	
	CHRedBlackTree *tree = [[[CHRedBlackTree alloc] init] autorelease];
	for( NSUInteger i=0; i<limit; i++ ){
		[tree addObject:[Line lineWithAddress:i*10]];
	}
	// 1.610219
	
	double startTime = sys_getrealtime();

	double endTime = sys_getrealtime();
	STFail(@"woo took a long time %f", endTime-startTime);
}


@end
