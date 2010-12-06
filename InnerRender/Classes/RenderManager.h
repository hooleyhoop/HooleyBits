//
//  RenderManager.h
//  InnerRender
//
//  Created by Steven Hooley on 06/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RenderManager : NSObject {
@private
    NSMutableArray *_drawables;
}

- (void)addDrawable:(id)ob;

- (void)drawSceneInContext:(CGContextRef)windowContext;

@end
