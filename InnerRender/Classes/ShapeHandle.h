//
//  Handle.h
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface ShapeHandle : NSObject {
@private
    CGFloat _x, _y;
}

+ (ShapeHandle *)handleWithPt:(CGPoint *)pt;

- (id)initWithPt:(CGPoint *)pt;

- (void)moveTo:(NSPoint *)location;

- (BOOL)hitTest:(NSPoint *)pt;

@end
