//
//  SHViewport.h
//  InterfaceTest
//
//  Created by Steve Hooley on Wed May 19 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
//  The Window has a number of SHViewports. eg 2 up, 4 up etc.


#import "SHViewControllerProtocol.h"
#import "SHCustomViewProtocol.h"
#import "SHCustomViewController.h"


@class MenubarView, MenubarView;


@interface SHViewport : NSView  {

	bool							_hasBeenResizedFlag;
	//aaa   MenubarView				*theMenubarView;
	
	id<SHCustomViewProtocol>		_theSHSwapableView;
	id<SHViewControllerProtocol>	_theViewController;
}
#pragma mark -
#pragma mark init methods

#pragma mark action methods
- (void) layOutAtNewSize;
- (void) viewDidEndLiveResize;

- (void) reDrawContents;

- (void) willCloseWindow;

#pragma mark accessor methods
- (void) setTheViewController: (SHCustomViewController<SHViewControllerProtocol>*) aViewController;
- (id<SHViewControllerProtocol>) theViewController;

- (void) setTheSHSwapableView: (id<SHCustomViewProtocol>) aTheSHSwapableView;
- (id<SHCustomViewProtocol>) theSHSwapableView;

// - (void)swapViews:(SHSwapableView*)viewArg;

// - (void)makeViewMenu;

// - (void) setHasBeenResized: (NSRect) newSize;


@end
