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
        _pt = pt;
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)moveTo:(NSPoint *)location {
    
    _pt->x = location->x;
    _pt->y = location->y;
}

- (BOOL)hitTest:(NSPoint *)pt {
    
    NSUInteger ptSize = 10;
    if( (pt->x < _pt->x+ptSize) && (pt->x > _pt->x-ptSize) )
        if( (pt->y < _pt->y+ptSize) && (pt->y > _pt->y-ptSize) ) {
            return YES;
        }
    return NO;
}

@end
