//
//  RenderView.h
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class RenderManager, Grid, HooPolygon, PolygonRasterizer;

@interface RenderView : NSView {
@private
    RenderManager *_rMan;
    Grid *_grid;
	HooPolygon *_poly;
	PolygonRasterizer *_rasterizer;
}

@end
