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

@implementation RenderView

- (id)initWithFrame:(NSRect)frame {

	self = [super initWithFrame:frame];
    if( self ) {
        
		_rMan = [[RenderManager alloc] init];
		
		_poly = [[HooPolygon alloc] init];
        _grid = [[Grid alloc] init];
        
		_rasterizer = [[PolygonRasterizer alloc] init];
		[_rasterizer setResolution:1 in:20];
		[_rasterizer setPolygon:_poly];
		[_rasterizer render];
		
		[_rMan addDrawable:_rasterizer];		
        [_rMan addDrawable:_poly];
        [_rMan addDrawable:_grid];
    }
    
    return self;
}

- (void)dealloc {

    [_rMan release];
	[_grid release];
	[_poly release];

    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {

    [[NSColor blackColor] set];

    NSRectFill(dirtyRect);
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]  graphicsPort];

    [_rMan drawSceneInContext:context];
}

@end
