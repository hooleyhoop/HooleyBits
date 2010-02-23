//
//  BBRenderer.m
//  BBExtras
//
//  Created by Jonathan del Strother on 06/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "BBRenderer.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>

@implementation BBRenderer

+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 1;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return FALSE;
}

+ (int)timeMode
{
	return 1;	//Allow external time patch
}
	
- (id)initWithIdentifier:(id)fp8
{
	// Do your initialization of variables here 
	NSLog(@"Init Rendering patch");
	
	return [super initWithIdentifier:fp8];
}
	
- (void)dealloc
{
	[super dealloc];
}
	
- (id)setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	return fp8;
}

typedef struct {
	float x,y,z;
	float xDot, yDot, zDot;
	float xDDot, yDDot, zDDot;
} Particle;

static Particle* particles = nil;
static int numParticles = 500;

#define NRAND (rand()%1000 * 0.002 - 1)
	
- (BOOL)execute:(id)context time:(double)fp12 arguments:(id)fp20
{
	// This is where the execution of your patch happens.
	// Everything in this method gets executed once
	// per 'clock cycle', which is available in fp12 (time).

	// Read/Write any ports in here too.

	if (!particles)
	{
		particles = malloc(sizeof(Particle)*numParticles);
		for (int i=0; i<numParticles; i++)
		{
			float circleLoc = NRAND * 3.1415829;

			particles[i].x = NRAND*0.0001 + 0.5*sinf(circleLoc);
			particles[i].y = NRAND*0.0001 + 0.5*cosf(circleLoc);
			particles[i].z = NRAND*0.0001 + 0;
			
			particles[i].xDot = 0.01*(NRAND*0.01 + (NRAND*0.1+1)*cosf(circleLoc));
			particles[i].yDot = 0.01*(NRAND*0.01 - (NRAND*0.1+1)*sinf(circleLoc));
			particles[i].zDot = 0.01*(NRAND*0.1 + 0);
			
			particles[i].xDDot = particles[i].yDDot = particles[i].zDDot = 0;
		}
	}

	
	CGLSetCurrentContext([context CGLContextObj]);
	
	GLfloat fogColor[] = {0.0,0.0,0.0,1}; // fog color
	
	glEnable (GL_FOG); // turn on fog, otherwise you won't see any
	glFogi (GL_FOG_MODE, GL_LINEAR); // Fog fade using linear function
	glFogfv (GL_FOG_COLOR, fogColor); // Set the fog color
	glFogf (GL_FOG_DENSITY, 0.05); // Set the density, don't make it too high.
	glFogf (GL_FOG_START, 0.1); 
	glFogf (GL_FOG_END, 2); 
	glHint (GL_FOG_HINT, GL_NICEST); // ROS says Set default calculation mode
	
//	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(1,1,1,0.1);
	
	glMatrixMode(GL_MODELVIEW);
	glRotatef(30,1,1,0);
	glTranslatef(0,-1,-1);
	
//	[context makeCurrentContext];
	glBegin(GL_TRIANGLES);
	for (int i=0; i<numParticles; i++)
	{
		
		particles[i].x += particles[i].xDot + 0.5*particles[i].xDDot*particles[i].xDDot;
		particles[i].y += particles[i].yDot + 0.5*particles[i].yDDot*particles[i].yDDot;
		particles[i].z += particles[i].zDot + 0.5*particles[i].zDDot*particles[i].zDDot;
				
		particles[i].xDot += 0.5*particles[i].xDDot;
		particles[i].yDot += 0.5*particles[i].yDDot;
		particles[i].zDot += 0.5*particles[i].zDDot;
		
		static int hack=0;
		particles[i].xDDot = -0.001*(particles[i].x -(hack++%100)*0.01);
		particles[i].yDDot = -0.001*(particles[i].y -(hack++%100)*0.01);
		particles[i].zDDot = -0.001*(particles[i].z -(hack++%100)*0.001);

					
		glVertex3f(particles[i].x, particles[i].y, particles[i].z);
		glVertex3f(particles[i].x+0.5, particles[i].y, particles[i].z);
		glVertex3f(particles[i].x, particles[i].y+0.5, particles[i].z);		
	}
	glEnd();
	
	glDisable(GL_BLEND);

	return YES;
}

@end
