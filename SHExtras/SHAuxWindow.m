//
//  SHAuxWindow.m
//  Pharm
//
//  Created by Steve Hooley on 11/08/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SHAuxWindow.h"
#import "SHViewport.h"


@implementation SHAuxWindow


#pragma mark -
#pragma mark init methods



//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {
	[self setViewport:nil];
    [super dealloc];
}

//=========================================================== 
// - awakeFromNib:
//=========================================================== 
- (void) awakeFromNib
{
	[self layOutAtNewSize];
}


#pragma mark action methods
- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"SHAuxWindow.m: is keyDown theEvkeyDownent? ");
}

// the window has been resized
- (void) layOutAtNewSize
{
	// NSLog(@"SHMainWindow.m: window has been resized");
	[_viewport layOutAtNewSize];

	[self setOpaque:NO];
	[self setAlphaValue:.999f];
	[self makeMainWindow];
	[self makeKeyWindow];
	[self makeFirstResponder:self];
//	NSLog(@"SHMainWindow.m: is key window? %i", 	[self isKeyWindow]);
}


#pragma mark accessor methods

//=========================================================== 
//  viewPort 
//=========================================================== 
- (SHViewport *) viewport { return _viewport; }
- (void) setViewport: (SHViewport *) aViewport {
    NSLog(@"in -setViewPort:, old value of _viewPort: %@, changed to: %@", _viewport, aViewport);

    if (_viewport != aViewport) {
        [aViewport retain];
        [_viewport release];
        _viewport = aViewport;
    }
}


- (BOOL)canBecomeKeyWindow
{
//	NSLog(@"SHMainWindow.m: canBecomeKeyWindow? ");

	return YES;
}
- (BOOL)canBecomeMainWindow
{
//	NSLog(@"SHMainWindow.m: canBecomeMainWindow? ");

	return YES;
}



@end
