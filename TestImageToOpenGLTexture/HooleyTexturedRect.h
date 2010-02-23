//
//  HooleyTexturedRect.h
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TextureWrapper;

@interface HooleyTexturedRect : NSObject {

	TextureWrapper* txtr;
    int		_displayListId;
	double _alpha;	
	double _width;
	double _height;
	int _txtWidth;
	int _txtHeight;
	
	NSPoint		_anchorPoint;
    NSPoint		_rotation;
    NSPoint		_translation;
    NSPoint		_scaling;
}

+ (id)rectWithTexture:(TextureWrapper *)openglTexture;
- (id)initWithTexture:(TextureWrapper *)openglTexture;

- (void)buildQuadWithWidth:(double)aWidth height:(double)aHeight textureWidth:(int)pixelWidth textureHeight:(int)pixelHeight;

- (void)startDisplayList;
- (void)stopDisplayList;
- (void)destroyDisplayList;

- (void)draw;

- (TextureWrapper *)txtr;
- (void)setTxtr:(TextureWrapper *)newTxtr;


@end
