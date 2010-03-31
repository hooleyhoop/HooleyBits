//
//  main.m
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogController.h"
#import "SHInstanceCounter.h"
#import "SHSwizzler.h"

__attribute__((constructor))
void onStart(void) {
	printf("-- Starting Process --");

#ifdef NSDEBUGENABLED
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	[SHSwizzler insertDebugCodeForInitMethod:@"initWithFrame:" ofClass:@"UIWindow"];
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithCoder:" ofClass:@"UIWindow"];
	
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithFrame:" ofClass:@"UIView"];
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithCoder:" ofClass:@"UIView"];

	[SHSwizzler insertDebugCodeForInitMethod:@"initWithNibName:bundle:" ofClass:@"UIViewController"];
	
	[SHSwizzler insertDebugCodeForInitMethod:@"init" ofClass:@"CALayer"];

	[pool release];
#else
	#error SHIT
#endif
	
}

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
__attribute__((destructor)) void onExit() {
    
    static BOOL onExitCheck = NO;
    
    if(onExitCheck==NO)
    {
#ifdef NSDEBUGENABLED

        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        logInfo(@"-- Exiting process -- thread %i", [NSThread isMainThread]);
        [LogController killSharedLogController];
		
        if( [SHInstanceCounter instanceCount]<0 )
			[NSException raise:NSInvalidArgumentException format:@"freed too many hooleyObjects"];
        [pool release];
        
        pool = [[NSAutoreleasePool alloc] init];
		//        if( [SHInstanceCounter instanceCount]>0 ){
		//            [SHInstanceCounter printLeakingObjectInfo];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
		[SHInstanceCounter performSelector:@selector(cleanUpInstanceCounter) withObject:nil afterDelay:0.33];
        [SHInstanceCounter cleanUpInstanceCounter];
        [pool release];
		//		sleep(100);
        printf("done");
#endif
    } else {
        NSLog(@"!!EXITING AGAIN!!");
    }
}