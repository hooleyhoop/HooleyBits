//
//  Swapable3DView.h
//  InterfaceTest
//
//  Created by Steve Hooley on Fri Jan 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>


#import "SHViewControllerProtocol.h"
//RR #import "C3DTTYPES.h"
#import "SHCustomViewProtocol.h"
    #import <OpenGL/OpenGL.h>
    #import <GLUT/glut.h>
	#import <OpenGL/glext.h>
	#import <OpenGL/glu.h>
	#import <OpenGL/gl.h>
	
	
@class OutputControl, C3DTCamera, C3DTScene, C3DTEntity, MenubarView, NSView, SHCustomViewController ;


@interface SHSwapableView : NSView <SHCustomViewProtocol>
{
    NSString						*_swapableViewName;
    NSMenu							*_contextualMenu;
	
    SHCustomViewController<SHViewControllerProtocol>	*_controller;

	// View must not retain its parent view to avoid retain cycle

    // NSButton						*fitAll, *resetScale;
    // NSBezierPath					*path;
	// SwapViewMenuBar				*menuStuff;
	
    // mouse event properties
    NSPoint							_downPointInWindow, _currentPointInWindow, _oldPointInWindow;
    NSPoint							_downPointInView, _currentPointInView, _oldPointInView;
	
    NSColor*						_backgroundColor;
	bool							_hasBeenResizedFlag;
	NSTrackingRectTag				_trackRect;
	
	int SHIFT_DOWN;
	int ALT_DOWN;
	int lastALT_DOWN;
	int CMD_DOWN;
	
	NSCursor						*_myCursor;
}

#pragma mark -
#pragma mark init methods
// - (id)initWithFrame:(NSRect)frameRect Control: (id)controlArg; // type id but conforms to protocol

#pragma mark action methods
- (NSPoint)randomPoint;

- (NSPoint)viewPointInCentreOfFrame;

- (void)timedRedraw;

- (void) layOutAtNewSize;

- (void)refresh: (NSNotification *)aNotification;

// - (void)setCentrePoint: (NSPoint) oldCentre;
#pragma mark mouse methods
- (void) mouseDown: (NSEvent *)event;
- (void) mouseDragged: (NSEvent *)event;
- (void) mouseUp: (NSEvent *)event;

- (void)altMouseDragActionX:(GLfloat)xarg Y:(GLfloat)yarg;

// These only work for a specific tracking rectangle 
- (void) mouseMoved:(NSEvent *)event;
- (void) mouseEntered:(NSEvent *)theEvent;
- (void) mouseExited:(NSEvent *)theEvent;
//- (void)rightMouseDown:(NSEvent *)event;
//- (void)rightMouseDragged:(NSEvent *)event;
//- (void)rightMouseUp:(NSEvent *)event;
//- (void)otherMouseDown:(NSEvent *)event;
//- (void)otherMouseDragged:(NSEvent *)event;
//- (void)otherMouseUp:(NSEvent *)event;

- (void)resetCursorRects;

// key events
- (void) keyDown: (NSEvent *)event;
- (void) keyUp: (NSEvent *)event;

#pragma mark accessor methods
- (void) setBackgroundColor:(NSColor*)aNSColor;
- (NSColor*) backgroundColor;

- (NSString*) swapableViewName;
- (void) setSwapableViewName:(NSString*)aNameString; 

- (SHCustomViewController*)controller;
- (void)setController:(SHCustomViewController*)aController;

//- (NSColor*)backColor;
//- (void)setBackColor: (NSColor*)aColor;

- (int)SHIFT_DOWN;
- (int)ALT_DOWN;
- (int)CMD_DOWN;



#pragma mark private methods

- (void) setGlobalModifierKeys:(NSEvent *)anEvent;

//- (void) registerWith: (id)aSender forNotification: (NSString *)aNotification;

//- (void) unregisterWith: (id)aSender forNotification: (NSString *)aNotification;

// keyPressed Stuff
//- (void)backSpacePressed;

//- (void)spacePressed;

- (NSCursor *)myCursor;
- (void)setMyCursor:(NSCursor *)aMyCursor;


/* you need to overide this to stop it automatically
 * re instating the default arrow cursor. You need
 * never call it directly
*/
- (void)resetCursorRects;


@end
