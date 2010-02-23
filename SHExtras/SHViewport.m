//
//  SHViewport.m
//  InterfaceTest
//
//  Created by Steve Hooley on Wed May 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SHViewport.h"
// #import "SHCustomViewProtocol.h";
// #import "SHCustomViewController.h"

@implementation SHViewport


#pragma mark -
#pragma mark init methods
// ===========================================================
// - awakeFromNib:
// ===========================================================
- (void) awakeFromNib
{
	[self setAutoresizesSubviews:NO];
	_hasBeenResizedFlag = YES;
	[self setNeedsDisplay: YES];
}


/*
 * Resize ourself and supply the menubar and swapable view with
 * their new sizes
 */
//sh - (void) setHasBeenResized: (NSRect) newSize
//sh{
//sh	NSLog(@"SHViewport.m: setHasBeenResized");

//sh	hasBeenResizedFlag = YES;
//	[self setFrame: newSize];
	
	// bounds is always from zero to width, etc.
	//    newSize.origin.x = 0;
	//    newSize.origin.y = 0;
	//	[self setBounds: newSize];
	
	// resize openglView
	//	newSize.origin.x = 0;
	//    newSize.origin.y = 0;
	//	newSize.size.height = newSize.size.height - 24;
//sh	[theSHSwapableView setHasBeenResized:newSize];
	
	// resize menu bar
	//	newSize.origin.y = newSize.size.height;
	//	newSize.size.height =24;
	//	[theMenubarView setHasBeenResized:newSize];
	
//sh	[self setNeedsDisplay: YES];
//sh}



#pragma mark action methods
// ===========================================================
// - layOutAtNewSize
// ===========================================================
- (void) layOutAtNewSize
{
	// NSLog(@"SHViewport.m: layOutAtNewSize %@", _theSHSwapableView);

	_hasBeenResizedFlag = YES;
	[_theSHSwapableView layOutAtNewSize];
	[self setNeedsDisplay:YES];
}

// ===========================================================
// - viewDidEndLiveResize
// ===========================================================
- (void)viewDidEndLiveResize
{
	// NSLog(@"SHViewport.m: end live resize");
	[self layOutAtNewSize];
	[super viewDidEndLiveResize];
}


// ===========================================================
// - reDrawContents
// ===========================================================
- (void) reDrawContents
{
	[(NSView*)_theSHSwapableView setNeedsDisplay:YES];
}


// ===========================================================
// - makeViewMenu. Called from SHAppControl
// ===========================================================
//- (void)makeViewMenu
//{
//	[theMenubarView makeViewMenu];
//}
	

// ===========================================================
// - swapViews
// ===========================================================
// - (void)swapViews: (SHSwapableView*)viewArg
// {
//	currentView		= viewArg;
//	if(singleViewFlag) 
//		[self setFourView];
//	else 
//		[self setSingleView];
//}


/*
 * we are drawing the window infront of the opengl so this
 * has to be drawn clear
 */
- (void)drawRect:(NSRect)rect
{
//	if( ![self inLiveResize] )
//	{
//		if(_hasBeenResizedFlag)
//		{
//				_hasBeenResizedFlag = NO;
//		}
//	} else {
		
	//	NSRect r = [self bounds];
	//	r.origin.x = r.origin.x - 50;
	//	r.origin.y = r.origin.y - 50;
	//	r.size.width = r.size.width + 50;
	//	r.size.height = r.size.height + 50;
	//	[[NSColor clearColor] set];
	//	[[NSColor grayColor] set];
	//	[[NSColor redColor] set];

	//	NSRectFill(rect);
		_hasBeenResizedFlag = YES;
//	}
}


// ===========================================================
// - viewDidMoveToWindow:
// ===========================================================
- (void) viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
//	[[self window] setOpaque:NO];
//	[[self window] setAlphaValue:.999f];
	_hasBeenResizedFlag = YES;
	[self setNeedsDisplay: YES];
}



- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"keyDown.m: is keyDown theEvkeyDownent? ");
}

- (void) willCloseWindow
{
	NSLog(@"viewport.m: willBeRemovedFromViewPort ");

	[_theViewController willBeRemovedFromViewPort];
	[self setTheViewController:nil];
	[self setTheSHSwapableView:nil];
}

#pragma mark accessor methods


// ===========================================================
// - theViewController:
// ===========================================================
- (id<SHViewControllerProtocol>) theViewController{
	return _theViewController;
}


// ===========================================================
// - setTheViewController:
// ===========================================================
- (void) setTheViewController: (SHCustomViewController<SHViewControllerProtocol>*) aViewController
{
	//NSLog(@"SHViewport.m: theViewController is %@", aViewController );
	
	[(id)aViewController retain];
	[_theViewController willBeRemovedFromViewPort];
    [(id)_theViewController release];
    _theViewController = aViewController;
	[_theViewController willBeAddedToViewPort];
	
	
	[self setTheSHSwapableView: [(SHCustomViewController*)_theViewController swapableView]];
}

// ===========================================================
// - theSHSwapableView:
// ===========================================================
- (id<SHCustomViewProtocol>) theSHSwapableView 
{
    return _theSHSwapableView;
}

// ===========================================================
// - setTheSHSwapableView:
// ===========================================================
- (void) setTheSHSwapableView: (id<SHCustomViewProtocol>) aTheSHSwapableView
{
	[(NSView*)aTheSHSwapableView retain];
	// remove current view - still ok even if it is nil
	[(NSView*)_theSHSwapableView removeFromSuperview];
    [(NSView*)_theSHSwapableView release];
    _theSHSwapableView = aTheSHSwapableView;
	[self addSubview: (NSView*)_theSHSwapableView];
	[_theSHSwapableView layOutAtNewSize ];
	
	// NSLog(@"SHViewport.m: retainCount of swapView is %i", [aTheSHSwapableView retainCount] );
	// NSLog(@"SHViewport.m: swapableView is %@", aTheSHSwapableView );
	// NB! Swapable View must not retain the parent view!!
}

// ===========================================================
// - isOpaque:
// ===========================================================
- (BOOL) isOpaque{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
    return NO;
}

@end
