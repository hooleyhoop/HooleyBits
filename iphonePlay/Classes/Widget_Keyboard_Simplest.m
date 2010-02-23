//
//  Widget_Keyboard_Simplest.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Widget_Keyboard_Simplest.h"
#import "Layer_key.h"
#import "LogController.h"
#import "HooleyTouchEvent.h"
#import "GridLayout.h"
#import "Layer_Base.h"

#define X_CELLS 12
#define Y_CELLS 7

@implementation Widget_Keyboard_Simplest

@synthesize layoutManager;

- (id)init {
		
	self = [super init];
	if(self){
		widgetLayer = [[Layer_Base layer] retain];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		float onColVals[4] = { 255/255.0f, 255/255.0f, 0/255.0f, 1.0};
		float offColVals[4] = { 255/255.0f, 255/255.0f, 255/255.0f, 1.0};
		float errColVals[4] = { 255/255.0f, 0/255.0f, 0/255.0f, 1.0};
		float backgroundColVals[4] = { 125/255.0f, 0/255.0f, 0/255.0f, 0.65};
		float borderColVals[4] = { 0/255.0f, 127/255.0f, 127/255.0f, 1.0};
		onColour = CGColorCreate( colorSpace, onColVals );
		offColour = CGColorCreate( colorSpace, offColVals );
		errColour = CGColorCreate( colorSpace, errColVals );
		backgroundColour = CGColorCreate( colorSpace, backgroundColVals );
		borderColour = CGColorCreate( colorSpace, borderColVals );
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	
	[layoutManager release];
	[widgetLayer removeFromSuperlayer];
	[widgetLayer release];
	CGColorRelease(onColour); 
	CGColorRelease(offColour); 
	CGColorRelease(errColour); 
	[super dealloc];
}

- (void)addToView:(UIView *)aView {

	view = aView;
}

- (void)removeFromView:(UIView *)aView {

}

/* Have we touched a key ? */
- (void)touchBegan:(HooleyTouchEvent *)hTouchEvent {
	
	CALayer *hitKeyLayer = [widgetLayer hitTest:hTouchEvent.pt];
	if( hitKeyLayer && hitKeyLayer!=widgetLayer )
		[self _pressedKeyLayer:(Layer_key *)hitKeyLayer withTouch:hTouchEvent];
}

- (void)touchMoved:(HooleyTouchEvent *)hTouchEvent {
	
	// was this touch on a key last time round?
	Layer_Base *prevHitKeyLayer = [self keyPressedByTouch:hTouchEvent];
	CALayer *hitKeyLayer = [widgetLayer hitTest:hTouchEvent.pt];


	// Has it moved off that key? Stop the note if it has
	if( prevHitKeyLayer &&hitKeyLayer!=prevHitKeyLayer )
	{
		[self _releasedKeyLayer:(Layer_key *)prevHitKeyLayer];
		
		// has it moved onto a different key? Start the new note if it has
		if( hitKeyLayer && hitKeyLayer!=widgetLayer )
			[self _pressedKeyLayer:(Layer_key *)hitKeyLayer withTouch:hTouchEvent];

	} else {
		// has it moved onto a key? Start the new note if it has
		if( hitKeyLayer && hitKeyLayer!=widgetLayer )
			[self _pressedKeyLayer:(Layer_key *)hitKeyLayer withTouch:hTouchEvent];
	}
}

- (void)touchEnded:(HooleyTouchEvent *)hTouchEvent {

	// is this touch stored by one of our keys?
	Layer_Base *hitKeyLayer = [self keyPressedByTouch:hTouchEvent];
	if( hitKeyLayer!=nil)
		[self _releasedKeyLayer:(Layer_key *)hitKeyLayer];
}

- (Layer_key *)keyPressedByTouch:(HooleyTouchEvent *)hTouchEvent {
	
	for(Layer_key *each in widgetLayer.sublayers){
		if(each.touch==hTouchEvent)
			return each;
	}
	return nil;
}

- (void)_pressedKeyLayer:(Layer_key *)lyr withTouch:(HooleyTouchEvent *)hTouchEvent {
	
	if( [lyr.state isEqualToString:@"UP"] )
	{
		int hitIndex = [[widgetLayer sublayers] indexOfObject:lyr];
		BOOL success = [keyboard pressedKey:hitIndex];
		if(success){
//			lyr.backgroundColor = onColour;
			lyr.state = @"DOWN";
//			lyr.position = CGPointMake(lyr.position.x-5, lyr.position.y-5);
//			lyr.zPosition = +100.0f;
		} else {
//			lyr.backgroundColor = errColour;
			lyr.state = @"ERROR";
		}
		
		/* only need to do this if we want to draw something different - no nesaccary to change colour */
		[lyr setNeedsDisplay];

		// we will save the custom touch event so we can match it up with touchMoved and touchEneded events
		lyr.touch = hTouchEvent;
	}
}

- (void)_releasedKeyLayer:(Layer_key *)lyr {

	if( [lyr.state isEqualToString:@"DOWN"] || [lyr.state isEqualToString:@"ERROR"] )
	{
		int hitIndex = [[widgetLayer sublayers] indexOfObject:lyr];
		[keyboard releasedKey:hitIndex];
//		lyr.backgroundColor = offColour;
		lyr.state = @"UP";
		lyr.touch = nil;
//		lyr.zPosition = 0.0f;
		
		/* only need to do this if we want to draw something different - no nesaccary to change colour */
		[lyr setNeedsDisplay];
	}
}

- (void)setModel:(SHooleyObject<KeyboardProtocol> *)keybrd {

	keyboard = keybrd;
}

- (void)_setupKeys {
	
	NSAssert(view && keyboard, @"Not ready to setup keys");
	NSAssert([[widgetLayer sublayers] count]==0, @"should not do this more than once");
	NSAssert(layoutManager, @"need a layout manager to do layout");

	widgetLayer.anchorPoint = CGPointMake( 0.f, 0.f );
	widgetLayer.position = CGPointMake( 0, 0 );
	widgetLayer.bounds = CGRectMake(0, 0, 300, 400 );
	widgetLayer.backgroundColor = backgroundColour;
	[view.layer addSublayer:widgetLayer];

	layoutManager.gridWidth = 300;
	layoutManager.gridHeight = 400;
	layoutManager.margin = -4;
	layoutManager.xCells = X_CELLS;
	layoutManager.yCells = Y_CELLS;

//	Isometric
//	!bottom right key is backmost layer
//	keys will need to overlap
	
	/* lets see what the layout manager gives us */
	NSArray *cellRects = [layoutManager cellRects];
	for( NSUInteger i=0; i<[cellRects count]; i++)
	{
		// put rects down in reverse order
		int rectIndex = [cellRects count]-1-i;

		NSValue *each = [cellRects objectAtIndex:rectIndex];
		CGRect rectValue = [each CGRectValue];
		Layer_key *keyLayer = [Layer_key layer];
		[widgetLayer addSublayer:keyLayer];

		keyLayer.bounds = CGRectMake(0, 0, rectValue.size.width, rectValue.size.height );
		keyLayer.anchorPoint = CGPointMake( 0.f, 0.0f );
		keyLayer.position = CGPointMake( rectValue.origin.x, rectValue.origin.y );
//		keyLayer.backgroundColor = offColour;
		keyLayer.delegate = self;
		[keyLayer setText:[keyboard nameOfKey:rectIndex]];
		[keyLayer setNeedsDisplay];
	}

}

- (void)relayout {
//	NSAssert(view, @"how can we layout?");
//s	[self _setupKeys];
//	logInfo( @"Size changed? %@", NSStringFromRect( NSRectFromCGRect( view.frame) ) );
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key {
	return (id)[NSNull null];
}


- (CGSize)neededSizeForScrollFrame:(CGRect)frame {
	
	layoutManager.gridWidth = CGRectGetWidth(frame);
	layoutManager.gridHeight = CGRectGetHeight(frame);
	layoutManager.margin = -4;
	layoutManager.xCells = X_CELLS;
	layoutManager.yCells = Y_CELLS;
	return [layoutManager size];
}

@end
