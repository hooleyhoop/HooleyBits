//
//  InnerRenderAppDelegate.h
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InnerRenderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
