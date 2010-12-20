//
//  RenderView.m
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RenderView.h"
#import "RenderManager.h"
#import "Grid.h"
#import "HooPolygon.h"
#import "PolygonRasterizer.h"
#import "HandleLayer.h"

@implementation RenderView

@synthesize action= _action;
@synthesize target= _target;

- (id)initWithFrame:(NSRect)frame {

	self = [super initWithFrame:frame];
    if( self ) {
        
		_rMan = [[RenderManager alloc] init];
		
		_poly = [[HooPolygon alloc] init];
        _grid = [[Grid alloc] init];
        
        _handles = [[HandleLayer alloc] init];
        _handles.poly = _poly;
        
 //TODO:       -- ok so this is fucked if we need to redraw!
            
		_rasterizer = [[PolygonRasterizer alloc] init];
		[_rasterizer setResolution:1 in:20];
		[_rasterizer setPolygon:_poly];
		[_rasterizer render];
		
		[_rMan addDrawable:_rasterizer];		
        [_rMan addDrawable:_poly];
        [_rMan addDrawable:_grid];
        [_rMan addDrawable:_handles];
    }
    
    return self;
}

- (void)dealloc {

    [_rMan release];
	[_grid release];
	[_poly release];

    [super dealloc];
}

- (void)viewDidEndLiveResize {

	[super viewDidEndLiveResize];
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
	
    if( YES ) // [theEvent modifierFlags] & NSAlternateKeyMask
	{
        NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSEvent *event = NULL;
        NSWindow *targetWindow = [self window];
		
        // -- requires drag = handles mousedown
        BOOL dragActive = [_handles needsMouseDrag:&location];
         
		NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
        while( dragActive )
		{
            event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSKeyDownMask) untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];
            if(!event)
                continue;
            location = [self convertPoint:[event locationInWindow] fromView:nil];
            switch ([event type])
			{
                case NSLeftMouseDragged:
                        
                    // -- handles forward drag
                    [_handles mouseDrag:&location];
                    [self setNeedsDisplay:YES];
                    break;
					
                case NSLeftMouseUp:
                    dragActive = NO;
					NSLog(@"UP");
                    break;
					
                case NSKeyDown:
					NSBeep();
					continue;
					
                default:
					NSLog(@"ARGGG");
                    break;
            }
        }
        [_handles mouseUp];
        
        [myPool release];
    } else {
        // other tasks handled here......
    }
}

- (void)mouseUp:(NSEvent *)theEvent {

    // [self setFrameColor:[NSColor greenColor]];
    [self setNeedsDisplay:YES];
	[NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)drawRect:(NSRect)dirtyRect {

    [[NSColor blackColor] set];

    NSRectFill(dirtyRect);
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]  graphicsPort];

    [_rMan drawSceneInContext:context];
}

@end
