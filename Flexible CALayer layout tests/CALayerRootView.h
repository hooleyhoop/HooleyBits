//
//  CALayerRootView.h
//  CALayerLayout
//
//  Created by steve hooley on 25/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ViewController;
@interface CALayerRootView : NSView {

	IBOutlet ViewController		*_viewController;
	CGPoint						_mouseDownPoint;
	NSGradient*					_gradient;

}
@property CGPoint mouseDownPoint;

- (void)configureMainView;

@end
