//
//  HandleLayer.h
//  InnerRender
//
//  Created by Steven Hooley on 09/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HooPolygon, ShapeHandle;

@interface HandleLayer : NSObject {

    HooPolygon *_poly;
    ShapeHandle *_downHandle;

}

@property (retain) HooPolygon *poly;
@property (assign) ShapeHandle *downHandle;

- (BOOL)needsMouseDrag:(NSPoint *)location;
- (void)mouseDrag:(NSPoint *)location;
- (void)mouseUp;

@end
