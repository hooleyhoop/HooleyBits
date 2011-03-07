//
//  DrawingView.m
//  CurveSmoother
//
//  Created by Steven Hooley on 26/02/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "DrawingView.h"

/* -------- use simple Bresenham's_line_algorithm to fill in the points between ----------------- */
void line(int x0, int y0, int x1, int y1) {
    
    int dx = abs(x1-x0), sx = x0<x1 ? 1 : -1;
    int dy = abs(y1-y0), sy = y0<y1 ? 1 : -1; 
    int err = (dx>dy ? dx : -dy)/2, e2;
    
    for(;;){
        NSLog(@"%i, %i",x0,y0);
        if (x0==x1 && y0==y1) break;
        e2 = err;
        if (e2 >-dx) { err -= dy; x0 += sx; }
        if (e2 < dy) { err += dx; y0 += sy; }
    }
}
/* ----------------------------------------------------------------------------------------------------------------- */


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
        
        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(3, 1);
        
        //line(0,0,3,1);
        
        //int xlen = p2.x-p1.x;
        //int ylen = p2.y-p1.y;
        // float dist = sqrtf(xlen*xlen+ylen*ylen);
        //float slope = (p2.y-p1.y)/(p2.x-p1.x);
        //NSLog(@"step");
        //cumulativeDist = cumulativeDist+dist;
        
//        [self pushPt:10,10]; 
//        [self pushPt:20,20]; 
//        [self calcLength];
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)pushPt:(int)x :(int)y {
    
    int pixelLoc = y * 480 + x;    
    _pointList[_pointListCount] = pixelLoc;
    _pointListCount++;
}


- (float)calcLength {
    
    int px1 = _pointList[0] /480;
    int py1 = _pointList[0] % 480;
    int px2, py2;
    float cumulativeDist = 0;
    for (int i=1; i<_pointListCount; i++) {
        px2 = _pointList[i] /480;
        py2 = _pointList[i] % 480;
        
        // -- length --
        int xlen = px2-px1;
        int ylen = py2-py1;
        float dist = sqrtf(xlen*xlen+ylen*ylen);
        cumulativeDist = cumulativeDist+dist;
        px1 = px2;
        py1 = py2;
    }
    // NSLog(@"Dist is %f", cumulativeDist);
    return cumulativeDist;
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
    
    // store it in our list
    [self pushPt:location.x :location.y];

    // draw the image upside down
    int x = location.x;
    int y = 360-location.y;
    int pixelLoc = y * 480 + x;
    assert(x>-1 && x<481);
    assert(y>-1 && y<361);
    _buffer[pixelLoc] = 255; // color the pixel in the image
    
    // could optimize this
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
        
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    [[NSColor colorWithDeviceRed:1.0f green: 0 blue: 0 alpha:1.0] set];
    NSRectFill( dirtyRect );
         
    _image = CGImageCreate( 480, 360, 8, 8, 480*1, _colorSpace, kCGBitmapByteOrderDefault, _provider, NULL, FALSE, kCGRenderingIntentDefault);
    
    CGContextDrawImage( context, CGRectMake(0.0, 0.0, 480.0, 360.0), _image );
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);    
    CGContextSetLineWidth(context, 1.0);    
    CGContextSetStrokeColorWithColor(context, color);

    int py1 = _pointList[0] / 480;
    int px1 = _pointList[0] % 480;
    CGContextMoveToPoint(context, px1, py1);
    
    // for debuf purposes, redraw red over top
    for (int i=0; i<_pointListCount; i++) {
        py1 = _pointList[i] /480;
        px1 = _pointList[i] % 480;
        CGContextAddLineToPoint(context, px1, py1);
    }
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
    CGImageRelease(_image);
    
    /* step along each pixel */
    // starting at the first pixel
    // [self calcLength];
    [[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0] set];
    
    px1 = _pointList[0] /480;
    py1 = _pointList[0] % 480;
    int px2, py2;
    BOOL draw = YES;
    BOOL skipFirstPixel = NO;
    for( int i=1; i<_pointListCount; i++ )
    {
        px2 = _pointList[i] /480;
        py2 = _pointList[i] % 480;            
        int dx = abs(px2-px1), sx = px1<px2 ? 1 : -1;
        int dy = abs(py2-py1), sy = py1<py2 ? 1 : -1; 
        int err = (dx>dy ? dx : -dy)/2, e2;            
        BOOL nah = NO;
        if(skipFirstPixel)
            nah = YES;
        
        for(;;){
            if(nah){
                nah = NO;
            } else {
                draw = !draw;   // plot every other pixel
                if(draw){
                    //NSLog(@"%i, %i",px1,py1);
                    NSRectFill( NSMakeRect(px1,py1,1,1) );
                }
            }
            if (px1==px2 && py1==py2) break;
            e2 = err;
            if (e2 >-dx) { err -= dy; px1 += sx; }
            if (e2 < dy) { err += dx; py1 += sy; }
        }
        px1 = px2;
        py1 = py2;
        skipFirstPixel=YES;
    }
}

@end
