//
//  TextureWrapper.m
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TextureWrapper.h"
#import "AppControl.h"
#import <Quartz/Quartz.h>

extern CGLContextObj cgl_ctx; // defined in view

@implementation TextureWrapper

+ (id)textureWithImage:(CIImage *)value cntx:(CIContext *)cntx
{
	return [[[self alloc] initTextureWithImage:value cntx:cntx ] autorelease];
}

- (id)initTextureWithImage:(CIImage *)value cntx:(CIContext *)cntx
{
    if ((self = [super init]) != nil) 
	{
		_fbo=-1;
		_textureName-1;
		CGRect bounds = [value extent];
		_width = bounds.size.width;
		_height = bounds.size.height;
		[self makeTextureWithImage:value cntx:cntx];
	}
	return self;	
}

- (void)makeTextureWithImage:(CIImage *)value cntx:(CIContext *)cntx
{
	/* make a rectangular 2d texture with no depthbuffer */
	GLint currentFB;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &currentFB); // save current framebuffer
	CGRect imageRect = [value extent];
	glPixelStorei(GL_UNPACK_ROW_LENGTH, imageRect.size.width);

	if(_textureName!=-1)
		[self destroyTexture];
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glGenFramebuffersEXT(1, &_fbo);																		// create a handle to FBO
	glGenTextures(1, &_textureName);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _fbo);														// make this the current FBO
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _textureName);

	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8,  _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE); 
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE); // Specify that we will retain storage for textures so opengl doent need to make a copy
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_EXT, _textureName, 0);
	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if (status != GL_FRAMEBUFFER_COMPLETE_EXT)
		printf("Error, FBO status %04x\n", (int)status);
	
	glViewport( 0, 0, _width, _height);
	glScissor( 0, 0, _width, _height); // this needs to be in window co-ords i think
	
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA  );
	
	[cntx drawImage:value inRect:CGRectMake(0, 0, _width, _height) fromRect:imageRect];
		
	//	-- restore entry framebuffer --
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, currentFB);
}

- (void)dealloc
{
	[self destroyTexture];
	[super dealloc];
}


- (void)destroyTexture
{
	if(_fbo!=-1){
		glDeleteFramebuffersEXT(1, &_fbo);
		glDeleteTextures(1, &_textureName);
		_textureName = -1;
		_fbo = -1;
	}
}

- (void)apply
{
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _textureName);
}

- (GLuint)width
{
	return _width;
}

- (GLuint)height
{
	return _height;
}

@end
