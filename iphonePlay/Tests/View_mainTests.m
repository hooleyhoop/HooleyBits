//
//  View_mainTests.m
//  iphonePlay
//
//  Created by steve hooley on 18/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "View_main.h"

@interface View_mainTests : SenTestCase {
	
	View_main *customView;
}

@end

@implementation View_mainTests

- (void)setUp {
	
	customView = [[View_main alloc] initWithFrame:CGRectMake(0,0,800,600)];
}

- (void)tearDown {
	
	[customView release];
}


@end