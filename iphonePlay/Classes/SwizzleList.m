//
//  SwizzleList.m
//  iphonePlay
//
//  Created by steve hooley on 13/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SwizzleList.h"
#import "SHSwizzler.h"
#import "LogController.h"
#import "SHInstanceCounter.h"

@implementation SwizzleList

+ (void)setupSwizzles {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	/* Only Swizzle Custom Classes? UIViewController seems ok.. SHooleyObjects are already taken care of */
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithFrame:" ofClass:@"Window_Base"];
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithCoder:" ofClass:@"Window_Base"];

	[SHSwizzler insertDebugCodeForInitMethod:@"initWithNibName:bundle:" ofClass:@"ViewController_Base"];
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithCoder:" ofClass:@"ViewController_Base"];

	[SHSwizzler insertDebugCodeForInitMethod:@"initWithFrame:" ofClass:@"View_Base"];
	[SHSwizzler insertDebugCodeForInitMethod:@"initWithCoder:" ofClass:@"View_Base"];

	[SHSwizzler insertDebugCodeForInitMethod:@"init" ofClass:@"Layer_Base"];

	[pool release];
}

+ (void)tearDownSwizzles {
	
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
		//sleep(100);
        printf("done");
#endif
    } else {
        NSLog(@"!!EXITING AGAIN!!");
    }
}

@end
