//
//  DrawingView.m
//  CurveSmoother
//
//  Created by Steven Hooley on 26/02/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "DrawingView.h"


@implementation DrawingView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buffer = malloc( 480*360 );
        _colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
        _provider = CGDataProviderCreateWithData(NULL, _buffer, 480*360 , NULL);
        
        _pointList = calloc(sizeof(int),3000);
        _pointListCount = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)push:(int)pixelLoc {
    _pointList[_pointListCount] = pixelLoc;
    _pointListCount++;
    // NSLog(@"pointCount %i", _pointListCount);
}


- (void)calcLength {
    
    for (int i=0; i<_pointListCount; i++) {
        int px = _pointList[i] /480;
        int py = _pointList[i] % 480;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    
//    BOOL                dragActive = YES;
//    NSPoint             location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//    NSAutoreleasePool   *myPool = nil;
//    NSEvent*            event = NULL;
//    NSWindow            *targetWindow = [self window];
//    myPool = [[NSAutoreleasePool alloc] init];
//    while (dragActive) {
//        event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
//                                          untilDate:[NSDate distantFuture]
//                                             inMode:NSEventTrackingRunLoopMode
//                                            dequeue:YES];
//        if(!event)
//            continue;
//        location = [self convertPoint:[event locationInWindow] fromView:nil];
//        switch ([event type]) {
//            case NSLeftMouseDragged:
//                --set the point in the offscreen buffer
//                break;
//            case NSLeftMouseUp:
//                dragActive = NO;
//                break;                
//            default:
//                break;
//        }
//    }
//    [myPool release];
}


- (void)mouseDragged:(NSEvent *)theEvent {
    
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int x = location.x;
    int y = 360-location.y;
    
    assert(x>-1 && x<481);
    assert(y>-1 && y<361);
    
    int pixelLoc = y * 480 + x;
    
    _buffer[pixelLoc] = 255; // color the pixel in the image
    [self push:pixelLoc];
    
    // could optimize this
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    //[[NSColor colorWithDeviceRed:1.0f green: 0 blue: 0 alpha:1.0] set];
    //NSRectFill( dirtyRect );
         
    // _image = CGImageCreate( 480, 360, 8, 8, 480*1, _colorSpace, kCGBitmapByteOrderDefault, _provider, NULL, FALSE, kCGRenderingIntentDefault);
    
   // CGContextDrawImage( context, CGRectMake(0.0, 0.0, 480.0, 360.0), _image );
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);    
    CGContextSetLineWidth(context, 1.0);    
    CGContextSetStrokeColorWithColor(context, color);

    
    int px = 360-(_pointList[0] /480);
    int py = _pointList[0] % 480;
    CGContextMoveToPoint(context, px, py);
    
    // for debuf purposes, redraw red over top
    for (int i=0; i<_pointListCount; i++) {
        py = 360-(_pointList[i] /480);
        px = _pointList[i] % 480;
        CGContextAddLineToPoint(context, px, py);
    }
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
  //  CGImageRelease(_image);
}

@end
