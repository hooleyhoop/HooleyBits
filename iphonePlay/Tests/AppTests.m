//
//  AppTests.m
//  iphonePlay
//
//  Created by steve hooley on 28/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
	#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "iphonePlayAppDelegate.h"

@interface AppTests : SenTestCase {
	
	iphonePlayAppDelegate *appDelegate;
}

@end

@implementation AppTests

- (void)setUp {
	
	appDelegate = [[iphonePlayAppDelegate alloc] init];
}

- (void)tearDown {
	
	[appDelegate release];
}

- (void)testTest {
	
	[appDelegate activeKeyboard];
}

@end
