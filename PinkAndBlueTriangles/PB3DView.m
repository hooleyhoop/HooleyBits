//
//  PB3DView.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 13/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PB3DView.h"
#import "FloorGrid.h"
#import <GLUT/glut.h>
#import <OpenGL/CGLMacro.h>
//#import "SHGeometryKit/SHGeometryKit.h"
#import "PBCamera.h"
#import <sys/time.h>
#import <unistd.h>
#import <stdlib.h>
#import <stdio.h>
#import <math.h>

// GLOBAL CGLContext
// Faster opengl dispatch via CGLMacro
CGLContextObj cgl_ctx;

@implementation PB3DView


#pragma mark -
#pragma mark class methods

#pragma mark init methods

- (void)_initCameraAndGL {

	[context clearDrawable];
	[context setView:self];
	
	//TODO: Isnt the glmacro stuff instead of this?
	[context makeCurrentContext];

    camera = [[PBCamera alloc] initWithBounds:[self bounds]];
    
    // Enable some OpenGL parts by default
//    glShadeModel( GL_SMOOTH );		// Enable smooth shading
//    glEnable(GL_LIGHTING);			// Enable Lighting
//    glEnable(GL_DEPTH_TEST);		// Enable hidden surface removal
//    glDepthFunc(GL_LESS);
	glCullFace(GL_BACK);
	glEnable(GL_CULL_FACE);			// Don't consider "internal" faces
   // enable culling
//   glEnable( GL_POLYGON_SMOOTH );
//  glBlendFunc( GL_SRC_ALPHA_SATURATE, GL_ONE );
//   glEnable( GL_BLEND );
    // As default, we use the simplest mode to track material & color
//    glEnable(GL_COLOR_MATERIAL);
//    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);

//    glEnable(GL_BLEND);				// Enable Blending
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

//	glEnable(GL_TEXTURE_2D);
//	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glDisable(GL_DEPTH_TEST);				
	glPolygonMode(GL_FRONT, GL_FILL);
//	glDisable(GL_TEXTURE_RECTANGLE_EXT);	
//	glDisable(GL_BLEND);	

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT, GL_FASTEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);	// multiply texture color with quad color
	
	glClearDepth(1.0f);
//  glClearAccum( 0.0, 0.0, 0.0, 0.5 );
 	[camera setUseOrtho: NO];

	C3DTVector cameraPos = {{ 50.0f, -200.0f, 70.0f, 1.0f }}; // minus x moves to the right, minus y moves towards,
	[camera setPos: cameraPos];
	[camera setLookAtX: -30.0f Y:20 Z:0]; // minus x moves to the right, minus y moves towards,
	// Optional: sets orthographic view instead of perspective
	
    // Try to use arrays
    /*
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_INDEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    */
    // Really nice perspective calculations
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
}


- (id)initWithFrame:(NSRect)frame {

    self = [super initWithFrame:frame];
    if(self) {

		GLuint attribs[] =
		{
			NSOpenGLPFAWindow, 
			NSOpenGLPFACompliant,
			NSOpenGLPFABackingStore,
			NSOpenGLPFANoRecovery, 
			NSOpenGLPFADoubleBuffer, 
			NSOpenGLPFAAccelerated,
			NSOpenGLPFAMPSafe,
			NSOpenGLPFASupersample,
			NSOpenGLPFADepthSize, 8,
			NSOpenGLPFAColorSize, 24,
			NSOpenGLPFAAccumSize, 8,
			NSOpenGLPFAStencilSize, 8,
			NSOpenGLPFAAlphaSize, 8,
			0
		};

		pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute *)attribs];
		context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
		
		const GLint swapInterval = 1;
		[context setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	
		// GLOBAL CONTEXT
		// Faster opengl dispatch via CGLMacro
		cgl_ctx = [context CGLContextObj];
				
		if(!pixelFormat)
			NSLog(@"No OpenGL pixel format");

		[context makeCurrentContext];
	
		// [self _initCameraAndGL];
		currentTime = 0.0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_surfaceNeedsUpdate:) name:NSViewGlobalFrameDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
	
	[context release];
	[camera release];
	[floorGrid release];
	[drawTimer release];

	[super dealloc];
}

- (void)awakeFromNib {
	
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
	[defaultCenter addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
	[defaultCenter addObserver:self selector:@selector(stop:) name:@"gridWillChange" object:self];
	[defaultCenter addObserver:self selector:@selector(start:) name:@"gridDidlChange" object:self];
	
    [self _initCameraAndGL];
}

#pragma mark notification methods
- (void)viewDidResize:(NSNotification *)note {
	
	[self reshape];
	[self update];
	[self setTracking];
	[self setNeedsDisplay:YES];
}

- (void)viewDidMoveToWindow {
	
    [super viewDidMoveToWindow];
    if ([self window] == nil)
        [context clearDrawable];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	mousePt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

// - (void)flagsChanged:(NSEvent *)theEvent

- (void)_surfaceNeedsUpdate:(NSNotification*)notification {

  [self update];
}

#pragma mark action methods
- (IBAction)stop:(id)sender {

	[drawTimer invalidate];
	[drawTimer release];
	drawTimer = nil;
}

- (IBAction)start:(id)sender {

	startTime = [[NSDate date] timeIntervalSinceReferenceDate];

	/* basic animation */
	if(!drawTimer)
		drawTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES] retain];
}

- (void)update {

  if([context view]==self) {
    [context update];
  }
}

- (void)reshape {

    [context update];
    // We don't use accessor here because reshape could be called before camera is set,
    // thus we'll go in an endless loop
    [camera setBounds: [self bounds]];

    [self setNeedsDisplay: YES];
}


- (void)drawRect:(NSRect)rect {
	
    [context makeCurrentContext];

	// draw on anchor point
//	[[NSColor whiteColor] set];
//	NSFrameRect(rect );
//	[[NSColor grayColor] set];
//	NSRectFill( rect );
			
	// translate (0,0) to centre of window
//	NSAffineTransform* xform = [NSAffineTransform transform];
//	[xform translateXBy:rect.size.width/2.0 yBy:rect.size.height/2.0];
//	NSPoint centrePoint = [xform transformPoint:NSMakePoint(0,0)];
	
    glClearColor(0, 0, 0, 0);
    glClearDepth(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if(camera){
		[floorGrid moveForwardAtTime: currentTime];
		[floorGrid useWith:camera atTime: currentTime];
	}
    glSwapAPPLE();
}

- (void)animate {
	
//	currentTime = [[NSDate date] timeIntervalSinceReferenceDate] - startTime;
	[self setNeedsDisplay:YES];
}

- (void)lockFocus {
	
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    [context makeCurrentContext];
}


#pragma mark accessor methods
- (void)setTracking {

	[self removeTrackingRect:trackingRect];
	NSRect b = [self bounds];
	trackingRect = [self addTrackingRect:b owner:self userData:NULL assumeInside:NO];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}  

- (FloorGrid *)floorGrid {

	return floorGrid;
}

- (void)setFloorGrid:(FloorGrid *)value {

	if(value != floorGrid){
		[floorGrid release];
		floorGrid = [value retain];
	}
}

- (PBCamera *)camera {

	return camera;
}

- (double)currentTime {

	return currentTime;
}

- (void)inceraseCurrentTime:(double)value {

	currentTime = currentTime+value;
}

@end
