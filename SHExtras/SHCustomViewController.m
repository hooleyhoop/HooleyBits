//
//  SHCustomViewController.m
//  Pharm
//
//  Created by Steve Hooley on 11/08/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SHCustomViewController.h"
//#import "SHCustomViewProtocol.h"
//#import "SHAuxWindow.h"
//#import "SHViewport.h"


NSString* _windowTitle = @"Default Window Name";

@implementation SHCustomViewController



#pragma mark -
#pragma mark init methods
// init
- (id)init {
    if (self = [super init]) {
        [self setIsInViewPort: NO];
        [self setIsInWindow: NO];
		_enabled = NO;
    }
    return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {

    [super dealloc];
}

#pragma mark action methods
//=========================================================== 
//  launchInWindow 
//=========================================================== 
- (void) hasBeenLaunchedInWindow
{
	BOOL i;
//	[self setIsInWindow:YES];
//	[self setIsInViewPort:NO];
//	NSAssert( [_swapableView superview] != nil, @"SHCustomViewController: ERROR: Should have been added to window but superview is nil" );
	[_swapableView setFrame: [[_swapableView superview] frame]];

}

// ===========================================================
// - willBeRemovedFromViewPort
// ===========================================================
- (void) willBeRemovedFromViewPort{
	BOOL i;
	[self setIsInViewPort: NO];
//	[self setIsInWindow: NO];
}

// ===========================================================
// - willBeAddedToViewPort
// ===========================================================
- (void) willBeAddedToViewPort{
	[self setIsInViewPort: YES];

}


// ===========================================================
// - syncWithNodeGraphModel
// ===========================================================
- (void) syncWithNodeGraphModel
{
	// when you load a script the model can get out of sync with the views
}

- (void) enable
{
	_enabled = YES;
}
- (void) disable
{
	_enabled = NO;
}

#pragma mark accessor methods

// ===========================================================
// - swapableView
// ===========================================================
- (id<SHCustomViewProtocol>)swapableView{return _swapableView;}


// ===========================================================
// - theAppControl
// ===========================================================
- (SHAppControl*)theAppControl{return _theAppControl;}


//=========================================================== 
//  isInViewPort 
//=========================================================== 
- (BOOL) isInViewPort { return _isInViewPort; }
- (void) setIsInViewPort: (BOOL) flag {
    //NSLog(@"in -setIsInViewPort, old value of isInViewPort: %@, changed to: %@", (isInViewPort ? @"YES": @"NO"), (flag ? @"YES": @"NO") );
    _isInViewPort = flag;
}

//=========================================================== 
//  isInWindow 
//=========================================================== 
- (BOOL) isInWindow { return _isInWindow; }
- (void) setIsInWindow: (BOOL) flag {
    //NSLog(@"in -setIsInWindow, old value of isInWindow: %@, changed to: %@", (isInWindow ? @"YES": @"NO"), (flag ? @"YES": @"NO") );
   _isInWindow = flag;
}

+ (NSString*) windowTitle
{
	return _windowTitle;
}

@end
