//
//  RootViewControllerTests.m
//  iphonePlay
//
//  Created by Steven Hooley on 2/23/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "RootViewController.h"


@interface RootViewControllerTests : SenTestCase {
	
	RootViewController *viewController;
}

@end


@implementation RootViewControllerTests

- (void)setUp {
	
	viewController = [[RootViewController alloc] init];
}

- (void)tearDown {
	
	[viewController release];
}

- (void)testInactiveViewController {
	//- (UIViewController *)inactiveViewController
	
	ViewController_Base *vc1 = [[[ViewController_Base alloc] init] autorelease];
	ViewController_Base *vc2 = [[[ViewController_Base alloc] init] autorelease];
	[viewController setPrimaryViewController:vc1 secondaryViewController:vc2];
	STAssertTrue( [viewController activeViewController]==vc1, @"should default to main viewController");
	STAssertTrue( [viewController inactiveViewController]==vc2, @"should default to main viewController");
}

- (void)testToggleView {
	// - (IBAction)toggleView;

	ViewController_Base *vc1 = [[[ViewController_Base alloc] init] autorelease];
	ViewController_Base *vc2 = [[[ViewController_Base alloc] init] autorelease];

	[viewController setPrimaryViewController:vc1 secondaryViewController:vc2];
	STAssertTrue( [viewController activeViewController]==vc1, @"should default to main viewController");
	
	[viewController toggleActiveView];
	STAssertTrue( [viewController activeViewController]==vc2, @"Info view should be active");
	
	[viewController toggleActiveView];
	STAssertTrue( [viewController activeViewController]==vc1, @"Main view should be active");
}

@end
