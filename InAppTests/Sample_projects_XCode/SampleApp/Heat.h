/*
 *  Heat.h
 *  HeatEquation
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

struct HeatEqn{
    long ncols;
    long nrows;
    float *p;
    float sigma;
    float dt;
    HeatEqn(){ncols=nrows=0;p=0;sigma=1.0;dt=0.01;}
    void free();
    OSErr Run(int steps);
};

extern HeatEqn gHeatEqn;