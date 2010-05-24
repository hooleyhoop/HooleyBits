//
//  PBCamera.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 11/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <SHGeometryKit/SHGeometryKit.h>

@interface PBCamera : NSObject {

    C3DTVector		_pos;			// Camera position
    C3DTVector		_lookAt;		// Looking at this point
    C3DTVector		_frustum;		// height,width & depth of the view
	
	C3DTFrustum		_OPENGLViewFrustum; // so far i havent compared this to the one above. This one is obtained from opengl
	C3DTFrustum		_frustum2;

    GLdouble		_fov;			// Angle of the view
	NSPoint			_zoom;			// ortho zoom
	BOOL			_zoomEnabled;	
    BOOL			_useOrtho;		// Use orthographic view instead of perspective
	
}

#pragma mark -
#pragma mark class methods
+ (PBCamera *)camera;

#pragma mark init methods
- (id)initWithBounds:(NSRect)boundsRect;

#pragma mark action methods
- (void)useWith:(id)anObject atTime:(double)time;
- (void)calcFrustumEquations;

#pragma mark accessor methods
// return scaled dimensions
- (GLdouble)frustumWidth;
- (GLdouble)frustumHeight;
- (GLdouble)frustumLeft;
- (GLdouble)frustumRight;
- (GLdouble)frustumTop;
- (GLdouble)frustumBottom;

- (void)setBounds:(NSRect)boundsRect;
- (void)setFrustumWidth:(GLdouble)w height: (GLdouble)h depth: (GLdouble)d;
- (GLdouble)fov;
- (void)setFov:(GLdouble)newFov;

- (NSPoint*)zoom;
- (void)setZoom:(NSPoint*)newZoom;
- (void) setXZoom:(double)xZoom yZoom:(double) yZoom;

- (C3DTVector)pos;
- (void)setPos:(C3DTVector)newPos;
- (void)setPosX: (float)x Y: (float)y Z: (float)z;

- (C3DTVector)lookAt;
- (void)setLookAt:(C3DTVector)newPos;
- (void)setLookAtX:(GLdouble)x Y:(GLdouble)y Z:(GLdouble)z;
- (void)setUseOrtho:(BOOL)ortho;

- (C3DTFrustum)OPENGLViewFrustum;

@end
