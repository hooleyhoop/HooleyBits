//
//  RootViewController.h
//  FlipSideInfoView
//
//  Created by steve hooley on 20/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController_Base.h"
#import "SimpleViewSwitcherProtocol.h"

@class ViewController_mainScreen;
@class ViewController_info;

@interface RootViewController : ViewController_Base <SimpleViewSwitcherProtocol> {

    ViewController_mainScreen				*mainViewController;
    ViewController_info						*infoViewController;
	UIViewController						*activeViewController;
}

@property (retain, nonatomic) ViewController_mainScreen		*mainViewController;
@property (retain, nonatomic) ViewController_info			*infoViewController;
@property (assign, nonatomic) UIViewController				*activeViewController;

- (void)setPrimaryViewController:(UIViewController *)mainVC secondaryViewController:(UIViewController *)infoVC;

- (void)showActiveViewController;
- (void)hideActiveViewController; 

- (void)toggleView;
- (void)toggleActiveView;

- (UIViewController *)inactiveViewController;

@end
