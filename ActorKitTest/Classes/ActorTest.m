//
//  ActorTest.m
//  iphonePlay
//
//  Created by Steven Hooley on 2/3/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "ActorTest.h"
#import "ActorKit.h"


@implementation ActorTest

- (id)init {

	if ((self = [super init]) == nil)
		return nil;
	
	// Launch our actor
	id proxy = [[PLActorRPCProxy alloc] initWithTarget: self];
	
	// Release ourself, as the proxy has retained our object,
	// and return our proxy to the caller
	[self release];
	return proxy;
}

// Method is called asynchronously
- (oneway void)asynchronousEcho:(NSString *)text listener:(id)echoListener {

	// callback from this new thread
	[echoListener receiveEcho:text];
	NSLog(@"asynchronousEcho on thread %@, %@", [NSThread currentThread], text);
}

// Method is called synchronously
- (NSString *)synchronousEcho:(NSString *)text {
	
	NSLog(@"synchronousEcho on thread %@, %@", [NSThread currentThread], text);
	return text;
}

@end
