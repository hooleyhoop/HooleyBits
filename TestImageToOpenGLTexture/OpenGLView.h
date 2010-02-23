//
//  OpenGLView.h
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HooleyTexturedRect;

@interface OpenGLView : NSOpenGLView {

	NSTimer* drawTimer;
	NSMutableArray* drawables;
	CIContext* myCIContext;
	NSTrackingRectTag trackingRect;

}


- (void)addDrawableShape:(HooleyTexturedRect *)value;

- (NSMutableArray *)drawables;
- (void)setDrawables:(NSMutableArray *)newDrawables;

- (CIContext *)ciCntx;
@end
