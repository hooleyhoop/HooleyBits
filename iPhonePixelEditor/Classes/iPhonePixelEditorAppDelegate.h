//
//  iPhonePixelEditorAppDelegate.h
//  iPhonePixelEditor
//
//  Created by steve hooley on 23/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface iPhonePixelEditorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

