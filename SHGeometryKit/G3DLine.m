//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DLine
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
// $Id: G3DLine.m,v 1.3 2002/10/25 10:11:16 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DLine.h"

#import "G3DVector3f.h"
#import "G3DTuple3f.h"
#import "G3DBox.h"
#import "G3DPlane.h"
#import "G3DSphere.h"
#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DLineException = @"G3DLineException";

@implementation G3DLine

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
  id tuple;
  id vector;
  id line;
  
  static float tmp1[3] = {0.0,0.0,0.0};
  static float tmp2[3] = {1.0,1.0,1.0};

  tuple = [[G3DTuple3f alloc] initWithElements:tmp1];
  vector = [[G3DVector3f alloc] initWithElements:tmp2];
  
  line = [self initWithOrigin:tuple direction:vector factor:1.0f];
  
  [tuple release];
  [vector release];
  
  return line;
}

- (id)initWithOrigin:(G3DTuple3f *)s direction:(G3DVector3f *)vec factor:(const float)f
{
  if ((self = [super init])) 
  {
    origin    = [s copy];
    
    direction = [vec copy];
    [direction normalise];
    
    t = f;
  }
  return self;
}

- (id)initWithLine:(G3DLine *)aLine
{
  return [self initWithOrigin:[aLine origin] direction:[aLine direction] factor:[aLine factor]];
}

- (void)dealloc
{
  [direction release];
  [origin release];

  [super dealloc];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (BOOL)isParallel:(G3DLine *)aLine
{
  const float *d1 = [direction elements];
  const float *d2 = [[aLine direction] elements];
  float cr_pr[3];

  G3DMultiplyVector3fv(cr_pr,d1,d2);

  return (G3DScalarProduct3fv(cr_pr,cr_pr) == 0.0f) ? YES : NO;
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
    return [self intersectsPlane:anObject at:nil];
  }
  else {
    [NSException raise:G3DLineException format:@"Couldn't perform the intersection test!"];
  }
  
  return NO;
}

- (BOOL)intersectsLine:(G3DLine *)ln
{
  const float *o1 = [origin elements];
  const float *d1 = [direction elements];
  const float *o2 = [[ln origin] elements];
  const float *d2 = [[ln direction] elements];
  float denom;
  float _t_v1[3];
  float _t_v2[3];
  float t2 = [ln factor];
  float _r1, _r2;
  
  /*
   * o1 + t * d1 = o2 + t2 * d2 
   *
   * <=>
   *
   *      |o2 -o1 d2 d1xd2|
   * t == -----------------
   *          ||d1xd2||^2
   *
   * AND
   *
   *       |o2 -o1 d1 d1xd2|
   * t2 == -----------------
   *           ||d1xd2||^2
   *
   */

  if( [self isEqualToLine:ln] ) {
    return YES;
  }

  G3DMultiplyVector3fv(_t_v1,d1,d2);
  denom = G3DScalarProduct3fv(_t_v1,_t_v1);

  // Parallel if denominator equals 0
  if (denom == 0.0f) {
    return NO;
  }

  // Faster...
  denom = 1.0f/denom;

  G3DSubVectors3fv(_t_v1,o2,o1);
  G3DMultiplyVector3fv(_t_v2,d1,d2);

  _r1 = G3DDeterminante3fv(_t_v1,d2,_t_v2) * denom;
  _r2 = G3DDeterminante3fv(_t_v1,d1,_t_v2) * denom;

  return (_r1 == t && _r2 == t2) ? YES : NO;
}

- (BOOL)intersectsSphere:(G3DSphere *)sphere
{
  return [sphere intersectsLine:self];
}

- (BOOL)intersectsBox:(G3DBox *)box
{
    return [box intersectsLine:self];
}

- (BOOL)intersectsPlane:(G3DPlane *)plane at:(G3DTuple3f *)pt
{
    float isect[3];
    int ret = G3DIntersectLinePlanef( isect,
                                      [direction elements],
                                      [origin elements],
                                      [plane elements]);

    if ( ret && pt ) {
        [pt setElements:isect];
    }

    return ret;
}

- (void)transform:(G3DMatrix4f *)aMatrix
{
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setFactor:(const float)val
{
  NSAssert(val!=0.0f,@"The line factor must not be 0!");

  t = val;
}

- (float)factor
{
  return t;
}

- (G3DTuple3f *)origin
{
  return origin;
}

- (void)setOrigin:(G3DTuple3f *)o
{
  [origin autorelease];
  origin = [o copy];
}

- (G3DVector3f *)direction
{
  return direction;
}

- (void)setDirection:(G3DVector3f *)d
{
  [direction autorelease];
  direction = [d copy];

  [direction normalise];
}

- (BOOL)isEqualToLine:(G3DLine *)aLine
{
  //~ probert: This is not correct!
  if ([origin isEqualToTuple:[aLine origin]] &&
      [direction isEqualToTuple:[aLine direction]]) {
    return YES;
  }
    
  return NO;
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:origin];
  [aCoder encodeObject:direction];
  [aCoder encodeValueOfObjCType:@encode(float) at:&t];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  origin = [[aCoder decodeObject] retain];
  direction = [[aCoder decodeObject] retain];
  [aCoder decodeValueOfObjCType:@encode(float) at:&t];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  return [[G3DLine allocWithZone:zone] initWithLine:self];
}

@end






