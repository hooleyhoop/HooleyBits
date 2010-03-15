//
//  NSInvocation_testFutures.m
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "NSInvocation_testFutures.h"
#import "FSBlockConviences.h"
#import "AsyncTests.h"
#import <SHShared/NSInvocation(ForwardedConstruction).h>

@implementation NSInvocation_testFutures
// These just pospone calling the actual assert methods in AsyncTests

/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
+ (NSInvocation *)_assertEqualObjectsInvocation:(AsyncTests *)tests expectedResult:(id)ob2 {
	
	NSParameterAssert( tests );
	
	NSInvocation *outInv;
	
	// of course, result isn't available at this stage
	id result = nil;
	[[NSInvocation makeRetainedInvocationWithTarget:tests invocationOut:&outInv] assert_arg1:result arg2:ob2 ofBlock:[FSBlockConviences _assertEqualObjectsBlock] failMsg:nil];
	return outInv;
}

/* Construct an Invocation for the Notification - we aren't going to send it till we have a callback set */
+ (NSInvocation *)_assertFailInvocation:(AsyncTests *)tests {
	
	NSParameterAssert( tests );
	
	NSInvocation *outInv;
	
	// of course, result isn't available at this stage
	id result = nil;
	[[NSInvocation makeRetainedInvocationWithTarget:tests invocationOut:&outInv] assert_arg1:result ofBlock:[FSBlockConviences _assertFailBlock] failMsg:nil];
	return outInv;
}

+ (NSInvocation *)_assertTrueInvocation:(AsyncTests *)tests {
	
	NSParameterAssert( tests );
	
	NSInvocation *outInv;
	
	// of course, result isn't available at this stage
	id result = nil;
	[[NSInvocation makeRetainedInvocationWithTarget:tests invocationOut:&outInv] assert_arg1:result ofBlock:[FSBlockConviences _assertTrueBlock] failMsg:nil];
	return outInv;
}

+ (NSInvocation *)_assertResultNilInvocation:(AsyncTests *)tests {
	
	NSParameterAssert( tests );
	
	NSInvocation *outInv;
	
	// of course, result isn't available at this stage
	id result = nil;
	[[NSInvocation makeRetainedInvocationWithTarget:tests invocationOut:&outInv] assert_arg1:result ofBlock:[FSBlockConviences _assertNilBlock] failMsg:nil];
	return outInv;
}

+ (NSInvocation *)_assertResultNotNilInvocation:(AsyncTests *)tests {
	
	NSParameterAssert( tests );
	
	NSInvocation *outInv;
	
	// of course, result isn't available at this stage
	id result = nil;
	[[NSInvocation makeRetainedInvocationWithTarget:tests invocationOut:&outInv] assert_arg1:result ofBlock:[FSBlockConviences _assertNotNilBlock] failMsg:nil];
	return outInv;
}

@end
