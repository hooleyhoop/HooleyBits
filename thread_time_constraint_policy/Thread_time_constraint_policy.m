//
//  Thread_time_constraint_policy.m
//  thread_time_constraint_policy
//
//  Created by Steven Hooley on 22/08/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Thread_time_constraint_policy.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <pthread.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <mach/thread_policy.h>

#define PROGNAME "thread_time_constraint_policy"
   
#define SLEEP_NS 50000000 // sleep for 50 ms

// if actual sleeping time differs from SLEEP_NS by more than this amount,
// count it as an error
#define ERROR_THRESH_NS ((double)50000) // 50 us
#define REALTIME 1

static double             abs2clock;
static unsigned long long nerrors = 0, nsamples = 0;
static struct timespec    rqt = { 0, SLEEP_NS };

// before exiting, print the information we collected
void atexit_handler(void)
{
    printf("%llu errors in %llu samples\n", nerrors, nsamples);
}

void * timestamper(void *arg)
{
    int       ret;
    double    diff_ns;
    u_int64_t t1, t2, diff;
   
    while (1) {
        t1 = mach_absolute_time();   // take a high-resolution timestamp
        ret = nanosleep(&rqt, NULL); // sleep for SLEEP_NS seconds
        t2 = mach_absolute_time();   // take another high-resolution timestamp
        if (ret != 0)                // if sleeping failed, give up
            exit(1);
        diff = t2 - t1;              // how much did we sleep?
   
        // the "error" (in nanoseconds) in our sleeping time
        diff_ns = ((double)SLEEP_NS) - (double)diff * abs2clock;
   
        if (diff_ns < 0)
            diff_ns *= -1;
   
        if (diff_ns > ERROR_THRESH_NS)
            nerrors++;
   
        nsamples++;
		NSLog(@"yelp");
    }
   
    return NULL;
}

@implementation Thread_time_constraint_policy

- (void)awakeFromNib
{
    int           ret;
    kern_return_t kr;
    pthread_t     t1;
    static double clock2abs;
    mach_timebase_info_data_t            tbinfo;
    thread_time_constraint_policy_data_t policy;
    ret = pthread_create(&t1, (pthread_attr_t *)0, timestamper, (void *)0);
    ret = atexit(atexit_handler);
    (void)mach_timebase_info(&tbinfo);
    abs2clock = ((double)tbinfo.numer / (double)tbinfo.denom);
	
    // if any command-line argument is given, enable real-time
    if(REALTIME)
	{
        clock2abs = ((double)tbinfo.denom / (double)tbinfo.numer) * 1000000;
   
        policy.period      = 50 * clock2abs;	// 50 ms periodicity - time between
        policy.computation = 1 * clock2abs;		// 1 ms of work
        policy.constraint  = 2 * clock2abs;		// maximum. constraint - computation = latency
        policy.preemptible = FALSE;
   
        kr = thread_policy_set(pthread_mach_thread_np(t1), THREAD_TIME_CONSTRAINT_POLICY, (thread_policy_t)&policy, THREAD_TIME_CONSTRAINT_POLICY_COUNT);
        if (kr != KERN_SUCCESS) {
            mach_error("thread_policy_set:", kr);
            goto OUT;
        }
    }
   
    ret = pthread_detach(t1);
   
    printf("waiting 10 seconds...\n");
    sleep(10);
   
OUT:
    exit(0);
}

@end
