//
//  Polygon.h
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface HooPolygon : NSObject {

    NSPointerArray      *_ptArray;  // a growable list of pts
    //                    _tags       // a list of ints
                        
    // open or closed ?
    
    //-- presumably we need multiple contours? - arse
    //                    _contours
}

+ (HooPolygon *)complexTestPoly;

- (CGRect)boundsRect;
- (NSPointerArray *)pts;
- (NSUInteger)numverts;

@end
