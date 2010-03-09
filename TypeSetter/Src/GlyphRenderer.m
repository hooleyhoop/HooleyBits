//
//  GlyphRenderer.m
//  TypeSetter
//
//  Created by steve hooley on 08/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "GlyphRenderer.h"

#pragma mark -
#pragma mark GlyphHolder
@interface GlyphHolder : NSObject {
	CGGlyph *_glyphs;
}
+ (GlyphHolder *)glyphsForCharacters:(NSString *)iString ofFont:(CTFontRef)iFont;
- (id)initWithCount:(NSUInteger)c;
- (CGGlyph)glyphAtIndex:(NSUInteger)gi;

@end

@implementation GlyphHolder

+ (GlyphHolder *)glyphsForCharacters:(NSString *)iString ofFont:(CTFontRef)iFont {
	
    UniChar *characters;
    CFIndex count;
	
    assert(iFont != NULL && iString != NULL);
	
    // Get our string length.
    count = CFStringGetLength((CFStringRef)iString);
	
    // Allocate our buffers for characters and glyphs.
    characters = (UniChar *)malloc(sizeof(UniChar) * count);
    assert(characters != NULL);
	
    // Get the characters from the string.
    CFStringGetCharacters( (CFStringRef)iString, CFRangeMake(0, count), characters );
	
    // Get the glyphs for the characters.
	GlyphHolder *theGlyphs = [[[GlyphHolder alloc] initWithCount: count] autorelease];
	
    CTFontGetGlyphsForCharacters( iFont, characters, theGlyphs->_glyphs, count );
	
    // Do something with the glyphs here, if a character is unmapped
	
    // Free our buffers
	free(characters);
	
	return theGlyphs;
}

- (id)initWithCount:(NSUInteger)c {

	self = [super init];
	if( self ) {
		_glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * c);
		assert( _glyphs != NULL );
	}
	return self;
}

- (void)dealloc {

	free(_glyphs);
	[super dealloc];
}

- (CGGlyph)glyphAtIndex:(NSUInteger)gi {
	return _glyphs[gi];
}

@end

#pragma mark -
#pragma mark GlyphRenderer
@implementation GlyphRenderer

CTFontRef CreateFont( CTFontDescriptorRef iFontDescriptor, CGFloat iSize ) {
    check( iFontDescriptor != NULL );
	
    // Create the font from the font descriptor and input size. Pass
    // NULL for the matrix parameter to use the default matrix (identity).
	
    return CTFontCreateWithFontDescriptor( iFontDescriptor, iSize, NULL );
}

CTFontDescriptorRef CreateFontDescriptorFromName( CFStringRef iPostScriptName, CGFloat iSize ) {

    assert(iPostScriptName != NULL);
    return CTFontDescriptorCreateWithNameAndSize( iPostScriptName, iSize );
}

- (CGImageRef)glyphImage {
	
	// get the path
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"Helvetica", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
	
	GlyphHolder *theGlyphs = [GlyphHolder glyphsForCharacters:@"M" ofFont:iFont];
	
	CGPathRef glyphPath = CTFontCreatePathForGlyph(  iFont, [theGlyphs glyphAtIndex:0],  NULL );
	
	// create an image
	size_t width = 200;
	size_t height = 200;
	size_t bitsPerComponent = 8;
	size_t componentsPerPixel = 1;
	size_t bitsPerPixel = bitsPerComponent * componentsPerPixel;
	size_t bytesPerRow = (width * bitsPerPixel + 7)/8;
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericGray );
	CGBitmapInfo bitmapInfo = kCGImageAlphaNone;
	
	size_t dataLength = bytesPerRow * height;
	UInt32 *restrict bitmap = malloc( dataLength );
	memset( bitmap, 255, dataLength );
	
	/*
	 * TODO:
	 * An alternate way to do this is to pass NULL instead of bitmap (auto memory management) and the CGBitmapContextCreateImage() to make a copy of the back buffer. Profile this?
	*/
	CGContextRef context = CGBitmapContextCreate( bitmap, width, height, bitsPerComponent, bytesPerRow, colorspace, bitmapInfo );
	
	// draw the path
	CGContextBeginPath( context );
	CGContextAddPath( context, glyphPath );
	CGContextSetRGBFillColor( context, 0.0f, 0.0f, 0.0f, 1.0f );
	CGContextFillPath( context );

	CGDataProviderRef dataProvider = CGDataProviderCreateWithData( NULL, bitmap, dataLength, NULL);
	CGImageRef cgImage = CGImageCreate( width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorspace, bitmapInfo, dataProvider, NULL, false, kCGRenderingIntentDefault );
	
	CGDataProviderRelease(dataProvider);
	CGColorSpaceRelease(colorspace);
	CGContextRelease(context);
	CGPathRelease(glyphPath);
	CFRelease(fdesc);
	CFRelease(iFont);
	
	// TODO: free the image and the bitmap
//	free(bitmap);
	return cgImage;
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
