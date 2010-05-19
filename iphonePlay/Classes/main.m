//
//  main.m
//  iphonePlay
//
//  Created by Steven Hooley on 1/15/09.
//  Copyright Bestbefore 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogController.h"
#import "SHInstanceCounter.h"
#import "SwizzleList.h"


__attribute__((constructor))
void onStart(void) {
	printf("-- Starting Process --");
	
#ifdef NSDEBUGENABLED
	
	[SwizzleList setupSwizzles];
#else
	#warning SHIT - enable NSDEBUGENABLED
#endif
}

void mysighandler(int sig, siginfo_t *info, void *context) {
	void *backtraceFrames[128];
//	int frameCount = backtrace(backtraceFrames, 128);
	
	// report the error
}

int main(int argc, char *argv[]) {

	struct sigaction mySigAction;
	mySigAction.sa_sigaction = mysighandler;
	mySigAction.sa_flags = SA_SIGINFO;
	sigemptyset(&mySigAction.sa_mask);
	sigaction(SIGQUIT, &mySigAction, NULL);
	sigaction(SIGILL, &mySigAction, NULL);
	sigaction(SIGTRAP, &mySigAction, NULL);
	sigaction(SIGABRT, &mySigAction, NULL);
	sigaction(SIGEMT, &mySigAction, NULL);
	sigaction(SIGFPE, &mySigAction, NULL);
	sigaction(SIGBUS, &mySigAction, NULL);
	sigaction(SIGSEGV, &mySigAction, NULL);
	sigaction(SIGSYS, &mySigAction, NULL);
	sigaction(SIGPIPE, &mySigAction, NULL);
	sigaction(SIGALRM, &mySigAction, NULL);
	sigaction(SIGXCPU, &mySigAction, NULL);
	sigaction(SIGXFSZ, &mySigAction, NULL);
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, @"CustomApplication", nil);
	[pool release];
	return retVal;
}

__attribute__((destructor)) void onExit(void) {
    
	[SwizzleList tearDownSwizzles];
}