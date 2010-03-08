//
//  DebugView.m
//  TypeSetter
//
//  Created by steve hooley on 11/03/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "DebugView.h"


@implementation DebugView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setNeedsDisplay:YES];
    }
    return self;
}

// highest-level = framesetter. The framesetter object uses other Core Text objects, such as typesetter, line, and glyph run objects, to accomplish its work: creating frame objects, which are lines of glyphs laid out within a shape.
// Clients who need to intervene in the text layout process at a lower level can deal with lower level objects, such as line objects. Line objects can draw themselves individually or be used to obtain glyph information
// NSAttributedString = CFAttributedStringRef
// framesetter output is a frame object containing an array of lines. The frame can draw itself directly into a graphic context. 
// A typesetter performs the fundamental text layout operations of character-to-glyph conversion and positioning of those glyphs into lines.
// A line object contains glyph-run objects.
// A glyph run is a set of consecutive glyphs sharing the same attributes and direction. Glyph runs can draw themselves into a graphic context,
// NSFont = CTFontRef
// NSFontDescriptor = CTFontDescriptorRef

//CGFont has CGFontGetGlyphBBoxes and CGFontGetGlyphAdvances
//
//i need a very Specific idea here!
CGImageRef _createPNGWithURL( CFURLRef URL ) {
	
	CGDataProviderRef src = CGDataProviderCreateWithURL(URL);
	CGImageRef image = CGImageCreateWithPNGDataProvider(src, nil, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(src);
	return image;
}

- (void)drawRect:(NSRect)rect {

	[[NSColor blueColor] set];
	NSRectFill(rect);
	
	// Initialize a graphics context and set the text matrix to a known value.
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]  graphicsPort];
	
	/* 
	 * Use Core Text to draw some strings 
	 */
	CGContextSetTextMatrix( context, CGAffineTransformIdentity );
	
	// Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake( 10.0, 10.0, 200.0, 200.0);
	CGPathAddRect(path, NULL, bounds);
	
	// Initialize an attributed string.
	CFStringRef string = CFSTR("We hold this truth to be self-evident, that  everyone is created equal.");
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), string);
	
	// Create a color and add it as an attribute to the string.
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = { 1.0, 0.0, 0.0, 0.8 };
	CGColorRef red = CGColorCreate(rgbColorSpace, components);
	CGColorSpaceRelease(rgbColorSpace);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 50), kCTForegroundColorAttributeName, red);
	
	// Create the framesetter with the attributed string.
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CFRelease(attrString);
	
	// Create the frame and draw it into the graphics context
	CTFrameRef frame = CTFramesetterCreateFrame( framesetter, CFRangeMake(0, 0), path, NULL);
	CFRelease(framesetter);
	CTFrameDraw(frame, context);
	CFRelease(frame);
	
	/* 
	 * Just try drawing a normal image
	 *
	 */
	NSString *testImagePath = [[NSBundle mainBundle] pathForResource:@"Picture 4" ofType:@"png"];
	NSURL *testImageURL = [NSURL fileURLWithPath:testImagePath];
	CGImageRef testImage = _createPNGWithURL( (CFURLRef)testImageURL );
	NSAssert( testImage, @"cant find test image in bundle");
	
	CGContextSaveGState( context );
	CGContextDrawImage( context, CGRectMake( 0, 0, CGImageGetWidth(testImage), CGImageGetHeight(testImage)), testImage );
	CGContextRestoreGState( context );
	
	CGImageRelease( testImage );
	
	/* 
	 * Draw a glyph image
	*/
	
}

- (void)fontMetrics {
	
}

CGFloat GetLineHeightForFont( CTFontRef iFont ) {

    CGFloat lineHeight = 0.0;
	
    check(iFont != NULL);
	
    // Get the ascent from the font, already scaled for the font's size
    lineHeight += CTFontGetAscent(iFont);
	
    // Get the descent from the font, already scaled for the font's size
    lineHeight += CTFontGetDescent(iFont);
	
    // Get the leading from the font, already scaled for the font's size
    lineHeight += CTFontGetLeading(iFont);
	
    return lineHeight;
}

void GetGlyphsForCharacters( CTFontRef iFont, CFStringRef iString )
{
    UniChar *characters;
    CGGlyph *glyphs;
    CFIndex count;
	
    assert(iFont != NULL && iString != NULL);
	
    // Get our string length.
    count = CFStringGetLength(iString);
	
    // Allocate our buffers for characters and glyphs.
    characters = (UniChar *)malloc(sizeof(UniChar) * count);
    assert(characters != NULL);
	
    glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert(glyphs != NULL);
	
    // Get the characters from the string.
    CFStringGetCharacters(iString, CFRangeMake(0, count), characters);
	
    // Get the glyphs for the characters.
    CTFontGetGlyphsForCharacters(iFont, characters, glyphs, count);
	
    // Do something with the glyphs here, if a character is unmapped
	
    // Free our buffers
	free(characters);
	free(glyphs);
}

CTFontDescriptorRef CreateFontDescriptorFromName(CFStringRef iPostScriptName,
												 CGFloat iSize)
{
    assert(iPostScriptName != NULL);
    return CTFontDescriptorCreateWithNameAndSize(iPostScriptName, iSize);
}

CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits( CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize ) {
	
    CTFontDescriptorRef descriptor = NULL;
    CFMutableDictionaryRef attributes;
	
    assert(iFamilyName != NULL);
    // Create a mutable dictionary to hold our attributes.
    attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
										   &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    check(attributes != NULL);
	
    if (attributes != NULL) {
        CFMutableDictionaryRef traits;
        CFNumberRef symTraits;
		
        // Add a family name to our attributes.
        CFDictionaryAddValue(attributes, kCTFontFamilyNameAttribute, iFamilyName);
		
        // Create the traits dictionary.
        symTraits = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type,
								   &iTraits);
        check(symTraits != NULL);
		
        if (symTraits != NULL) {
            // Create a dictionary to hold our traits values.
            traits = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
											   &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            check(traits != NULL);
			
            if (traits != NULL) {
                // Add the symbolic traits value to the traits dictionary.
                CFDictionaryAddValue(traits, kCTFontSymbolicTrait, symTraits);
				
                // Add the traits attribute to our attributes.
                CFDictionaryAddValue(attributes, kCTFontTraitsAttribute, traits);
                CFRelease(traits);
            }
            CFRelease(symTraits);
        }
        // Create the font descriptor with our attributes and input size.
        descriptor = CTFontDescriptorCreateWithAttributes(attributes);
        check(descriptor != NULL);
		
        CFRelease(attributes);
    }
    // Return our font descriptor.
    return descriptor;
}

CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize)
{
    check(iFontDescriptor != NULL);
	
    // Create the font from the font descriptor and input size. Pass
    // NULL for the matrix parameter to use the default matrix (identity).
	
    return CTFontCreateWithFontDescriptor(iFontDescriptor, iSize, NULL);
}

CTFontRef CreateBoldFont(CTFontRef iFont, Boolean iMakeBold)
{
    CTFontSymbolicTraits desiredTrait = 0;
    CTFontSymbolicTraits traitMask;
	
    // If we are trying to make the font bold, set the desired trait
    // to be bold.
    if (iMakeBold)
        desiredTrait = kCTFontBoldTrait;
	
    // Mask off the bold trait to indicate that it is the only trait
    // desired to be modified. As CTFontSymbolicTraits is a bit field,
    // we could choose to change multiple traits if we desired.
    traitMask = kCTFontBoldTrait;
	
    // Create a copy of the original font with the masked trait set to the
    // desired value. If the font family does not have the appropriate style,
    // this will return NULL.
	
    return CTFontCreateCopyWithSymbolicTraits(iFont, 0.0, NULL, desiredTrait, traitMask);
}

CTFontRef CreateFontConvertedToFamily(CTFontRef iFont, CFStringRef iFamily)
{
    // Create a copy of the original font with the new family. This call
    // attempts to preserve traits, and may return NULL if that is not possible.
    // Pass in 0.0 and NULL for size and matrix to preserve the values from
    // the original font.
	
    return CTFontCreateCopyWithFamily(iFont, 0.0, NULL, iFamily);
}

@end
