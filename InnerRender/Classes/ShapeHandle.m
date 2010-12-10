//
//  Handle.m
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "ShapeHandle.h"


@implementation ShapeHandle

+ (ShapeHandle *)handleWithPt:(CGPoint *)pt {
    ShapeHandle *handle = [[ShapeHandle alloc] initWithPt:pt];
    return [handle autorelease];
}

- (id)initWithPt:(CGPoint *)pt {
	self = [super init];
    if(self) {
        _x = pt->x;
        _y = pt->y;
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

- (void)moveTo:(NSPoint *)location {
    
}

- (BOOL)hitTest:(NSPoint *)pt {
    return YES;
}

@end
