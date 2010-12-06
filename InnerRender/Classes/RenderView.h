//
//  RenderView.h
//  InnerRender
//
//  Created by Steven Hooley on 05/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RenderManager, Grid;

@interface RenderView : NSView {
@private
    RenderManager *_rMan;
    Grid *_grid;
}

@end
