//
//  SHSwapableView.m
//  InterfaceTest
//
//  Created by Steve Hooley on Fri Jan 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
//#import "SHAppControl.h"
#import "SHSwapableView.h"
//#import "SHAppView.h"
#import "SHCustomViewController.h"
//#import "C3DTColor.h"
//#import "C3DTEntity.h"
//#import "C3DTCamera.h"
//import "C3DTPlainSurface.h"
// #import "C3DTScene.h"
// #import "C3DTStringTexture.h"
//#import "SHMakeContextualMenu.h"
//#import "SHMainWindow.h"
//RR#import "Temp.h"
#include <sys/time.h>



@implementation SHSwapableView

#pragma mark -
#pragma mark init methods


// ===========================================================
// - dealloc:
// ===========================================================
- (void)dealloc
{
    [(id)_controller release];
    [_myCursor release];
	
    _myCursor = nil;
    _controller = nil;

    [super dealloc];
}


// ===========================================================
// - awakeFromNib:
// ===========================================================
- (void) awakeFromNib
{
//	_backgroundColor = [NSColor lightGrayColor];
//	[SHMakeContextualMenu makeContextualMenu: _contextualMenu on: self];
//	_trackRect = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:YES];
//	_hasBeenResizedFlag = YES;
//	ALT_DOWN = 0;
//	lastALT_DOWN = 0;
//	[[self window] discardCursorRects];
}

#pragma mark action methods


// ===========================================================
// - viewPointInCentreOfFrame:
// ===========================================================
//- (NSPoint)viewPointInCentreOfFrame
//{
//	NSRect boundsRect  = [self bounds];
//	NSRect frameRect   = [self frame];
//	
//	// typedef struct _NSRect {
//	//  NSPoint origin;
//	//    NSSize size;
//	// } NSRect;	
//	
//	GLfloat boundsRectx		= boundsRect.origin.x;
//	GLfloat boundsRecty		= boundsRect.origin.y;
//	// float boundsRectwidth   = boundsRect.size.width;
//	// float boundsRectheight  = boundsRect.size.height;
//	
//	// float frameRectx		= frameRect.origin.x;
//	// float frameRecty		= frameRect.origin.y;
//	GLfloat frameRectwidth	= frameRect.size.width;
//	GLfloat frameRectheight   = frameRect.size.height;
//			
//	// NSLog(@" ");
//	// NSLog(@" bounds %f, %f, %f, %f", boundsRectx, boundsRecty, boundsRectwidth, boundsRectheight );
//	// NSLog(@" frame  %f, %f, %f, %f", frameRectx, frameRecty, frameRectwidth, frameRectheight );
//	// NSLog(@" ");
//
//	NSPoint result;
//	result.x = frameRectwidth/2 + boundsRectx;
//	result.y = frameRectheight/2 + boundsRecty;
//	return result;
//}


// ===========================================================
//  - timedRedraw:
// ===========================================================
- (void) timedRedraw
{
    static double lastDrawTime = 0.0;

	struct timeval t;
	gettimeofday(&t, NULL);
	double currentTime = (double) t.tv_sec + (double) t.tv_usec / 1000000.0 ;

	if ( (currentTime - lastDrawTime) > (1.0/30.0) ) 
	{
		// NSLog(@"time since draw was %f compared to %f", (currentTime - lastDrawTime), (1.0/30.0) );
		[self setNeedsDisplay:YES];
		// [super setNeedsDisplay:YES];

		// [glView setNeedsDisplay:YES];
		lastDrawTime = currentTime;
	}
}


// ===========================================================
// - layOutAtNewSize:
// ===========================================================
- (void) layOutAtNewSize
{
	// NSLog(@"swapableView.m: layout at new size");
	_hasBeenResizedFlag = YES;
	[self removeTrackingRect:_trackRect];
	
	NSRect superViewRect = [[self superview] frame];
	superViewRect.origin.x = 0;
	superViewRect.origin.y = 0;	
	[self setFrame: superViewRect];	
	
	_trackRect = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:YES];
	[self timedRedraw];
}


// ===========================================================
// - setHasBeenResized: OLD
// ===========================================================
//- (void) setHasBeenResized: (NSRect) newSize
//{
//	NSLog(@"resizing swapable view");
//hasBeenResizedFlag = YES;
//	[self setFrame: newSize];
	
	// bounds is always from zero to width, etc.
//    newSize.origin.x = 0;
//    newSize.origin.y = 0;
//	[self setBounds: newSize];
//	[self reshape];
//	[self removeTrackingRect:trackRect];
//	trackRect = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:YES];
//}


// ===========================================================
// - refresh
// ===========================================================
- (void)refresh: (NSNotification *)aNotification
{
 //   [self setNeedsDisplay: YES];
	[self timedRedraw];
}

// ===========================================================
// - reshape
// ===========================================================
//- (void) reshape
//{
 //   [super reshape];
    // We don't use accessor here because reshape could be called before camera is set,
    // thus we'll go in an endless loop
 //   [self setNeedsDisplay: YES];
//}


#pragma mark mouse methods

// ===========================================================
//  - mouseDown:
// ===========================================================
//- (void)mouseDown:(NSEvent *)event
//{
////	NSLog(@"SHSwapableView.m: mouse down");
//	[self setGlobalModifierKeys:event];
//
//	_downPointInWindow   = [event locationInWindow];
//    _downPointInView     = [self convertPoint: _downPointInWindow fromView:self ];
//	
//	// NSLog(@"SHSwapableView.m: dwn x %f, down y %f", downPointInWindow.x, downPointInWindow.y);
//    _currentPointInWindow= _downPointInWindow;
//    _currentPointInView  = _downPointInView;
//	
//    _oldPointInWindow    = _downPointInWindow;
//	[self setMyCursor: [NSCursor arrowCursor]]; 
//}


// ===========================================================
//  - mouseUp:
// ===========================================================
//- (void)mouseUp:(NSEvent *)event
//{
////	NSLog(@"SHSwapableView.m: mouse up");
//	
//	[self setGlobalModifierKeys:event];
//	
//    _currentPointInWindow= [event locationInWindow];
//    _currentPointInView  = [self convertPoint:_currentPointInWindow fromView:nil ]; // convert from window co-ords to view co-ords
//	[self setMyCursor: [NSCursor arrowCursor]]; 
//}


// ===========================================================
//  - mouseUp:
// ===========================================================
//- (void)mouseDragged:(NSEvent *)event
//{
//	[self setGlobalModifierKeys:event];
//
//    _currentPointInWindow    = [event locationInWindow];
//    _currentPointInView      = [self convertPoint: _currentPointInWindow fromView:nil ]; // convert from window co-ords to view co-ords
//    // NSPoint distanceDragged = { (currentPointInWindow.x - oldPointInWindow.x), (currentPointInWindow.y - oldPointInWindow.y) };
//	// float distanceDraggedLength = sqrt(distanceDragged.x*distanceDragged.x +distanceDragged.y*distanceDragged.y);
//
//    GLfloat angleX, angleY;
//    angleX = _currentPointInWindow.x - _oldPointInWindow.x;
//    angleY = _currentPointInWindow.y - _oldPointInWindow.y;
//
//    if(ALT_DOWN!=0)
//    {   
//	    if(CMD_DOWN!=0)
//		{	
//		// ZOOM
//			// either of these (or both!) manage to zoom the camera (but not in orthographic)
//			// [_camera setDistance: [_camera distance] - angleY];  // zoom in with y mouse movement
//			// [_camera setFov: [_camera fov] + angleX];			// zoom in with x mouse movement
//			
//			// convert window space coords to ortho coords
//			// NSRect frameRect   = [self frame];
//			// float frameRectwidth = frameRect.size.width;
//
//		} else {
//		// PAN THE VIEW
//
//			[self setMyCursor: [NSCursor closedHandCursor]]; 
//			
////			NSLog(@"mouse dragged %f, %f", angleX, angleY );
//			[self altMouseDragActionX:angleX Y:angleY ];
//		}
//    } else {
//		[self setMyCursor: [NSCursor arrowCursor]]; 
//    }
//    _oldPointInWindow = _currentPointInWindow;
////	[self timedRedraw];
//
//}


// ===========================================================
// - altDragActionX: Y:
// ===========================================================
//- (void)altMouseDragActionX:(float)xarg Y:(float)yarg{}


// ===========================================================
// - mouseEntered:
// ===========================================================
//- (void)mouseEntered:(NSEvent *)event
//{
//	[self setGlobalModifierKeys:event];
//	[[self window] makeFirstResponder: self];
//}


// ===========================================================
// - mouseExited:
// ===========================================================
//- (void)mouseExited:(NSEvent *)event
//{
//	[self setGlobalModifierKeys:event];
//}

// ===========================================================
// - mouseMoved:
// ===========================================================
//- (void)mouseMoved:(NSEvent *)event
//{
//	// [self setGlobalModifierKeys:event];
//}


// ===========================================================
// - resetCursorRects
// ===========================================================
//- (void)resetCursorRects
//{
//	/* you need to overide this to stop it automatically
//	 * re instating the default arrow cursor. You need
//	 * never call it directly
//	*/
//	[super resetCursorRects];
//	[self addCursorRect:[self frame] cursor:_myCursor];
//}


// ===========================================================
// - keyDown:
// ===========================================================
//- (void)keyDown:(NSEvent *)event
//{
//    // event info: -(NSString*)characters, -(BOOL)isARepeat, -(unsigned short)keyCode, -(unsigned int)modifierFlags
//	//unsigned int modFlags   = [event modifierFlags];
//	//NSNumber* shiftPressed = [NSNumber numberWithUnsignedInt:(modFlags & NSShiftKeyMask)];
//    //NSNumber* altPressed =  [NSNumber numberWithUnsignedInt:(modFlags & NSAlternateKeyMask)];
//    // NSNumber* altPressed =  [NSNumber numberWithUnsignedInt:(modFlags)];
//   
//    // NSLog( @"alt pressed?%s", [altPressed stringValue] );
//    //NSLog( @"alt pressed? %@", altPressed );
//    // NSString* keypress   = [event characters];
//    // NSLog( @"key pressed? %s", keypress );
//    
//    unsigned short theKeyCode = [event keyCode];
////NS    NSNumber* kc = [NSNumber numberWithUnsignedShort:theKeyCode];
//	//NSLog( @"SHSwapable View.m: key pressed code ? %@", kc );
//    
//    // keycodes
//    // 49 is space
//    // 24 +
//    // 27 - 
//    // 69 + keypad
//    // 78 - keypad 
//	// 51 backspace
//	// 117 delete
//	
//    NSString* keypress   = [event charactersIgnoringModifiers];
//    //NSLog( @"key pressed? %@", keypress );
//    
////    if( [keypress isEqualToString:@"+"] || [keypress isEqualToString:@"="] )
////    {
////        NSLog( @"zoom in");
////
////    } else if( [keypress isEqualToString:@"-"]  ) {
////        NSLog( @"zoom out");
////    
////    } else if( [keypress isEqualToString:@" "]  ) {
////		[self spacePressed];
////    //   [(AppView*)[self superview] swapViews: self ];
////   } else if( theKeyCode==51 || theKeyCode==117) {
////		[self backSpacePressed];
////	}
//	[super keyDown:event];
//}
//
//
//// ===========================================================
//// - keyUp:
//// ===========================================================
//- (void) keyUp: (NSEvent *)event {
//	[self setMyCursor: [NSCursor arrowCursor]]; 
//	// NSLog(@"swapable view.m: KEY UP");
//}


#pragma mark accessor methods
// ===========================================================
// - setBackgroundColor:
// ===========================================================
- (void)setBackgroundColor:(NSColor*)aNSColor
{
	_backgroundColor = aNSColor;
    [self setNeedsDisplay: YES];
}

// ===========================================================
// - backgroundColor:
// ===========================================================
- (NSColor*)backgroundColor {
    return _backgroundColor;
}

// ===========================================================
// - swapableViewName:
// ===========================================================
- (NSString*)swapableViewName {
	return _swapableViewName;
}


// ===========================================================
// - setSwapableViewName:
// ===========================================================
- (void)setSwapableViewName:(NSString*)aNameString
{
    [aNameString retain];
    [_swapableViewName release];
	_swapableViewName = aNameString;
}



// ===========================================================
// - drawRect
// ===========================================================
//- (void)drawRect:(NSRect)rect 
//{
////	NSRect bounds = [self bounds];
//	// fill background
//
//		
//    // all drawing is done on the back buffer
//	// float transformX, transformY ;
//	// transformX = 2.0 * mousePoint.x / [self bounds].size.width - 1.0 ;
//	// transformY = 2.0 * mousePoint.y / [self bounds].size.height - 1.0 ;
//	
////	float red1, red2, green1, green2, blue1, blue2;
//
//
//    // NSAssert( theOutputControl != nil, @"displayString nil" );
//    
//	
//    // BACKGROUND
////a    NSPoint frameOrigin = b.origin;
////a    NSRect background = {frameOrigin,frameSize};
////a    [backgroundColor set];
////a    [NSBezierPath fillRect: background];
//    
//    // draw the path in white
//	// NSRect r = [self frame];
//	[[NSColor clearColor] set];
//	NSRectFill(rect);
//
////	[NSBezierPath strokeRect:bounds];
//    
////		if([[self window] firstResponder]==self)
////		{
////			[[NSColor blackColor] set];
////			[NSBezierPath strokeRect:bounds];
////		}
//		_hasBeenResizedFlag = NO;
//	
//    // transforms are the key
//	// - (void)transformUsingAffineTransform:(NSAffineTransform *)aTransform}
//}



//
//- (void)setCentrePoint: (NSPoint) oldCentre
//{
//	NSRect boundsRect  = [self bounds];
//	NSRect frameRect   = [self frame];
	
//	float boundsRectx		= boundsRect.origin.x;
//	float boundsRecty		= boundsRect.origin.y;
	// float boundsRectwidth   = boundsRect.size.width;
	// float boundsRectheight  = boundsRect.size.height;
	
	// float frameRectx		= frameRect.origin.x;
	// float frameRecty		= frameRect.origin.y;
//	float frameRectwidth	= frameRect.size.width;
//	float frameRectheight   = frameRect.size.height;
	
//	NSPoint currentCentre;
//	currentCentre.x = frameRectwidth/2 + boundsRectx;	
//	currentCentre.y = frameRectheight/2 + boundsRecty;	

//	float xdiff = currentCentre.x - oldCentre.x;
//	float ydiff = currentCentre.y - oldCentre.y;

//	boundsRect.origin.x = boundsRect.origin.x-xdiff;
//	boundsRect.origin.y = boundsRect.origin.y-ydiff;
	
//	boundsRect.origin.x = 0;
//	boundsRect.origin.y = 0;
//	[self setBounds: boundsRect];
//}


//
//- (BOOL)acceptsFirstResponder
//{
//    return NO;
//}
//
//- (BOOL)becomeFirstResponder
//{
////	NSLog(@"SHSwapableView is about to become the first responder");
//	[self setNeedsDisplay:YES];
//	return YES;
//}
//
//
//- (BOOL)resignFirstResponder
//{
//	//Notifies the receiver that it's not the first responder.
//// 	NSLog(@"BOO HOO!! SHSwapableView is about to not be the first responder!");
//	[self setNeedsDisplay:YES];
//	return YES;
//}




// ===========================================================
// - controller:
// ===========================================================
- (SHCustomViewController*)controller { return _controller; }

// ===========================================================
// - setController:
// ===========================================================
- (void)setController:(SHCustomViewController*)aController
{
    if (_controller != aController) {
        [aController retain];
        [(id)_controller release];
        _controller = aController;
    }
}



// default does nothing
// - (void)setObjectClickedOn:(C3DTEntity*)objectClickedOn{}




- (int)SHIFT_DOWN{
	return SHIFT_DOWN;
}
- (int)ALT_DOWN{
	return ALT_DOWN;
}
- (int)CMD_DOWN{
	return CMD_DOWN;
}

// this tells the window manager that nothing behind our view is visible
-(BOOL) isOpaque {
	return YES; // temp - set to yes when working
}


/*
 * Keep track of the modifier keys
*/
- (void) setGlobalModifierKeys:(NSEvent *)anEvent
{
    unsigned int modFlags   = [anEvent modifierFlags];
    SHIFT_DOWN		= (modFlags & NSShiftKeyMask) >> 17;
	ALT_DOWN		= (modFlags & NSAlternateKeyMask) >> 19;
	CMD_DOWN		= (modFlags & NSCommandKeyMask) >> 20;
}

- (void) altUp{NSLog(@"alt up");}
- (void) altDown{NSLog(@"alt down");}

//- (void) registerWith: (id)aSender forNotification: (NSString *)aNotification
//{
//	NSLog(@"registering");
//    [[NSNotificationCenter defaultCenter] addObserver: self  selector: @selector(refresh:)  name: aNotification object: aSender];
//}



//- (void)unregisterWith: (id)aSender forNotification: (NSString *)aNotification
//{
//	NSLog(@"unregistering");
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//    [dc removeObserver: (id)(self) name: @"eh?" object: (id)(aSender)];
//}



// ===========================================================
// - backSpacePressed:
// ===========================================================
//- (void)backSpacePressed
//{
//	NSLog( @"Back Space or Delete pressed");
//}

// ===========================================================
// - spacePressed:
// ===========================================================
//- (void)spacePressed
//{
//	NSLog( @"space pressed");
//}


//=========================================================== 
// - myCursor:
//=========================================================== 
//- (NSCursor *)myCursor { return _myCursor; }
//
////=========================================================== 
//// - setMyCursor:
////=========================================================== 
//- (void)setMyCursor:(NSCursor *)aMyCursor
//{
//    if (_myCursor != aMyCursor) {
//		[super resetCursorRects];
//
//        [aMyCursor retain];
//        [_myCursor release];
//        _myCursor = aMyCursor;
//		[_myCursor set];
//    }
//}



@end
