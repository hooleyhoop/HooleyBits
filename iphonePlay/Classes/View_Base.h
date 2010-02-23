//
//  View_Base.h
//  iphonePlay
//
//  Created by steve hooley on 20/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface View_Base : UIView {

	UIViewController *viewController;
}

@property (assign, nonatomic) UIViewController *viewController;

@end
