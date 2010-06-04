//
//  iPhoneFFTAppDelegate.h
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/05/2010.
//  Copyright Tinsal Parks 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPhoneFFTViewController;
@class IPhoneFFT;
@class AudioSessionStuff;

@interface iPhoneFFTAppDelegate : NSObject <UIApplicationDelegate> {
	
    UIWindow				*window;
    iPhoneFFTViewController	*viewController;
	IPhoneFFT				*_iPhoneFFT;
	AudioSessionStuff		*_audioSessionManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPhoneFFTViewController *viewController;

@end

