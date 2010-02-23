//
//  CALayerRootView.m
//  CALayerLayout
//
//  Created by steve hooley on 25/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CALayerRootView.h"
#import <QuartzCore/QuartzCore.h>
#import "HooleyLayer.h"
#import "ViewController.h"

@implementation CALayerRootView

@synthesize mouseDownPoint = _mouseDownPoint;


- (id)initWithFrame:(NSRect)frame {
	
	BOOL jag;
    self = [super initWithFrame:frame];
    if (self) {
		NSColor* gradientBottom = [NSColor colorWithCalibratedWhite:0.10 alpha:1.0];
		NSColor* gradientTop    = [NSColor colorWithCalibratedWhite:0.35 alpha:1.0];
		_gradient = [[NSGradient alloc] initWithStartingColor:gradientBottom endingColor:gradientTop];
    }
    return self;
}

- (void)dealloc {

	[_gradient release];
	[super dealloc];
}

- (void)awakeFromNib {
	[[self window] setPreferredBackingLocation: NSWindowBackingLocationVideoMemory];
}

- (void)configureMainView {
	
    // create a layer and match its frame to the view's frame
	self.layer = [CALayer layer];
    self.wantsLayer = YES;
    CALayer* mainLayer = self.layer;
    mainLayer.name = @"mainLayer";
    mainLayer.delegate = self;	
	mainLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:nil];
}

- (void)drawRect:(NSRect)rect {

	if ([self inLiveResize]==NO){
		[_gradient drawInRect:self.bounds angle:90.0];
	}
}

- (void)resizeSubLayersOf:(CALayer *)lyr {
	
	// reposition the mutha fucking layers?
	HooleyLayer *eachLayer;
	id subLyrs = [lyr sublayers];
	for( eachLayer in subLyrs ){
		[eachLayer setNeedsLayout];
	}
}

- (void)viewFrameChanged:(NSNotification *)note {

//	[CATransaction begin];
//	[CATransaction setValue: [NSNumber numberWithBool:0.1] forKey: kCATransactionAnimationDuration];
	CALayer *rLayer = self.layer;
	[self resizeSubLayersOf:rLayer];
//	[CATransaction commit];
}

- (void)keyDown:(NSEvent*)event
{
    // clear all existing layers
    // self.containerLayerForSpheres.sublayers = [NSArray array];
	
    // toggle fullscreen mode
    if ( self.isInFullScreenMode )
        [self exitFullScreenModeWithOptions:nil];
    else
        [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
	
    // once the screen format changes, reset the spheres
//    NSUInteger sphereCount = self.countOfSpheresToGenerate;
//    NSUInteger i;
//    for ( i = 0; i < sphereCount; i++ )
//    {
//        [self generateGlowingSphereLayer];        
//    }    
}

- (void)mouseDown:(NSEvent*)theEvent
{
    // convert to local coordinate system
    NSPoint mousePointInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
	
    // convert to CGPoint for convenience
    CGPoint cgMousePointInView = NSPointToCGPoint(mousePointInView);
	
    // save the original mouse down as a instance variable, so that we
    // can start a new animation from here, if necessary.
    self.mouseDownPoint = cgMousePointInView;

	CALayer *layer = [self.layer hitTest: _mouseDownPoint];
	if([layer isKindOfClass:[HooleyLayer class]]){
		[_viewController hitLayer:layer];
	}
    // stop animating everything and move all the sphere layers so that
    // they're directly under the mouse pointer.
//    NSArray* sublayers = self.containerLayerForSpheres.sublayers;
//    for ( CALayer* layer in sublayers)
//    {
//        [layer removeAllAnimations];
//        layer.position = cgMousePointInView;
//    }
	
}


- (void)mouseDragged:(NSEvent*)theEvent
{
    // convert to local coordinate system
    NSPoint mousePointInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
	
    // convert to CGPoint for convenience
    CGPoint cgMousePointInView = NSPointToCGPoint(mousePointInView);
    
    // save the original mouse down as a instance variables, so that we
    // can start a new animation from here, if necessary.
    self.mouseDownPoint = cgMousePointInView;
	
	CALayer *layer = [self.layer hitTest: _mouseDownPoint];
	if([layer isKindOfClass:[HooleyLayer class]]){
		[_viewController hitLayer:layer];
	} else {
		[_viewController hitLayer:nil];
	}
//    [CATransaction begin];
	
	// make sure the dragging happens immediately. we set a specific
	// value here in case we want to it be nearly instant (0.1) later        
//	[CATransaction setValue: [NSNumber numberWithBool:0.0] forKey: kCATransactionAnimationDuration];
	
//	NSArray* sublayers = self.containerLayerForSpheres.sublayers;
//	for ( CALayer* layer in sublayers)
//	{
//		[layer removeAllAnimations];
//		layer.position = cgMousePointInView;    
//	}
	
//	[CATransaction commit];
}

- (void)mouseUp:(NSEvent*)anEvent
{
    // start new animation paths for all of the spheres
//    NSArray* sublayers = self.containerLayerForSpheres.sublayers;
//    for ( CALayer* layer in sublayers )
//    {
//        // "movementPath" is a custom key for just this app
//        CAAnimation* animation = [self randomPathAnimationWithStartingPoint:self.mouseDownPoint];
//        [layer addAnimation:animation forKey:@"movementPath"];
//    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}


@end
