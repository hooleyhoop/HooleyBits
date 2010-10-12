//
//  GenericTimer.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "GenericTimer.h"
#import <sys/time.h>

// gettimeofday is microsecond accurate. for higher resolution (nanosecond) switch to http://developer.apple.com/library/mac/#qa/qa2004/qa1398.html

double sys_getrealtime(void) {
	
    static struct timeval then;
    struct timeval now;
    gettimeofday(&now, 0);
    if (then.tv_sec == 0 && then.tv_usec == 0) then = now;
    return ((now.tv_sec - then.tv_sec) + (1./1000000.) * (now.tv_usec - then.tv_usec));
}

@implementation GenericTimer

- (id)init {

	self = [super init];
	if(self){
		_startTime = sys_getrealtime();
	}
	return self;
}

- (void)dealloc {

	[super dealloc];
}

- (void)close {
	double time = sys_getrealtime()-_startTime;
	NSLog(@"Timer took %f", time);
}

@end
