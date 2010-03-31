//
//  OpenGLView.m
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"
#import "TextureWrapper.h"
#import "HooleyTexturedRect.h"
#import "AppControl.h"
#import <Quartz/Quartz.h>

CGLContextObj cgl_ctx;  // Magical CGLMacro context that prevents OpenGL having to look up the current context for every single OpenGL call.


@implementation OpenGLView

- (id)initWithFrame:(NSRect)frame {
	GLuint attribs[] = 
	{
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAWindow,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAStencilSize, 8,
		NSOpenGLPFAAccumSize, 0,
		0
	};
	
	NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: (NSOpenGLPixelFormatAttribute*) attribs]; 
	
	if (!fmt)
		NSLog(@"No OpenGL pixel format");
	
	/* array of stuff to draw */
	[self setDrawables: [NSMutableArray arrayWithCapacity:3]];
	
	return self = [super initWithFrame:frame pixelFormat: [fmt autorelease]];
}

- (void)dealloc
{
	[myCIContext release];
	[drawTimer release];
	[drawables release];
	[super dealloc];
}

- (void)setTracking
{
	[self removeTrackingRect:trackingRect];
	NSRect b = [self bounds];
	trackingRect = [self addTrackingRect:b owner:self userData:NULL assumeInside:NO];
}

- (void)viewDidResize:(NSNotification *)note
{
    [self reshape];
	[self update];
	[self setTracking];
	[self setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
	[defaultCenter addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];

	[[self openGLContext]  makeCurrentContext];
	cgl_ctx = [[self openGLContext] CGLContextObj];  // Faster opengl dispatch via CGLMacro
	[self viewDidResize:nil];
	
	glDisable(GL_TEXTURE_2D);                
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	// glEnable(GL_BLEND);	// only needed for transparency

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT, GL_FASTEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);	// multiply texture color with quad color
	glEnable(GL_SCISSOR_TEST);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	myCIContext = [CIContext contextWithCGLContext:cgl_ctx pixelFormat:[[self pixelFormat] CGLPixelFormatObj] options:[NSDictionary dictionaryWithObjectsAndKeys:(id)colorSpace, kCIContextOutputColorSpace,(id)colorSpace, kCIContextWorkingColorSpace, nil]];
	[myCIContext retain];
	CGColorSpaceRelease(colorSpace);
	
    [[self openGLContext] setView:self];
	[[self window] setAcceptsMouseMovedEvents:YES];

	/* basic animation */
	drawTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES] retain];
}


- (void)animate
{
	[self setNeedsDisplay:YES];
}

static NSPoint mousePt;
- (void)drawRect:(NSRect)rect 
{
	if([self openGLContext])
	{
		NSRect frame = [self frame];
		[[self openGLContext]  makeCurrentContext];

		// Define the opengl view area
		glViewport(0, 0, (GLsizei) frame.size.width, (GLsizei) frame.size.height);
		
		/* reset opengl transform matrixces */
		glMatrixMode( GL_PROJECTION );   
		glLoadIdentity(); 
		glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
		glLoadIdentity();                // and reset it
		
		// DEFINE THE VIEW CO-ORDS..
		glOrtho( 0, rect.size.width, 0, rect.size.height, rect.size.height, -rect.size.height );
		glScissor( 0, 0,  rect.size.width, rect.size.height); // this needs to be in window co-ords i think

		/* clear the screen */
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		/* draw our custom objects */
		NSEnumerator* objs = [drawables objectEnumerator];
		HooleyTexturedRect* obj;
		while( obj = [objs nextObject] ) 
		{
			[obj setTranslation:mousePt];
			[obj draw];
			glError();
		}
		
		/* swap our backbuffer to the front. Synced to screen refresh so may block this thread */
		glSwapAPPLE();

	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	mousePt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)addDrawableShape:(HooleyTexturedRect *)value
{
	[drawables addObject:value];
}

- (NSMutableArray *)drawables {
    return drawables;
}

- (void)setDrawables:(NSMutableArray *)newDrawables {
    if (drawables != newDrawables) {
        [drawables release];
        drawables = [newDrawables retain];
    }
}

- (CIContext *)ciCntx
{
	return myCIContext;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}  
@end
