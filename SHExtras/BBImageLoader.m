//
//  Unsafe Image Loader.m
//  BBExtras
//
//  Created by Jonathan del Strother on 01/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "BBImageLoader.h"
#import <OpenGL/gl.h>

@implementation BBImageLoader

-(void)dealloc
{
	[priorURL release];
	[super dealloc];
}

- (BOOL)execute:(QCOpenGLContext*)context time:(double)fp12 arguments:(id)fp20
{
	if (![priorURL isEqualToString:[inputURL stringValue]])		//Whenever the URL updates, override super's functionality and start the image downloading ourselves.  Otherwise, super will prevent network downloading in Quicktime.
	{
		[priorURL release];
		priorURL = [[inputURL stringValue] retain];
		
		[_imageURL release];
		_imageURL = [[NSURL URLWithString:priorURL] retain];
		
		int maxTextureSize = [QCOpenGLContext maxSupportedTextureSizeForTarget:GL_TEXTURE_RECTANGLE_ARB];
		
		NSDictionary* imageProps = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:maxTextureSize], @"cgImageMaxHeight",
			[NSNumber numberWithInt:maxTextureSize], @"cgImageMaxWidth",
			[NSNumber numberWithInt:GL_TEXTURE_RECTANGLE_ARB], @"textureTarget", 
			@"proportionally", @"cgImageScalingMode", nil];
			 
		[self runThreadWithSelector:@selector(_imageThread:) argument:imageProps];
	}
	else
	{
		[super execute:context time:fp12 arguments:fp20];
	}
	return YES;
}

@end
