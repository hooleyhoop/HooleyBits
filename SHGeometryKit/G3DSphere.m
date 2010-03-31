//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class	        G3DSphere
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	Thu Sep  9 11:05:08 CEST 1999
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DSphere.m,v 1.3 2002/10/25 10:13:24 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DSphere.h"
#import "G3DMatrix3f.h"
#import "G3DMatrix4f.h"
#import "G3DTuple3f.h"
#import "G3DVector3f.h"
#import "G3DBox.h"
#import "G3DLine.h"
#import "G3DPlane.h"

#import "G3DDefs.h"
#import "G3DFunctions.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DSphereException = @"G3DSphereException";

@implementation G3DSphere

static Class G3DLineClass;
static Class G3DSphereClass;
static Class G3DBoxClass;
static Class G3DPlaneClass;

+ (void)initialize
{
  static BOOL tooLate = NO;
  
  if (tooLate == NO) 
  {
    G3DLineClass   = [G3DLine class];
    G3DSphereClass = [G3DSphere class];
    G3DBoxClass    = [G3DBox class];
    G3DPlaneClass  = [G3DPlane class];
    
    tooLate = YES;
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithX:0.0 y:0.0 z:0.0 radius:1.0];
}

- (id)initWithCenter:(G3DTuple3f *)aCenter radius:(float)aRadius
{
  return [self initWithX:[aCenter x] y:[aCenter y] z:[aCenter z] radius:aRadius];
}

- (id)initWithX:(float)x y:(float)y z:(float)z radius:(float)aRadius
{
  if ((self = [super init])) {
    _center[0] = x;
    _center[1] = y;
    _center[2] = z;
    _radius = aRadius;
  }
  return self;
}

- (id)initWithSphere:(G3DSphere *)aSphere
{
  const float *c = [[aSphere center] elements];

  return [self initWithX:c[0] y:c[1] z:c[2] radius:[aSphere radius]];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)wrapPoint:(G3DTuple3f *)aPoint
{
  const float *pt = [aPoint elements];
  float dist;
  float pc[3];

  if (_radius < G3DEPSILON) {
    _radius = 0.0f;
    _center[0] = pt[0];
    _center[1] = pt[1];
    _center[2] = pt[2];
    return;
  }

  // Distance between center and pt
  pc[0] = pt[0]-_center[0];
  pc[1] = pt[1]-_center[1];
  pc[2] = pt[2]-_center[2];
  dist = G3DLength3fv(pc);

  if (dist > _radius) {
    float nradius = (_radius + dist) / 2.0f;
    float ratio = (nradius - _radius) / dist;

    _center[0] += pc[0] * ratio;
    _center[1] += pc[1] * ratio;
    _center[2] += pc[2] * ratio;

    _radius = nradius;
  }
  else {
    NSLog(@"<%@ %x> distance %f > radius %f - ignoring",dist,_radius);
  }
}

- (void)wrapBox:(G3DBox *)aBox
{
  if ([aBox isEmpty]) {
    return;
  }

  // Bad algorithm if the box is not very symmetric (but fast...)
  if (_radius <= 0.0) {
    G3DAddVectors3fv(_center,[[aBox min] elements],[[aBox max] elements]);
    G3DScaleVector3fv(_center,_center,0.5);
    _radius = G3DDistance3fv(_center,[[aBox max] elements]) ;
  }
  else {
    float tmp[3]; // intermediate 'sphere'
    float radius2;
    float dist;

    G3DCopyVector3f(tmp,0.0,0.0,0.0);
    G3DAddVectors3fv(tmp,[[aBox min] elements],[[aBox max] elements]);
    G3DScaleVector3fv(tmp,tmp,0.5);
    radius2 = G3DDistance3fv(tmp,[[aBox max] elements]);

    // wrap this intermediate sphere!
    dist = G3DDistance3fv(_center, tmp);

    // Already wrapped by our sphere!
    if (dist + radius2 <= _radius) {
      return;
    }

    // We are wrapped by the other sphere...
    if (dist + _radius <= radius2) {
      G3DCopyVector3fv(_center,tmp);
      _radius = radius2;
      return;
    } 
    else {
      float nradius = (_radius + dist + radius2) / 2.0f;
      float ratio = (nradius - _radius) / dist;

      _center[0] += (tmp[0] - _center[0]) * ratio;
      _center[1] += (tmp[1] - _center[1]) * ratio;
      _center[2] += (tmp[2] - _center[2]) * ratio;
      _radius = nradius;
    }
  }
}

- (void)wrapSphere:(G3DSphere *)s
{
  const float *tmp = [[s center] elements];
  float srad = [s radius];

  if (srad <= 0.0) {
    return;
  }

  if (_radius <= 0.0) {
    G3DCopyVector3fv(_center,tmp);
    _radius = srad;
    return;
  }
  else {
    float dist = G3DDistance3fv(_center, tmp);

    // Already wrapped by our sphere!
    if (dist + srad <= _radius) {
      return;
    }

    // We are wrapped by the other sphere...
    if (dist + _radius <= srad) {
      G3DCopyVector3fv(_center,tmp);
      _radius = srad;
      return;
    } 
    else {
      float nradius = (_radius + dist + srad) / 2.0f;
      float ratio = (nradius - _radius) / dist;

      _center[0] += (tmp[0] - _center[0]) * ratio;
      _center[1] += (tmp[1] - _center[1]) * ratio;
      _center[2] += (tmp[2] - _center[2]) * ratio;
      _radius = nradius;
    }
  }

  _center[0] = tmp[0];
  _center[1] = tmp[1];
  _center[2] = tmp[2];

  _radius = [s radius] + 0.001;
}

- (void)transform:(G3DMatrix4f *)aMatrix
{
  const float *m = [aMatrix elements];
  float tmp[4];
  float _s_factor;

  G3DCopyVector3fv(tmp,_center);

  _center[0] = m[0] * tmp[0] + m[4] * tmp[1] + m[8]  * tmp[2] + m[12];
  _center[1] = m[1] * tmp[0] + m[5] * tmp[1] + m[9]  * tmp[2] + m[13];
  _center[2] = m[2] * tmp[0] + m[6] * tmp[1] + m[10] * tmp[2] + m[14];

  _s_factor = MAX(MAX(m[0],m[5]),m[10]);
  _radius *= _s_factor;
}

- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject
{
  Class objClass = [anObject class];

  if (objClass == G3DLineClass) {
    return [self intersectsLine:anObject];
  }
  else if (objClass == G3DSphereClass) {
    return [self intersectsSphere:anObject];
  }
  else if (objClass == G3DBoxClass) {
    return [self intersectsBox:anObject];
  }
  else if (objClass == G3DPlaneClass) {
    return [self intersectsPlane:anObject];
  }
  else {
    [NSException raise:G3DSphereException format:@"Unknown volume class!"];
  }
  return NO;
}

- (BOOL)intersectsLine:(G3DLine *)line
{
  float tmp[3];
  const float *origin = [[line origin] elements];
  const float *direction = [[line direction] elements];
  float dirDotCenterSubOrigin;
  float squaredDir;
  
  /*
   * Tests for any t...
   *
   */

  G3DSubVectors3fv(tmp, _center, origin);

  dirDotCenterSubOrigin = G3DScalarProduct3fv(direction, tmp);
  squaredDir = G3DScalarProduct3fv(direction, direction);
  
  if(squaredDir > G3DEPSILON) {
    float dist;
    float lambda = dirDotCenterSubOrigin / squaredDir;
    float expandedLine[3];

    G3DScaleVector3fv(expandedLine, direction, - lambda);
    G3DAddVectors3fv(tmp, tmp, expandedLine);

    dist = G3DLength3fv(tmp);

    return (dist <= _radius) ? YES : NO;
  }
  
  return NO;
}

- (BOOL)intersectsSphere:(G3DSphere *)s
{
  register int cmp = 0;
  float tmp[3];
  float squaredDistance;
  float squareRDistance = (_radius + [s radius])*(_radius + [s radius]);

  [[s center] getElements:tmp];
  tmp[0] = _center[0] - tmp[0];
  tmp[1] = _center[1] - tmp[1];
  tmp[2] = _center[2] - tmp[2];

  squaredDistance = tmp[0]*tmp[0] + tmp[1]*tmp[1] + tmp[2]*tmp[2];

  if (squareRDistance > squaredDistance) cmp = 1;
  if (squareRDistance < squaredDistance) cmp = -1;

  return (cmp <= 0) ? YES : NO;
}

- (BOOL)intersectsBox:(G3DBox *)aBox
{
  const float *minvals = [[aBox min] elements];
  const float *maxvals = [[aBox max] elements];
  float tmp[3];
  float tmp2[3];
  float squareDist;
  float squaredRadius;

  // Evaluating the box' closest point to the sphere - unrolling the loop...
  if (minvals[0] > _center[0]) tmp[0] = minvals[0];
  else if (maxvals[0] < _center[0]) tmp[0] = maxvals[0];
  else tmp[0] = _center[0];
  
  if (minvals[1] > _center[1]) tmp[1] = minvals[1]; 
  else if(maxvals[1] < _center[1]) tmp[1] = maxvals[1]; 
  else tmp[1] = _center[1];

  if (minvals[2] > _center[2]) tmp[2] = minvals[2]; 
  else if(maxvals[2] < _center[2]) tmp[2] = maxvals[2]; 
  else tmp[2] = _center[2];

  // Compare...
  G3DSubVectors3fv(tmp2,_center,tmp);
  squareDist = G3DScalarProduct3fv(tmp2,tmp2); 
  squaredRadius = SQR(_radius);

  return (squareDist > squaredRadius) ? NO : YES;
}

- (BOOL)intersectsPlane:(G3DPlane *)plane
{
  id tuple = [[G3DTuple3f alloc] initWithElements:_center];
  float dist = [plane distanceFromPoint:tuple];

  [tuple release];
  
  return (ABS(dist) <= _radius) ? YES : NO;
}

- (BOOL)isEqualToSphere:(G3DSphere *)aSphere
{
  BOOL ret = G3DIsEqualToVector3fv(_center,[[aSphere center] elements]);

  if (ret && _radius == [aSphere radius]) {
    return YES;
  }
  return NO;
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (float)volume
{
  static float pcv = (4/3)*PI;

  return (float)(pcv*_radius*_radius*_radius);
}

- (BOOL)isEmpty
{
  return [self volume] <= 0.0f ? YES : NO;
}

- (float)radius
{
  return _radius;
}

- (void)setRadius:(const float)newRadius
{
  _radius = newRadius;
}

- (G3DTuple3f *)center
{
  return [[[G3DTuple3f alloc] initWithElements:_center] autorelease];
}

- (void)setCenter:(G3DTuple3f *)newCenter
{
  G3DCopyVector3fv(_center,[newCenter elements]);
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeValueOfObjCType:@encode(float) at:&_radius];
  [aCoder encodeArrayOfObjCType:@encode(float) count:3 at:_center];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeValueOfObjCType:@encode(float) at:&_radius];
  [aCoder decodeArrayOfObjCType:@encode(float) count:3 at:_center];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  return [[G3DSphere allocWithZone:zone] initWithSphere:self];
}

@end






