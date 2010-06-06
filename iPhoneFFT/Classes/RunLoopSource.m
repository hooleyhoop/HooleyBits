//
//  RunloopSource.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 05/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RunloopSource.h"
#import "RunLoopContext.h"

@implementation RunLoopSource

// Listing 3-7  Installing the run loop source
- (id)init {

	CFRunLoopSourceContext context = {0, self, NULL, NULL, NULL, NULL, NULL, &RunLoopSourceScheduleRoutine, RunLoopSourceCancelRoutine, RunLoopSourcePerformRoutine};
	
    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    commands = [[NSMutableArray alloc] init];
	
    return self;
}

- (void)addToCurrentRunLoop {

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}

// Listing 3-4  Scheduling a run loop source
void RunLoopSourceScheduleRoutine( void *info, CFRunLoopRef rl, CFStringRef mode ) {

    RunLoopSource* obj = (RunLoopSource*)info;
//    AppDelegate*   del = [AppDelegate sharedAppDelegate];
 //   RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
	
//    [del performSelectorOnMainThread:@selector(registerSource:) withObject:theContext waitUntilDone:NO];
}

// Listing 3-5  Performing work in the input source
void RunLoopSourcePerformRoutine( void *info ) {

    RunLoopSource *obj = (RunLoopSource *)info;
    [obj sourceFired];
}

// Listing 3-6  Invalidating an input source
void RunLoopSourceCancelRoutine( void *info, CFRunLoopRef rl, CFStringRef mode ) {

//    RunLoopSource* obj = (RunLoopSource*)info;
//    AppDelegate* del = [AppDelegate sharedAppDelegate];
//    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
//	
//    [del performSelectorOnMainThread:@selector(removeSource:) withObject:theContext waitUntilDone:YES];
}

- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop {

    CFRunLoopSourceSignal(runLoopSource);
    CFRunLoopWakeUp(runloop);
}

- (void)invalidate {
	
}

// Handler method
- (void)sourceFired {
	
}


// Client interface for registering commands to process
- (void)addCommand:(NSInteger)command withData:(id)data {
	
}

- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runloop {
	
}
@end




