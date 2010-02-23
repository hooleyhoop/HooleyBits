//
//  SHCustomViewController.h
//  Pharm
//
//  Created by Steve Hooley on 11/08/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

//#import "SHViewControllerProtocol.h"
#import "SHCustomViewProtocol.h"

@class SHAppControl, SHAuxWindow;

@interface SHCustomViewController : NSObject {
	
    SHAppControl				*_theAppControl;

	BOOL						_isInViewPort;
	BOOL						_isInWindow;
	BOOL						_enabled;
    id<SHCustomViewProtocol>	_swapableView;

}

#pragma mark -
#pragma mark init methods

#pragma mark action methods
- (void) hasBeenLaunchedInWindow;

- (void) willBeRemovedFromViewPort;
- (void) willBeAddedToViewPort;

- (void) syncWithNodeGraphModel;

- (void) enable;
- (void) disable;

#pragma mark accessor methods
- (id<SHCustomViewProtocol>) swapableView;

- (SHAppControl*)theAppControl;

- (BOOL) isInViewPort;
- (void) setIsInViewPort: (BOOL) flag;
- (BOOL) isInWindow;
- (void) setIsInWindow: (BOOL) flag;

+ (NSString*) windowTitle;

@end