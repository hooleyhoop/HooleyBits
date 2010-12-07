//
//  PolygonRasterizer.h
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class HooPolygon;

@interface PolygonRasterizer : NSObject {

	HooPolygon *_poly;
}

#ifndef MAXVERTS
#define MAXVERTS 100
#endif

#ifndef X
#define X 0
#endif

#ifndef Y
#define Y 1
#endif

#ifndef fmin
#define fmin(a,b) (((a)>(b))?(b):(a))
#endif

#ifndef fmax
#define fmax(a,b) (((a)>(b))?(a):(b))
#endif

static int pointinpoly( const double point[2], double pgon[MAXVERTS][2]);

- (void)setResolution:(NSUInteger)numerator in:(NSUInteger)denominator;

- (void)setPolygon:(HooPolygon *)poly;

- (void)render;

@end
