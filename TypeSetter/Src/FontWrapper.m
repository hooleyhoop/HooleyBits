//
//  FontWrapper.m
//  TypeSetter
//
//  Created by Steven Hooley on 31/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FontWrapper.h"


@implementation FontWrapper

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

- (NSString *)randomFontName {
	
	static NSArray *allFonts;
	if(!allFonts)
		allFonts = [[NSFontManager sharedFontManager] availableFonts];
	NSUInteger fontCount = [allFonts count];
	NSUInteger randomFontIndex = rand()%fontCount;
	
	//	for(id each in allFonts){
	//		NSLog(@"%@", each);
	//	}
	return [allFonts objectAtIndex:randomFontIndex];
}

- (void)getRandomFont:(CTFontRef *)iFont {
	
	NSString *fontName = [self randomFontName];
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)fontName, 72.0f );
	assert( fdesc!=NULL );
	//	CGFontRef cgFont = CGFontCreateWithFontName( (CFStringRef)fontName );
	
	
	*iFont = CreateFont( fdesc, 72.0f );
	assert( iFont!=NULL);
	
	CFRelease(fdesc);
	//	CFRelease(cgFont);
}

CGFloat GetLineHeightForFont( CTFontRef iFont ) {
	
    CGFloat lineHeight = 0.0f;
	
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
    attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
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
            traits = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
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
	
    return CTFontCreateCopyWithSymbolicTraits(iFont, 0.0f, NULL, desiredTrait, traitMask);
}

CTFontRef CreateFontConvertedToFamily(CTFontRef iFont, CFStringRef iFamily)
{
    // Create a copy of the original font with the new family. This call
    // attempts to preserve traits, and may return NULL if that is not possible.
    // Pass in 0.0 and NULL for size and matrix to preserve the values from
    // the original font.
	
    return CTFontCreateCopyWithFamily(iFont, 0.0f, NULL, iFamily);
}

- (void)inspectFont:(NSString *)fontName glyph:(NSString *)iString size:(CGFloat)size {
	
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)fontName, size );
	CTFontRef iFont = CreateFont( fdesc, size );
	assert(iFont != NULL && iString != NULL);
    NSUInteger count = [iString length];
	UniChar *characters = (UniChar *)malloc(sizeof(UniChar) * count);
	CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert( characters != NULL );
    assert(glyphs != NULL);
    CFStringGetCharacters( (CFStringRef)iString, CFRangeMake(0, count), characters );
	CTFontGetGlyphsForCharacters( iFont, characters, glyphs, count );
	
	CGGlyph glyph1 = glyphs[0];
	CGGlyph glyph2 = glyphs[1];
	
	CGPathRef glyphPath1 = CTFontCreatePathForGlyph( iFont, glyph1, NULL );
	CGPathRef glyphPath2 = CTFontCreatePathForGlyph( iFont, glyph2, NULL );
	
	CGRect boundingRects[2];
	CGSize advances[2];
	CGRect glyph1BoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, &glyph1, boundingRects, count ); // -0.72, 0 <> 25.692, 25.29
	double advance = CTFontGetAdvancesForGlyphs( iFont, kCTFontDefaultOrientation, &glyph1, advances, count );	// 24.1523
	CGSize advance0 = advances[0]; // 60.7
	CGSize advance1 = advances[1]; //23.99
	free(characters);
	free(glyphs);
	CFRelease(fdesc);
	CFRelease(iFont);
}


@end
