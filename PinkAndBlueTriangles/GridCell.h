//
//  SqFloorPatch.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


@interface GridCell : NSObject {

//	int width, height, columns, rows;
	
	NSColor* fillColour;
	float _red, _green, _blue;
	BOOL _visible;
}

#pragma mark action methods

- (id)initWithColourR:(float)r g:(float)g b:(float)b;

- (void)drawAtPoint:(NSPoint)p cellSize:(int)size;
- (void)useAtPoint:(NSPoint)p cellSize:(int)size row:(int)r col:(int)c;

- (void)setRed:(float)r;
- (void)setGreen:(float)g;
- (void)setBlue:(float)b;

- (BOOL)visible;
- (void)setVisible:(BOOL)value;

- (void)renderCrapGLText:(NSString *)text at:(NSPoint)point;

@end
