//
//  NSInvocation_testFutures.h
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
@class AsyncTests;

@interface NSInvocation_testFutures : NSObject {

}

// These just pospone calling the actual assert methods in AsyncTests
+ (NSInvocation *)_assertEqualObjectsInvocation:(AsyncTests *)tests expectedResult:(id)ob2;
+ (NSInvocation *)_assertFailInvocation:(AsyncTests *)tests;
+ (NSInvocation *)_assertTrueInvocation:(AsyncTests *)tests;
+ (NSInvocation *)_assertResultNilInvocation:(AsyncTests *)tests;
+ (NSInvocation *)_assertResultNotNilInvocation:(AsyncTests *)tests;

@end
