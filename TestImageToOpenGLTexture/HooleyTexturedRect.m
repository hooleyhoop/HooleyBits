//
//  HooleyTexturedRect.m
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HooleyTexturedRect.h"
#import "TextureWrapper.h"
#import "AppControl.h"

extern CGLContextObj cgl_ctx;

@implementation HooleyTexturedRect

+ (id)rectWithTexture:(TextureWrapper *)openglTexture
{
	return [[[self alloc] initWithTexture:openglTexture] autorelease];
}

- (id)initWithTexture:(TextureWrapper *)openglTexture
{
	if ((self = [super init]) != nil) 
	{
		[self setTxtr:openglTexture];
        _displayListId = -1;
		_alpha = 1.0;
		
		_anchorPoint = NSMakePoint(0,0);
		_rotation = NSMakePoint(0,0);
		_translation = NSMakePoint(100,100);
		_scaling = NSMakePoint(1.0,1.0);
		
		[self buildQuadWithWidth:[openglTexture width] height:[openglTexture height] textureWidth:[openglTexture width] textureHeight:[openglTexture height]];
	}
	return self;
}

- (void)dealloc
{
	[self destroyDisplayList];
	[self setTxtr:nil];
	[super dealloc];
}

- (void)buildQuadWithWidth:(double)aWidth height:(double)aHeight textureWidth:(int)pixelWidth textureHeight:(int)pixelHeight
{
	_width = aWidth;
	_height = aHeight;
	_txtWidth = pixelWidth;
	_txtHeight = pixelHeight;
	
	GLfloat verts[4][3];
	verts[0][0] = -aWidth / 2.; // anticlockwise sq
	verts[0][1] = aHeight / 2.;
	verts[0][2] = 0.;
	
	verts[1][0] = -aWidth / 2.;
	verts[1][1] = -aHeight / 2.;
	verts[1][2] = 0.;
	
	verts[2][0] = aWidth / 2.;
	verts[2][1] = -aHeight / 2.;
	verts[2][2] = 0.;
	
	verts[3][0] = aWidth / 2.;
	verts[3][1] = aHeight / 2.;
	verts[3][2] = 0.;

	[self startDisplayList];
	
	/* draw the quad */
	glBegin(GL_QUADS);
	glNormal3f( 0.0, 0.0, 1.0 );
	glTexCoord2f((GLfloat)0.0, (GLfloat)pixelHeight);			
	glVertex3fv( verts[0]);
	glTexCoord2f((GLfloat)0.0, (GLfloat)0.0);					
	glVertex3fv( verts[1] );
	glTexCoord2f((GLfloat)pixelWidth, (GLfloat)0.0);			
	glVertex3fv( verts[2] );
	glTexCoord2f((GLfloat)pixelWidth, (GLfloat)pixelHeight);	
	glVertex3fv( verts[3] );
	glEnd();
	
	[self stopDisplayList];
}

- (void)startDisplayList
{
    if (_displayListId != -1) {
        glDeleteLists(_displayListId, 1);
    }
    glNewList(_displayListId = glGenLists(1), GL_COMPILE);
}

- (void)stopDisplayList
{
    glEndList();
}

- (void)destroyDisplayList
{
	if (_displayListId != -1) {
		glDeleteLists(_displayListId, 1);
	}
	_displayListId = -1;
}


// ===========================================================
// - draw:
// ===========================================================
- (void)draw
{	
    if (_displayListId != -1) 
	{
		// for transparency
		//glBlendColor(1, 1.0, 1.0, _alpha);
		//glColor4f(1.0, 1.0, 1.0, _alpha);
		//glBlendFunc( GL_CONSTANT_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        glPushMatrix();
		_translation.x = _translation.x+1;
		if ((_translation.x != 0.0) || (_translation.y != 0.0) ) {
            glTranslatef(_translation.x, _translation.y, 0.0);
        }
		
        // Scaling
        if ((_scaling.x != 1.0) || (_scaling.y != 1.0) ) {
			glScalef(_scaling.x, _scaling.y, 1.0);
        }
        
        // Rotation
        glTranslatef(-_anchorPoint.x, -_anchorPoint.y, 0.0);
		
        if (_rotation.x != 0.0)
            glRotatef(_rotation.x, 1.0f, 0.0f, 0.0f);
        if (_rotation.y != 0.0)
            glRotatef(_rotation.y, 0.0f, 1.0f, 0.0f);

		glTranslatef(_anchorPoint.x, _anchorPoint.y, 0.0);
	
		/* make our texture the current txt */
		[txtr apply];
		
		/* draw our 'precompiled' geometry */
		glCallList(_displayListId);
		
		glPopMatrix();
    }
}


- (TextureWrapper *)txtr {
    return txtr;
}

- (void)setTxtr:(TextureWrapper *)value {
    if (txtr != value) {
        [txtr release];
        txtr = [value retain];
    }
}

- (void)setTranslation:(NSPoint)value
{
	_translation = value;
}

@end
