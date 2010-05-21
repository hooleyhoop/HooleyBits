//
//  PBCamera.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 11/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PBCamera.h"
#import <OpenGL/CGLMacro.h>
#import <SHGeometryKit/SHGeometryKit.h>
extern CGLContextObj cgl_ctx; // defined in millicent view

static PBCamera* camera;
/*
 *
*/
@implementation PBCamera


#pragma mark -
#pragma mark class methods
+ (PBCamera *)camera
{
	return camera;
}

#pragma mark init methods
// ===========================================================
// - initWithBounds:
// ===========================================================
- (id)initWithBounds:(NSRect)boundsRect
{
    if ((self = [super init]) != nil) 
	{
		[self setBounds: boundsRect];
		[self setFov: 110.0f];
		_zoomEnabled = YES;
		[self setXZoom:1.0f yZoom:1.0f];
		camera = self;
    }
	
    return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[super dealloc];
}

#pragma mark action methods
/*
 * The Key Camera Settings
 * Called every time we draw
 */
- (void)useWith:(id)anObject atTime:(double)time
{
	// @try {
	 // _C3DTVector	offset = cartesianToSpherical(vectorSubtract(_pos, _lookAt));
	_C3DTVector offset = _pos;
	glViewport( 0, 0, _frustum.x, _frustum.y); // this needs to be in window co-ords i think
	// move this somewhere else	glViewport( 0, 0, 768, 576); // this needs to be in window co-ords i think
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
	glMatrixMode( GL_PROJECTION );   
	glLoadIdentity();                
		
	   // see if we are in selection mode
//STEVE		   if( _selectionMode != CameraModeNormal )
	   // if (_selectionMode || _mouseUpMode)
//STEVE			{
//STEVE				GLint viewPort[4];
			// initialise a new name stack for picking objects
			// each Entity and Transform puts a name on the stack
//STEVE			[self initNameStack]; //glInitNames();
			// glPushName(-1);
	
		//	NSLog(@" ");
		//	NSLog(@"Initing names ");
//STEVE				glGetIntegerv(GL_VIEWPORT, viewPort);
			
			// creates a projection matrix for picking that restricts drawing to w * h
			// area centred at x,y in window coordinates within the viewport
//STEVE			gluPickMatrix(_selectionPoint.x, _selectionPoint.y,  _selectionSize.width, _selectionSize.height,  viewPort);
//STEVE			}
		
//STEVE		// By default, view depth starts at 1/1000th of total depth
		if (_useOrtho){
			// Sets the ortho mode
			GLdouble widthOver2 = [self frustumWidth]/2.0;
			GLdouble heightOver2 = [self frustumHeight]/2.0;			
			// DEFINE THE VIEW AREA..
			glOrtho( -widthOver2, widthOver2, -heightOver2, heightOver2, -_frustum.z, _frustum.z );

			
	} else {
			// Sets the perspective mode (default)
			// NB _frustum values are important in perspective mode - cant
			// just fuck about with em like im doing with zoom
			gluPerspective(_fov, _frustum.x / _frustum.y, 0.1, _frustum.z);
		}

		// Sets the camera position ad orientation: by default, we're always standing up
//		gluLookAt( _pos.x, _pos.y, _pos.z,
//		           _lookAt.x, _lookAt.y, _lookAt.z,
//		           0.0f, 1.0f, 0.0f);
		


		// Translate to the looking point
    glTranslatef(_lookAt.x, _lookAt.y, _lookAt.z);


		
    // Move away from the center
    glTranslatef(0.0, 0.0, -offset.r);
	

    // Rotate elevation
    glRotatef(rad2deg(offset.phi), 1.0, 0.0, 0.0);
    // Rotate azimuth (- π/2, 0 is on Z while spherical 0 is on X)

    glRotatef(rad2deg(offset.theta - M_PI_2), 0.0, 1.0, 0.0);
	/* should we do this every time ? */
		glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix

		
//	[self calcFrustumEquations];

		
//a	[OpenGlThread_Debug unlockContext:[_context CGLContextObj] withName:20];
	
//	} @catch (NSException *exception) {
//		NSLog(@"Camera.m: Caught %@: %@", [exception name], [exception reason]);
//	} @finally {
		// [cup release];
//	}
}

- (void)calcFrustumEquations
{

     // Retrieve matrices from OpenGL
	_C3DTMatrix modelMatrix, projectionMatrix;
	glGetFloatv(GL_MODELVIEW_MATRIX, modelMatrix.flts);
	glGetFloatv(GL_PROJECTION_MATRIX, projectionMatrix.flts);
	
	/* test geometry kit multiply */
	
	/* NORMAILISING AND VECTOR LENGTHS ARE WRONG IN GEOMETRY KIT */
	_C3DTMatrix clip = matrixMultiply(projectionMatrix, modelMatrix);
	
   /* Extract the numbers for the RIGHT plane */
   _frustum2.planes[0].x = clip.flts[ 3] - clip.flts[ 0];
   _frustum2.planes[0].y = clip.flts[ 7] - clip.flts[ 4];
   _frustum2.planes[0].z = clip.flts[11] - clip.flts[ 8];
   _frustum2.planes[0].w = clip.flts[15] - clip.flts[12];

   /* Normalize the result */
   float t = sqrt( _frustum2.planes[0].x * _frustum2.planes[0].x + _frustum2.planes[0].y * _frustum2.planes[0].y + _frustum2.planes[0].z * _frustum2.planes[0].z );
   _frustum2.planes[0].x /= t;
   _frustum2.planes[0].y /= t;
   _frustum2.planes[0].z /= t;
   _frustum2.planes[0].w /= t;

  /* Extract the numbers for the LEFT plane */
   _frustum2.planes[1].x = clip.flts[ 3] + clip.flts[ 0];
   _frustum2.planes[1].y = clip.flts[ 7] + clip.flts[ 4];
   _frustum2.planes[1].z = clip.flts[11] + clip.flts[ 8];
   _frustum2.planes[1].w = clip.flts[15] + clip.flts[12];

   /* Normalize the result */
   t = sqrt( _frustum2.planes[1].x * _frustum2.planes[1].x + _frustum2.planes[1].y * _frustum2.planes[1].y + _frustum2.planes[1].z * _frustum2.planes[1].z );
   _frustum2.planes[1].x /= t;
   _frustum2.planes[1].y /= t;
   _frustum2.planes[1].z /= t;
   _frustum2.planes[1].w /= t;

   /* Extract the BOTTOM plane */
   _frustum2.planes[2].x = clip.flts[ 3] + clip.flts[ 1];
   _frustum2.planes[2].y = clip.flts[ 7] + clip.flts[ 5];
   _frustum2.planes[2].z = clip.flts[11] + clip.flts[ 9];
   _frustum2.planes[2].w = clip.flts[15] + clip.flts[13];

   /* Normalize the result */
   t = sqrt( _frustum2.planes[2].x * _frustum2.planes[2].x + _frustum2.planes[2].y * _frustum2.planes[2].y + _frustum2.planes[2].z * _frustum2.planes[2].z );
   _frustum2.planes[2].x /= t;
   _frustum2.planes[2].y /= t;
   _frustum2.planes[2].z /= t;
   _frustum2.planes[2].w /= t;

   /* Extract the TOP plane */
   _frustum2.planes[3].x = clip.flts[ 3] - clip.flts[ 1];
   _frustum2.planes[3].y = clip.flts[ 7] - clip.flts[ 5];
   _frustum2.planes[3].z = clip.flts[11] - clip.flts[ 9];
   _frustum2.planes[3].w = clip.flts[15] - clip.flts[13];

   /* Normalize the result */
   t = sqrt( _frustum2.planes[3].x * _frustum2.planes[3].x + _frustum2.planes[3].y * _frustum2.planes[3].y + _frustum2.planes[3].z * _frustum2.planes[3].z );
   _frustum2.planes[3].x /= t;
   _frustum2.planes[3].y /= t;
   _frustum2.planes[3].z /= t;
   _frustum2.planes[3].w /= t;

   /* Extract the FAR plane */
   _frustum2.planes[4].x = clip.flts[ 3] - clip.flts[ 2];
   _frustum2.planes[4].y = clip.flts[ 7] - clip.flts[ 6];
   _frustum2.planes[4].z = clip.flts[11] - clip.flts[10];
   _frustum2.planes[4].w = clip.flts[15] - clip.flts[14];

   /* Normalize the result */
   t = sqrt( _frustum2.planes[4].x * _frustum2.planes[4].x + _frustum2.planes[4].y * _frustum2.planes[4].y + _frustum2.planes[4].z * _frustum2.planes[4].z );
   _frustum2.planes[4].x /= t;
   _frustum2.planes[4].y /= t;
   _frustum2.planes[4].z /= t;
   _frustum2.planes[4].w /= t;

   /* Extract the NEAR plane */
   _frustum2.planes[5].x = clip.flts[ 3] + clip.flts[ 2];
   _frustum2.planes[5].y = clip.flts[ 7] + clip.flts[ 6];
   _frustum2.planes[5].z = clip.flts[11] + clip.flts[10];
   _frustum2.planes[5].w = clip.flts[15] + clip.flts[14];

   /* Normalize the result */
   t = sqrt( _frustum2.planes[5].x * _frustum2.planes[5].x + _frustum2.planes[5].y * _frustum2.planes[5].y + _frustum2.planes[5].z * _frustum2.planes[5].z );
   _frustum2.planes[5].x /= t;
   _frustum2.planes[5].y /= t;
   _frustum2.planes[5].z /= t;
   _frustum2.planes[5].w /= t;
   
   /* These produce subtly different results - i think it is viewFrustum() that is wrong */ 
	_OPENGLViewFrustum = viewFrustum( projectionMatrix, modelMatrix );

	_OPENGLViewFrustum = _frustum2;
	
//	float farx = _OPENGLViewFrustum.planes[4].x;
//	float fary =_OPENGLViewFrustum.planes[4].y;
//	float farz =_OPENGLViewFrustum.planes[4].z;
//	float farw =_OPENGLViewFrustum.planes[4].w;
//	NSLog(@"far values are (%f, %f, %f, %f)", farx, fary, farz, farw);
	
//	_OPENGLViewFrustum.planes[4].x = farx/2;
//	_OPENGLViewFrustum.planes[4].y = fary/2;
//	_OPENGLViewFrustum.planes[4].z = farz/2;
//	_OPENGLViewFrustum.planes[4].w = farw+1;
	
//	int i;
//	for(i=0;i<6;i++){
//		_C3DTPlane plane = _OPENGLViewFrustum.planes[i]; // (ax + by + cz + d = 0)
//		glColor3f(1.0, 1.0, 1.0f);
//		glPolygonMode(GL_FRONT, GL_LINE);
//		glBegin(GL_QUADS);
//			glVertex3f( -5.0, -5.0, 0.);
//			glVertex3f(	5.0, -5.0, 0.);
//			glVertex3f( 5.0, 5.0, 0.);
//			glVertex3f( -5.0, 5.0, 0.);
//		glEnd();	
//	}
	
}

   /**************
   * Classifying *
   **************/
//   int DCuller::SphereInFrustum(const DVector3 *center,dfloat radius) const
//   // Returns classification (INSIDE/INTERSECTING/OUTSIDE)
//   {
//     int i;
//     const DPlane3 *p;
//   
//     for(i=0;i<6;i++)
//     {
//       p=&frustumPlane[i];
//       if(p->n.x*center->x+p->n.y*center->y+p->n.z*center->z+p->d <= -radius)
//         return OUTSIDE;
//     }
//     // Decide: Inside or intersecting
//     return INTERSECTING;
//   }

#pragma mark accessor methods
// ===========================================================
// - frustumWidth:
// ===========================================================
- (GLdouble)frustumWidth
{
	return _frustum.x * _zoom.x;
}

// ===========================================================
// - frustumHeight:
// ===========================================================
- (GLdouble)frustumHeight
{
	return _frustum.y * _zoom.y;
}

// ===========================================================
// - frustumLeft:
// ===========================================================
- (GLdouble)frustumLeft
{
	/* what is the difference between lookat and position? */
	/* positive lookat is to the left */
	GLdouble left = -_lookAt.x - [self frustumWidth]/2;
	// GLdouble left = 1*(((_frustum.x/2) + _lookAt.x)* _zoom.x);
	return left;
}

// ===========================================================
// - frustumRight:
// ===========================================================
- (GLdouble)frustumRight
{
	GLdouble right = -_lookAt.x + [self frustumWidth]/2;
	return right;
}

// ===========================================================
// - frustumTop:
// ===========================================================
- (GLdouble)frustumTop
{
	GLdouble top = -_lookAt.y + [self frustumHeight]/2;
	return top;
}

// ===========================================================
// - frustumBottom:
// ===========================================================
- (GLdouble)frustumBottom
{
	GLdouble bottom = -_lookAt.y - [self frustumHeight]/2;
	return bottom;
}


// ===========================================================
// - setBounds:
// ===========================================================
// for some reason the bounds seem to short - 
// adding a bit on. Could it be to do with the menu bar?
- (void)setBounds:(NSRect)boundsRect
{
    // Set camera parameters based on the view frame
    // As a default, we put depth == width
	// NSLog(@"setting frustrum %f", boundsRect.size.width );
	double width = boundsRect.size.width;
	double height = boundsRect.size.height;
//	GLdouble aspect = height/width;

	// use QC like co-ordinates
    [self setFrustumWidth:width height:height depth:100000];
}

/*
 *
 */
- (void)setFrustumWidth:(GLdouble)w height: (GLdouble)h depth: (GLdouble)d
{
    _frustum.x = w ;
    _frustum.y = (h != 0.0f ? h : .000001);		// To avoid problems in calculating aspect factor
    _frustum.z = (d != 0.0f ? d : .01);			// To avoid problems in calculating view depth
    _frustum.w = 1.0;
}

- (_C3DTVector)frustum
{
    return _frustum;
}

- (void)setFrustum: (_C3DTVector)newPos
{
    _frustum = newPos;
}


/*
 *
 */
- (GLdouble)fov
{
    return _fov;
}

/*
 *
 */
- (void)setFov: (GLdouble)newFov
{
    if ((_fov = newFov) < 0.1)
        _fov = 0.1;
    else if (_fov > 179.0)
        _fov = 179.0;
}

// ===========================================================
// - zoom:
// ===========================================================
- (NSPoint*)zoom
{
    return &_zoom;
}


// ===========================================================
// - setZoom:
// ===========================================================
- (void)setZoom:(NSPoint*)newZoom
{
	if(_zoomEnabled==YES)
	{
		if(newZoom->x==0.0f) 
			newZoom->x = 0.00001f;
		if(newZoom->y==0.0f) 
			newZoom->y = 0.00001f;

		/* attempt to memory manage the structs */
		_zoom.x = newZoom->x;
		_zoom.y = newZoom->y;
	}
}

// ===========================================================
// - setXZoom: yZoom:
// ===========================================================
- (void) setXZoom:(double)xZoom yZoom:(double)yZoom
{
	if(_zoomEnabled==YES)
	{
		if(xZoom==0.0f) 
			xZoom = 0.00001f;
		if(yZoom==0.0f) 
			yZoom = 0.00001f;

		_zoom.x = xZoom;
		_zoom.y = yZoom;
	}
}

// ===========================================================
// - pos:
// ===========================================================
- (_C3DTVector)pos
{
	_C3DTVector temp = vectorAdd(sphericalToCartesian(_pos), _lookAt);
	NSLog(@"Camera.m: pos.x is %f", temp.x);
    return temp;
}

- (void)setPos:(_C3DTVector)newPos
{
    _pos = cartesianToSpherical(vectorSubtract(newPos, _lookAt));
}

- (void)setPosX: (float)x Y: (float)y Z: (float)z
{
    _C3DTVector	newPos;
    
    newPos.x	= x;
    newPos.y	= y;
    newPos.z	= z;
    newPos.w	= 1.0;	// This is mathematically NOT correct, we just ignore quaternions at this moment

    [self setPos: newPos];
}

// ===========================================================
// - lookAt:
// ===========================================================
- (_C3DTVector)lookAt
{
	// NSLog(@"Camera.m: frustumTop.x is %f", [self frustumTop]);
    return _lookAt;
}

/*
 * Used to pan the view
 */
- (void)setLookAt:(_C3DTVector)newPos
{
    _lookAt = newPos;
    // WARNING: This is necessary, but is not elegant
    [self setPos: vectorAdd(sphericalToCartesian(_pos), _lookAt)];
}


/*
 * Used to pan the view
 */
- (void)setLookAtX:(GLdouble)x Y:(GLdouble)y Z:(GLdouble)z
{
    _lookAt.x = x;
    _lookAt.y = y;
    _lookAt.z = z;
    _lookAt.w = 1.0;
    [self setPos: vectorAdd(sphericalToCartesian(_pos), _lookAt)];
}

- (void)setUseOrtho:(BOOL)ortho
{
    _useOrtho = ortho;
}

- (void)rotateToAzimuth: (float)theta elevation: (float)phi distance: (float)d
{
    //_C3DTVector	newPos	= cartesianToSpherical(vectorSubtract(_pos, _lookAt));
    _C3DTVector	newPos	= _pos;
    float		pi2		= 2.0 * M_PI;

    // Limit angles to +/- 180 degrees
    if ((newPos.theta = theta) > M_PI)
        newPos.theta -= pi2;
    else if (newPos.theta < -M_PI)
        newPos.theta += pi2;

    if ((newPos.phi = phi) > M_PI) {
        newPos.phi -= pi2;
    }
    if (newPos.phi < -M_PI) {
        newPos.phi += pi2;
    }

    if ((newPos.r = d) <= 0.0)
        newPos.r = EPSILON;

    _pos = newPos;
}


- (void)rotateByDegreesX: (float)theta Y: (float)phi
{
    //_C3DTVector	newPos	= cartesianToSpherical(vectorSubtract(_pos, _lookAt));
    _C3DTVector	newPos	= _pos;

    newPos.phi		+= deg2rad(phi);
    newPos.theta	+= deg2rad(theta);

    [self rotateToAzimuth: newPos.theta elevation: newPos.phi distance: newPos.r];
}


- (float)distance
{
    return _pos.r;
}

- (void)setDistance: (float)d
{
    if ((_pos.r = d) <= 0.0)
        _pos.r = EPSILON;
}

- (_C3DTFrustum)OPENGLViewFrustum
{
	return _OPENGLViewFrustum;
}



   
@end
