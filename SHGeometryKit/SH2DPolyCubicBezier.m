//
//  SH2DPolyCubicBezier.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 10/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2DPolyCubicBezier.h"


@implementation SH2DPolyCubicBezier

/* apparently the derivative of a bezier at a point is the tangent */

/*
 * Evaluate the cubic Bezier spline
 */
static double eval_cubic_bezier_spline(u,xa,xb,xc,xd)
double u,xa,xb,xc,xd;
{
	double c;
	
	/* Check the value of u */
	if (u <0.0  || u > 1.0 ) {
		(void) fprintf(stderr,"Error - attempt to evaluate u=%f outside [0,1] range\n",u);
		return(0.0);
	}
	c = u*u*u*(  -xa + 3*xb - 3*xc + xd )
		+ u*u*( 3*xa - 6*xb + 3*xc      )
		+   u*(-3*xa + 3*xb             )
		+     (   xa                    );
	return(c);
}



void recursive_bezier(double x1, double y1, 
                      double x2, double y2, 
                      double x3, double y3, 
                      double x4, double y4)
{
    // Calculate all the mid-points of the line segments
    //----------------------
 //   double x12   = (x1 + x2) / 2;
//    double y12   = (y1 + y2) / 2;
//    double x23   = (x2 + x3) / 2;
//    double y23   = (y2 + y3) / 2;
//    double x34   = (x3 + x4) / 2;
//    double y34   = (y3 + y4) / 2;
//    double x123  = (x12 + x23) / 2;
//    double y123  = (y12 + y23) / 2;
//    double x234  = (x23 + x34) / 2;
//    double y234  = (y23 + y34) / 2;
//    double x1234 = (x123 + x234) / 2;
//    double y1234 = (y123 + y234) / 2;

//    if(curve_is_flat)
//    {
//        // Draw and stop
//        //----------------------
//        draw_line(x1, y1, x4, y4);
//    }
//    else
//    {
//        // Continue subdivision
//        //----------------------
//        recursive_bezier(x1, y1, x12, y12, x123, y123, x1234, y1234); 
//        recursive_bezier(x1234, y1234, x234, y234, x34, y34, x4, y4); 
//    }
}


@end
