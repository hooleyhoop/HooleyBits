//
//  Polygon.h
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface HooPolygon : NSObject {

    NSPointerArray *_ptArray;
}

+ (HooPolygon *)complexTestPoly;

- (CGRect)boundsRect;
- (NSPointerArray *)pts;
- (NSUInteger)numverts;

@end
