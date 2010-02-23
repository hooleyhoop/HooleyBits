//
//  ViewController_info.m
//  iphonePlay
//
//  Created by steve hooley on 13/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "ViewController_info.h"


@implementation ViewController_info

@synthesize flipsideNavigationBar;

// Set up the navigation bar
// UINavigationBar *aNavigationBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
// aNavigationBar.barStyle = UIBarStyleBlackOpaque;
// self.flipsideNavigationBar = aNavigationBar;


//UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleView)] autorelease];
//UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:@"FlipSideInfoView"] autorelease];
//navigationItem.rightBarButtonItem = buttonItem;
//[flipsideNavigationBar pushNavigationItem:navigationItem animated:NO];

- (void)dealloc {
	
    [flipsideNavigationBar release];
    [super dealloc];
}

//        [self.view insertSubview:flipsideNavigationBar aboveSubview:flipsideView];

//        [flipsideNavigationBar removeFromSuperview];


@end
