//
//  SHFakeView.h
//  SHExtras
//
//  Created by Steven Hooley on 07/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SHFakeView : NSView {

}

- (NSRect) _selectionRect;

- (void) _setHorizontalScrollerHidden:(BOOL)flag;

- (void) _setVerticalScrollerHidden:(BOOL)flag;

/* just to keep the compiler happy */
- (NSView*) _contentView;

@end
