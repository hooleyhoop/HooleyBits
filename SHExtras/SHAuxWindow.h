//
//  SHAuxWindow.h
//  Pharm
//
//  Created by Steve Hooley on 11/08/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SHViewport;

@interface SHAuxWindow : NSWindow {
	
	IBOutlet SHViewport*		_viewport;
}


#pragma mark -
#pragma mark init methods

#pragma mark action methods
- (void) layOutAtNewSize;

#pragma mark accessor methods
- (SHViewport *) viewport;
- (void) setViewport: (SHViewport *) aViewport;

@end
