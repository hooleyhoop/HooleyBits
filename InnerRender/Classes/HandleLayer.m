//
//  HandleLayer.m
//  InnerRender
//
//  Created by Steven Hooley on 09/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HandleLayer.h"
#import "HooPolygon.h"
#import "ShapeHandle.h"

@implementation HandleLayer

@synthesize poly=_poly;
@synthesize downHandle=_downHandle;

- (BOOL)needsMouseDrag:(NSPoint *)location {
    
    // -- have we hit a handle?
    NSPointerArray *pts = [_poly pts];
    for( NSUInteger i=0; i<[pts count]; i++ ) {
        CGPoint *p = [pts pointerAtIndex:i];
        ShapeHandle *shapeHandle = [ShapeHandle handleWithPt:p];
        if( [shapeHandle hitTest:location] ) {
            self.downHandle = shapeHandle;
            return YES;
        }
    }
    return NO;
}

- (void)mouseDrag:(NSPoint *)location {
   
    [_downHandle moveTo:location];
}

- (void)mouseUp {
    self.downHandle = nil;
}

- (void)drawInContext:(CGContextRef)windowContext  {

    CGColorRef redCol = CGColorCreateGenericRGB( 1.0f, 0.0f, 0.0f, 1.0f );
    CGContextSetFillColorWithColor( windowContext, redCol );

    // draw each pt
    NSPointerArray *pts = [_poly pts];
	for( NSUInteger i=0; i<[_poly numverts]-1; i++ )
    {
        CGPoint *p = [pts pointerAtIndex:i];
		CGContextFillRect( windowContext, CGRectMake( p->x, p->y, 5., 5.));
	}
    
    CGColorRelease(redCol); 
}

@end
