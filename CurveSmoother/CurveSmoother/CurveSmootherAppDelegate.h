//
//  CurveSmootherAppDelegate.h
//  CurveSmoother
//
//  Created by Steven Hooley on 26/02/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CurveSmootherAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
