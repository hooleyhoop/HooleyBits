//
//  ViewController_mainScreenTests.m
//  iphonePlay
//
//  Created by steve hooley on 24/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//


#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "ViewController_mainScreen.h"

#import "Widget_Keyboard_Simplest.h"

@interface ViewController_mainScreenTests : SenTestCase {
	
	Widget_Keyboard_Simplest *keyBoardWidget;
}

@end

@implementation ViewController_mainScreenTests

- (void)setUp {
	
	keyBoardWidget = [[Widget_Keyboard_Simplest alloc] init];
}

- (void)tearDown {
	
	[keyBoardWidget release];
}

- (void)testWidget {
	
}


@end
