//
//  2DVectorOps.h
//  CurveSmoother
//
//  Created by Steven Hooley on 21/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//
#import <Foundation/Foundation.h>

//setZero()
float approximateDistance( CGPoint this, CGPoint v );
CGPoint setDiff( CGPoint a, CGPoint b );
float approximateLength( CGPoint this );
CGPoint setApproximateTruncate( CGPoint this, float threshold );

CGPoint setUnitRandom();
CGPoint setScale( float a, CGPoint b );
CGPoint setSum( CGPoint a, CGPoint b );
