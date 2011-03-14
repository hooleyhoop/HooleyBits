//
//  HoboMaths.c
//  InnerRender
//
//  Created by Steven Hooley on 14/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#include "HoboMaths.h"
#include <math.h>

void cartToPolarDegress( float x, float y, float *r, float *theta ) {
    *r = sqrt(x*x+y*y);
    *theta = atan2(y,x) * 180. / M_PI;
}

void polarDegreesToCart( float r, float theta, float *x, float *y ) {
    float rads = theta*M_PI/180.;
    *x = r * cos(rads);
    *y = r * sin(rads);
}

 