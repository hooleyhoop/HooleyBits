//
//  AppControl.h
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OpenGLView;

#define glError() { \
	GLenum err = glGetError(); \
		while (err != GL_NO_ERROR) { \
			printf("glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
				err = glGetError(); \
		} \
}

@interface AppControl : NSObject {

	IBOutlet OpenGLView	*simpleView;
}

- (OpenGLView *)simpleView;
- (void)setSimpleView:(OpenGLView *)value;


@end
