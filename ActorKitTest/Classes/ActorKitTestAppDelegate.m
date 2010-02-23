//
//  ActorKitTestAppDelegate.m
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "ActorKitTestAppDelegate.h"
#import "ActorKitTestViewController.h"
#import "ActorKit.h"
#import "ActorTest.h"
#import "HooAudioStreamer.h"

@implementation ActorKitTestAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	
	// Spawn a new actor thread. This will return a process instance which may be used
	// to deliver messages the new actor.
	NSThread *thisThread = [NSThread currentThread];
	NSLog(@"Main Thread %@", thisThread);
	
	// This will create a thread that we can call echo on
	id<PLActorProcess> proc = [PLActorKit spawnWithTarget:self selector:@selector(echo)];
	
	// Send a simple message to the actor.
	[proc send: [PLActorMessage messageWithObject: @"Hello"]];
	
	// Wait for the echo
	NSLog(@"Waiting for Message..");
	PLActorMessage *message = [PLActorKit receive];
	NSLog(@"Received message..");
	
	/* 
	 * Send a message a wait for the reply. 
	 * Allocate a unique transaction id
	 * Send a message with that transaction id
	 * Wait for a reply with a matching transaction id.
	 
	 PLActorRPC does this for us and waits on our behalf
	 
	 */
	id<PLActorProcess> helloActor = [PLActorKit spawnWithTarget:self selector:@selector(helloActor)];
	PLActorMessage *message2 = [PLActorMessage messageWithObject: @"Hello"];
	PLActorMessage *reply = [PLActorRPC sendRPC:message2 toProcess:helloActor];
	
	
	// NEW
	// By default, PLActorRPCProxy and PLRunloopRPCProxy will execute methods synchronously, waiting for completion prior to returning
	
	NSString *actorString = [PLActorRPCProxy proxyWithTarget: @"Hello"];
	NSString *runloopString = [PLRunloopRPCProxy proxyWithTarget: @"Hello" runLoop: [NSRunLoop mainRunLoop]];
	
	// Executes synchronously, via a newly created actor thread.
	[actorString description];
	
	// Executes synchronously, on the main runloop.
	[runloopString description];
	
	// In order to execute a method asynchronously -- allowing a long running method to execute without waiting for completion -- it is 
	// necessary to mark methods for asynchronous execution.
	// - (oneway void) asyncMethod {
	// Execute, asynchronously
	// }
	
	ActorTest *testProxy = [[[ActorTest alloc] init] autorelease];
	
	[testProxy asynchronousEcho:@"No way!" listener:self];
	NSString *returnedValue = [testProxy synchronousEcho:@"Boo"];
	
	
	/* Try to play an mp3 */
	_player = [[HooAudioStreamer alloc] initWithURL:[NSURL URLWithString:@"http://boos.audioboo.fm/attachments/144145/Recording.mp3"]];
	[_player start];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

- (void)echo {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PLActorMessage *message;
	
	NSThread *thisThread = [NSThread currentThread];
	NSLog(@"Thread %@", thisThread);
	// Loop forever, receiving messages
	while ((message = [PLActorKit receive]) != nil)
	{
		NSLog(@"ECHO Actor - Thread %@", thisThread);
		
		// Echo the same message back to the sender.
		[[message sender] send:message];
		
		// Flush the autorelease pool through every loop iteration
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		// i added the break to see if the threads clean up
		break;
	}
	NSLog(@"ECHO Actor - killing!");
	[pool release];
}

- (void)helloActor {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"helloActor on thread %@", [NSThread currentThread]);
	PLActorMessage *message;
	
	// Loop forever, receiving messages
	while ((message = [PLActorKit receive]) != nil){
		
		NSLog(@"helloActor - in loop Thread");
		
		// The caller is waiting for a reply and we will block if we don't respond.
		[[message sender] send:message];
		
		// Flush the autorelease pool through every loop iteration
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		// i added the break to see if the threads clean up
		break;
	}
	NSLog(@"helloActor - killing!");
	[pool release];
}


- (void)receiveEcho:(NSString *)text {
	NSLog(@"receiveEcho on thread %@, %@", [NSThread currentThread], text);
}


@end
