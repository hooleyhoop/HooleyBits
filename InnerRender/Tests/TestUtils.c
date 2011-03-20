//
//  TestUtils.c
//  InnerRender
//
//  Created by Steven Hooley on 19/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#include "TestUtils.h"

#import <sys/time.h>

// gettimeofday is microsecond accurate. for higher resolution (nanosecond) switch to http://developer.apple.com/library/mac/#qa/qa2004/qa1398.html
double sys_getrealtime(void) {
	
    static struct timeval then;
    struct timeval now;
    gettimeofday(&now, 0);
    if (then.tv_sec == 0 && then.tv_usec == 0) then = now;
    return ((now.tv_sec - then.tv_sec) + (1./1000000.) * (now.tv_usec - then.tv_usec));
}