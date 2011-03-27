//
//  2DVectorOps.c
//  CurveSmoother
//
//  Created by Steven Hooley on 21/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#include "2DVectorOps.h"



 CGPoint setUnitRandom() {
     // cant be fucked
     return CGPointMake(0, 0);
}

CGPoint setScale( float a, CGPoint b ) {
    return CGPointMake(a * b.x, a * b.y);    
}

CGPoint setSum( CGPoint a, CGPoint b ) {
    return CGPointMake( a.x+b.x, a.y+b.y );    
}

float approximateDistance( CGPoint this, CGPoint v ) {
    CGPoint distTemp = setDiff(this, v);
    return approximateLength( distTemp );
}

CGPoint setDiff( CGPoint a, CGPoint b ) {
    return CGPointMake( a.x-b.x, a.y-b.y );        
}

float approximateLength( CGPoint this ) {
    
    float a = this.x;
    if (a < 0.0F)
        a = -a;
    float b = this.y;
    if (b < 0.0F)
        b = -b;
    float c = 0;
    if (a < b) { 
        float t = a;
        a = b;
        b = t; }
    // unesasry stuff here from vec 3
    if (a < c) { 
        float t = a;
        a = c; 
        c = t;
    }
    return a * 0.9375F + (b + c) * 0.375F;
}

CGPoint setApproximateTruncate( CGPoint this, float threshold ) {
    
    float length = approximateLength(this);
    if (length > threshold)
        return setScale( threshold / length, this);
    return this;
}
