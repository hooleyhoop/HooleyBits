// (CC) quartzcomposer.jp 
// 2005/08/01 version 0.11
// Licensed under Attribution-NonCommercial-ShareAlike : http://creativecommons.org/licenses/by-nc-sa/2.5/

#import "QCClasses.h"
#import "OpenGL/OpenGL.h"
#import "OpenGL/GL.h"
#import "math.h"

// number of triangles to draw for a complete circle
#define ACCURACY 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface QCJPTriangle : QCPatch
{
    QCNumberPort *inputStartAngle;
    QCNumberPort *inputEndAngle;

	QCNumberPort *inputInnerRadius;
    QCNumberPort *inputOuterRadius;
	
    QCNumberPort *inputX;
    QCNumberPort *inputY;
	
    QCGLPort_Color *inputColorPie;
    QCNumberPort *inputAlpha;
	
	QCGLPort_Blending *inputBlending;
	QCGLPort_ZBuffer *inputZBuffer;
	QCGLPort_Culling *inputCulling;
	
	@private
}

// QCPatch
+ (int)executionMode;
+ (BOOL)allowsSubpatches;
- (id)setup:(id)p;
- (BOOL)execute:(QCOpenGLContext*)qcglctx time:(double)exec_time arguments:(id)arg;
- (void)cleanup:(id)p;

// private
- (void)_drawGL:(CGLContextObj)qc_ctx;

@end