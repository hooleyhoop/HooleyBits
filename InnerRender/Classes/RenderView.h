//
//  RenderView.h
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class RenderManager, Grid, HooPolygon, PolygonRasterizer, HandleLayer;

@interface RenderView : NSView {
@private
    RenderManager			*_rMan;
    Grid					*_grid;
    HandleLayer				*_handles;
	HooPolygon				*_poly;
	PolygonRasterizer		*_rasterizer;
	SEL						_action;
	id						_target;
}

@property (assign) SEL		action;
@property (assign) id		target;

@end
