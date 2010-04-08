//
//  GlyphRenderer.h
//  TypeSetter
//
//  Created by steve hooley on 08/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GlyphRenderer : NSObject {

}

/*
 * Two unrelated tests
 *
*/
- (void)testOverlapDrawing:(CGContextRef)context;
- (void)renderAString:(CGContextRef)context;

- (CGImageRef)glyphImage;

@end
