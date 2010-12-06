//
//  RenderManager.m
//  InnerRender
//
//  Created by Steven Hooley on 06/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "RenderManager.h"


@implementation RenderManager

- (id)init {
    if ((self = [super init])) {
        _drawables = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_drawables release];
    [super dealloc];
}

- (void)addDrawable:(id)ob {
    [_drawables addObject:ob];
}

- (void)drawSceneInContext:(CGContextRef)windowContext {
    
    for( id each in _drawables )
        [each drawInContext:windowContext];
}

@end
