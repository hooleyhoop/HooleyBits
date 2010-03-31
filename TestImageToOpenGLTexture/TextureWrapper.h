//
//  TextureWrapper.h
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/CGLMacro.h>


@interface TextureWrapper : NSObject {

	GLuint					_textureName;
	GLuint					_fbo;
	GLuint					_width, _height;

}


+ (id)textureWithImage:(CIImage *)value cntx:(CIContext *)cntx;

- (id)initTextureWithImage:(CIImage *)value cntx:(CIContext *)cntx;

- (void)makeTextureWithImage:(CIImage *)value cntx:(CIContext *)cntx;
- (void)destroyTexture;

- (void)apply;

- (GLuint)width;
- (GLuint)height;
@end
