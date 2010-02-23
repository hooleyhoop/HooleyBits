//
//  SHMainWindowDelegate.h
//  InterfaceTest
//
//  Created by Steve Hool on Mon Dec 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

@class SHAuxWindow;


@interface SHAuxWindowDelegate : NSObject {
    
    IBOutlet SHAuxWindow* _theWindow;
}

//
- (id)init:(SHAuxWindow*)SHMainWindowArg;

// Working with window status
// - windowDidBecomeKey:
// - windowDidBecomeMain:
// - windowDidResignKey:
// - windowDidResignMain:

// Moving and resizing windows
// - windowDidChangeScreen:
// - windowWillMove:
// - windowDidMove:
// - windowWillResize:toSize:
- (void) windowDidResize:(NSNotification *)aNotification;
// - windowShouldZoom:toFrame:
// - windowWillUseStandardFrame:defaultFrame:

// Miniaturizing and closing windows
// - windowWillMiniaturize:
// - windowDidMiniaturize:
// - windowDidDeminiaturize:
// - windowShouldClose:
- (void)windowWillClose:(NSNotification *)aNotification;

// Exposing and updating windows
// - windowDidExpose:
// - windowDidUpdate:

// Displaying sheets
// - windowWillBeginSheet:
// - windowDidEndSheet:
// - window:willPositionSheet:usingRect:

// Obtaining information about a window
// - windowWillReturnFieldEditor:toObject:
// - windowWillReturnUndoManager:



@end
