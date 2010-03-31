//
//  RootViewController.m
//  FlipSideInfoView
//
//  Created by steve hooley on 20/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController_mainScreen.h"
#import "ViewController_info.h"
#import "View_Base.h"

@implementation RootViewController

@synthesize mainViewController, infoViewController, activeViewController;

/* When unaarchiving from the nib we will load sub view controllers - in unit tests set them yourself */
- (id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
    if(self) {
		
		// main view
		UIViewController *vc1 = [[[ViewController_mainScreen alloc] initWithNibName:@"View_main" bundle:nil] autorelease];
		
		// Info view
		UIViewController *vc2 = [[[ViewController_info alloc] initWithNibName:@"FlipsideView" bundle:nil] autorelease];
		[self setPrimaryViewController:vc1 secondaryViewController:vc2];
    }
    return self;
}

- (void)dealloc {

    [mainViewController release];
    [infoViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	[(View_Base *)self.view setViewController:self];
}

- (void)setPrimaryViewController:(UIViewController *)mainVC secondaryViewController:(UIViewController *)infoVC {
		
	self.mainViewController = (id)mainVC;
	self.infoViewController = (id)infoVC;
	self.activeViewController = mainViewController;
}

- (void)showActiveViewController {

	[activeViewController viewWillAppear:YES];
    [self.view addSubview:activeViewController.view];
	[activeViewController viewDidAppear:YES];
}

- (void)hideActiveViewController {

	[activeViewController viewWillDisappear:YES];
	[activeViewController.view removeFromSuperview];

	[activeViewController viewDidDisappear:YES];
}

- (void)toggleActiveView {
	
	self.activeViewController = self.inactiveViewController;
}
	
- (void)toggleView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:( activeViewController==mainViewController ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];

	[self hideActiveViewController];
	[self toggleActiveView];
	[self showActiveViewController];

	[UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	NSAssert(activeViewController, @"always must be one current");
	return [activeViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (UIViewController *)inactiveViewController {
	
	return (id)activeViewController==(id)mainViewController ? (id)infoViewController : (id)mainViewController;
}

@end
