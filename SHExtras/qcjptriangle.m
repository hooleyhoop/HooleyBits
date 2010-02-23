// (CC) quartzcomposer.jp 
// 2005/08/01 version 0.11
// Licensed under Attribution-NonCommercial-ShareAlike : http://creativecommons.org/licenses/by-nc-sa/2.5/

#import "qcjptriangle.h"

// TODO:
// - clean up
// - remove qcjp leftovers
// - use display list or vbo

///////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QCJPTriangle : QCPatch
+ (int)executionMode
{
	return 1; // maybe renderer
}

+ (BOOL)allowsSubpatches
{
	return NO;
}

- (id)setup:(id)p
{
	// intiialize variables
	[inputAlpha setDoubleValue:1.0];
	return p; // ?
}

- (BOOL)execute:(QCOpenGLContext*)qcglctx time:(double)exec_time arguments:(id)arg
{
	// get current, QC contexts
	CGLContextObj old_ctx = CGLGetCurrentContext();
	CGLContextObj qc_ctx = [qcglctx CGLContextObj];
	
	// set QC Context
	CGLSetCurrentContext( qc_ctx );

	// set blending/zbuffer/culling
	[inputBlending set:qc_ctx];
	[inputZBuffer set:qc_ctx];
	[inputCulling set:qc_ctx];

	[self _drawGL:qc_ctx];

	// unset blending/zbuffer/culling
	[inputCulling unset:qc_ctx];
	[inputZBuffer unset:qc_ctx];
	[inputBlending unset:qc_ctx];	

	// unset context
	CGLSetCurrentContext( old_ctx ); 
	return YES;
}

- (void)cleanup:(id)p
{
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_drawGL:(CGLContextObj)qc_ctx
{
	
	double start = [inputStartAngle doubleValue];
	double end = [inputEndAngle doubleValue];
	
	double distance = end - start;
	int numQuads = fmax(1, (fabs(distance)/2*M_PI)*ACCURACY);
	
		
	// save previous state
	glPushMatrix();
		
	// draw pie
	
	// translate to x/y
	glTranslatef([inputX doubleValue],[inputY doubleValue],0.0f);
	
	// set color
	// Yeah, this ignores the color port's alpha value.  But frankly, dealing with fading objects in QC patches is a pain in the ass.
	// [inputColorPie set:qc_ctx];	
	glColor4f([inputColorPie redComponent], [inputColorPie greenComponent], [inputColorPie blueComponent], [inputAlpha doubleValue]);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	// coordinates
	double innerRadius = [inputInnerRadius doubleValue];
	double outerRadius = [inputOuterRadius doubleValue];
	
	float innerX,innerY,outerX,outerY;
	innerX = sin(start)*innerRadius;
	innerY = cos(start)*innerRadius;
	outerX = sin(start)*outerRadius;
	outerY = cos(start)*outerRadius;
	
	
	// draw it
	glBegin( GL_QUAD_STRIP );
	{
		for (int idx = 0; idx <= numQuads; idx++) {
			double currentAngle = start + distance*idx/numQuads;
			innerX = sin(currentAngle)*innerRadius;
			innerY = cos(currentAngle)*innerRadius;
			outerX = sin(currentAngle)*outerRadius;
			outerY = cos(currentAngle)*outerRadius;

			glVertex3f(outerX, outerY, 0.0f);
			glVertex3f(innerX, innerY, 0.0f);
		}
	}	
	glEnd();
	
	
	// restore previous state
	glPopMatrix();
}

@end