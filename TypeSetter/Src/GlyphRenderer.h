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

- (void)randomFont_drawNonOverlappingGlphs:(NSString *)iString inContext:(CGContextRef)windowContext;

- (void)drawNonOverlappingGlphs:(NSString *)str inContext:(CGContextRef)context;

- (void)drawWithSuggestedAdvance:(NSString *)fontName text:(NSString *)textToDraw inContext:(CGContextRef)windowContext;
- (void)useCoreText:(NSString *)fontName text:(NSString *)iString inContext:(CGContextRef)windowContext;

- (void)testOverlapDrawing:(CGContextRef)context;
- (void)renderAString:(CGContextRef)context;

- (CGImageRef)glyphImage;


@end
