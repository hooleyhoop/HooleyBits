//
//  SHInvisibleWindow.m
//  SHExtras
//
//  Created by Steven Hooley on 11/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SHInvisibleWindow.h"


@implementation SHInvisibleWindow

-(id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])
    {
        [self setBackgroundColor: [NSColor clearColor]];
		[self setLevel: NSStatusWindowLevel];
        [self setAlphaValue:0.33];
        [self setOpaque:NO];
        [self setHasShadow: NO];
    }
   return self;
}


@end
