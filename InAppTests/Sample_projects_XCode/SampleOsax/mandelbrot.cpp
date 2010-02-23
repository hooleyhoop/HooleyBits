/*
 *  mandelbrot.cpp
 *  SampleOsax
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */

#include "mandelbrot.h"
#include <complex>
using namespace std;

void DoFractal(float* x, float*y, long width, long height, long depth, float* result) {
//float* result must be allocated (size : width*height)
  float* px=0;
  float* py=y;
  float* pr=result;
  for (int ny=0; ny<height; ny++, py++) {
    px=x;
    for (int nx=0; nx<width; nx++, px++,pr++) {
      int iter=0;
      complex<float> z(0,0);
      complex<float> c(*px,*py);
      while (iter<depth) {
        z=z*z+c;
        if (abs(z) > 2) break;
        iter++;
      }
      *pr=(float)iter;
    }
  }
  return;
}


