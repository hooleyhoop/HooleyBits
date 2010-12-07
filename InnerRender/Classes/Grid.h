//
//  Grid.h
//  InnerRender
//
//  Created by Steven Hooley on 06/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface Grid : NSObject {
@private
 
	NSUInteger _gridsize, _width, _height;
}

- (void)drawInContext:(CGContextRef)windowContext;

@end
