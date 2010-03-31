//
//  ActorKitTestAppDelegate.h
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActorKitTestViewController;

@interface ActorKitTestAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;
    ActorKitTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ActorKitTestViewController *viewController;

@end

