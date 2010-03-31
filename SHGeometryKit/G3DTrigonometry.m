//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DTrigonometry
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
// $Id: G3DTrigonometry.m,v 1.2 2002/10/21 19:27:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DTrigonometry.h"
#import "G3DDefs.h"

NSString *G3DTrigonometryTableAllocationException = @"G3DTrigonometryTableAllocationException";

#ifdef ENABLE_COSF_SINF
# define COSF(x) cosf(x)
# define SINF(x) sinf(x)
#else
# define COSF(x) (float)cos(x)
# define SINF(x) (float)sin(x)
#endif

@implementation G3DTrigonometry

static float *cosf_tbl;
static float *sinf_tbl;

static double *cosd_tbl;
static double *sind_tbl;

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

+ (void)initialize
{
  static BOOL tooLate = NO;

  if (!tooLate) {
    int	i;
    double rd = 0;
    double rf = 0;

    cosf_tbl = (float *)malloc( sizeof(float) * 3600);
    if(cosf_tbl == NULL) {
      [NSException raise:G3DTrigonometryTableAllocationException 
                  format:@"Could not allocate the cosine table!"];
      return;
    }

    cosd_tbl = (double *)malloc( sizeof(double) * 3600);
    if(cosd_tbl == NULL) {
      [NSException raise:G3DTrigonometryTableAllocationException 
                  format:@"Could not allocate the cosine table!"];
      return;
    }
    
    sinf_tbl = (float *)malloc( sizeof(float) * 3600);
    if(sinf_tbl == NULL) {
      [NSException raise:G3DTrigonometryTableAllocationException 
                  format:@"Could not allocate the sine table!"];
      return;
    }

    sind_tbl = (double *)malloc( sizeof(double) * 3600);
    if(sind_tbl == NULL) {
      [NSException raise:G3DTrigonometryTableAllocationException 
                  format:@"Could not allocate the sine table!"];
      return;
    }
	
    for( i = 0; i < 3600; i++) {
      cosf_tbl[i] = COSF(DEG2RAD * rf);
      rf += .01;
    }

    for( i = 0; i < 3600; i++) {
      cosd_tbl[i] = cos(DEG2RAD * rd);
      rd += .01;
    }
    
    rf = 0;
    for( i = 0; i < 3600; i++) {
      sinf_tbl[i] = SINF(DEG2RAD * rf);
      rf += .01;
    }

    rd = 0;
    for( i = 0; i < 3600; i++) {
      sind_tbl[i] = sin(DEG2RAD * rd);
      rd += .01;
    }
    
    tooLate = YES;
  }
}

+ (float)fastSinf:(const int)angle
{
  return(sinf_tbl[abs(angle % 3600)]);
}

+ (double)fastSin:(const int)angle
{
  return(sind_tbl[abs(angle % 3600)]);
}

+ (float)fastCosf:(const int)angle
{
  return(cosf_tbl[abs(angle % 3600)]);
}

+ (double)fastCos:(const int)angle
{
  return(cosd_tbl[abs(angle % 3600)]);
}

@end






