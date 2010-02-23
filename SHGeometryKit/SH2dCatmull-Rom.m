//
//  SH2dCatmull-Rom.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 14/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2dCatmull-Rom.h"


@implementation SH2dCatmull_Rom


the curve doesnt go thru the tangents..

t2 can well be 'after' p2

P1: the startpoint of the curve
T1: the tangent (e.g. direction and speed) to how the curve leaves the startpoint
P2: he endpoint of the curve
T2: the tangent (e.g. direction and speed) to how the curves meets the endpoint


moveto (P1);                            // move pen to startpoint
for (int t=0; t < steps; t++)
{
  float s = (float)t / (float)steps;    // scale s to go from 0 to 1
  float h1 =  2s^3 - 3s^2 + 1;          // calculate basis function 1
  float h2 = -2s^3 + 3s^2;              // calculate basis function 2
  float h3 =   s^3 - 2*s^2 + s;         // calculate basis function 3
  float h4 =   s^3 -  s^2;              // calculate basis function 4
  vector p = h1*P1 +                    // multiply and sum all funtions
             h2*P2 +                    // together to build the interpolated
             h3*T1 +                    // point along the curve.
             h4*T2;
  lineto (p)                            // draw to calculated point on the curve
}


if you auto calculate the tangents you have a 'cardinal Spline'

Ti = a * ( Pi+1 - Pi-1 )

ie. T1 = a * ( P1+1 - P1-1 )
T2 = a * ( P2+1 - P2-1 )

between 0 and 1, but this is not a must

when a = 0.5 you have a catmull-rom spline


/* it 
Given the control points P0, P1, P2, and P3, and the value t, the location of the point can be calculated as (assuming uniform spacing of control points):

 q(t) = 0.5 * (1.0f,t,t2,t3)  *	
[  0

2

0

0 ]

 	
[P0]

[ -1

0

1

0 ]

*

[P1]

[  2

-5

4

-1 ]

[P2]

[ -1

3

-3

1 ]

[P3]

Equation 1

To put that another way:

q(t) = 0.5 *(  	(2 * P1) +
 	(-P0 + P2) * t +
(2*P0 - 5*P1 + 4*P2 - P3) * t2 +
(-P0 + 3*P1- 3*P2 + P3) * t3)
Equation 2

@end
