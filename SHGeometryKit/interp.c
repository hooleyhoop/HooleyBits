/*
======================================================================
interp.c

Interpolation (and extrapolation) of LightWave envelopes.

Ernie Wright  16 Nov 00

The LightWave plug-in SDK provides functions for evaluating envelopes
and channels at arbitrary times, which is what plug-ins should use.
This code shows how to evaluate envelopes in standalone programs.
====================================================================== */
#import <Cocoa/Cocoa.h>
#include <stdlib.h>
#include <math.h>
#import "LWenvelope.h"
#import "LWKey.h"


/*
======================================================================
range()

Given the value v of a periodic function, returns the equivalent value
v2 in the principal interval [lo, hi].  If i isn't NULL, it receives
the number of wavelengths between v and v2.

   v2 = v - i * (hi - lo)

For example, range( 3 pi, 0, 2 pi, i ) returns pi, with i = 1.
====================================================================== */

static float range( float v, float lo, float hi, int *i )
{
   float v2, r = hi - lo;

   if ( r == 0.0 ) {
      if ( i ) *i = 0;
      return lo;
   }

   v2 = v - r * ( float ) floor(( v - lo ) / r );
   if ( i ) *i = -( int )(( v2 - v ) / r + ( v2 > v ? 0.5 : -0.5 ));

   return v2;
}







