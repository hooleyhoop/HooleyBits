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

@implementation RenderView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _rMan = [[RenderManager alloc] init];
        _grid = [[Grid alloc] init];
        
        [_rMan addDrawable:_grid];
    }
    
    return self;
}

- (void)dealloc {
    [_rMan release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {

    [[NSColor blueColor] set];

    NSRectFill(dirtyRect);
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]  graphicsPort];

    [_rMan drawSceneInContext:context];
}

@end
