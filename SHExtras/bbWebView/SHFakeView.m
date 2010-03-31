//
//  SHFakeView.m
//  SHExtras
//
//  Created by Steven Hooley on 07/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHFakeView.h"


@implementation SHFakeView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}


- (NSRect) _selectionRect
{
	return NSMakeRect(0,0,0,0);
}

- (void) _setHorizontalScrollerHidden:(BOOL)flag
{

}

- (void) _setVerticalScrollerHidden:(BOOL)flag
{

}

- (NSView*) _contentView
{
	return nil;
}

@end
