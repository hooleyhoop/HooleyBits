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
	@public
		CGGlyph *_glyphs;
		NSUInteger _count;
}
@property NSUInteger count;

+ (GlyphHolder *)glyphsForCharacters:(NSString *)iString ofFont:(CTFontRef)iFont;
- (id)initWithCount:(NSUInteger)c;
- (CGGlyph)glyphAtIndex:(NSUInteger)gi;

@end

@implementation GlyphHolder

@synthesize count = _count;

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
		_count = c;
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
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"HiraMinPro-W3", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
	
	CFCharacterSetRef charSet = CTFontCopyCharacterSet(iFont );
	NSData *charsetBitmap = [(NSCharacterSet *)charSet bitmapRepresentation];
	unsigned char *restrict bitmapRep  = (unsigned char *)[charsetBitmap bytes];
	
	NSUInteger myGlyphCount = 0;
	NSUInteger byteCount = [charsetBitmap length];
	NSUInteger bitCount = byteCount*8;
	
	const UTF32Char LEAD_OFFSET = 0xD800 - (0x10000 >> 10);
	const UTF32Char SURROGATE_OFFSET = 0x10000 - (0xD800 << 10) - 0xDC00;

	unsigned char mask_table[] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };
	unsigned char testByte = 3;
	
	unsigned char bit_0 = ( testByte & mask_table[ 0 ] )!= 0x00;
	unsigned char bit_1 = ( testByte & mask_table[ 1 ] )!= 0x00;
	unsigned char bit_2 = ( testByte & mask_table[ 2 ] )!= 0x00;
	unsigned char bit_3 = ( testByte & mask_table[ 3 ] )!= 0x00;
	unsigned char bit_4 = ( testByte & mask_table[ 4 ] )!= 0x00;
	unsigned char bit_5 = ( testByte & mask_table[ 5 ] )!= 0x00;
	unsigned char bit_6 = ( testByte & mask_table[ 6 ] )!= 0x00;
	unsigned char bit_7 = ( testByte & mask_table[ 7 ] )!= 0x00;
	
	unsigned char bbit_0 = ( testByte & (((unsigned int)1) << (0  & 7)) );
	unsigned char bbit_1 = ( testByte & (((unsigned int)1) << (1  & 7)) );
	unsigned char bbit_2 = ( testByte & (((unsigned int)1) << (2  & 7)) );
	unsigned char bbit_3 = ( testByte & (((unsigned int)1) << (3  & 7)) );
	unsigned char bbit_4 = ( testByte & (((unsigned int)1) << (4  & 7)) );
	unsigned char bbit_5 = ( testByte & (((unsigned int)1) << (5  & 7)) );
	unsigned char bbit_6 = ( testByte & (((unsigned int)1) << (6  & 7)) );
	unsigned char bbit_7 = ( testByte & (((unsigned int)1) << (7  & 7)) );
	
	// new muthafucking way
	NSUInteger codept = 0; 
	for( NSUInteger n=0; n<byteCount; n++ )
	{
		unsigned char theByte = bitmapRep[n];
		for( NSUInteger j=0; j<8; j++ ){
			BOOL bbit = ( theByte & (((unsigned int)1) << (j  & 7)) );
			UTF32Char codePt = (n << 3) + j;
			UTF16Char lead = LEAD_OFFSET + (codePt >> 10);
			UTF16Char trail = 0xDC00 + (codePt & 0x3FF);
			if(bbit){
				if(codePt>65535)
				{
					UniChar characters[2];
					CGGlyph glyphs[2];
					characters[0] = lead;
					characters[1] = trail;	
					Boolean gotGlyphs = CTFontGetGlyphsForCharacters( iFont, characters, glyphs, 1 );
					CGGlyph glyph1 = glyphs[0];
					CGGlyph glyph2 = glyphs[1];
					if(!gotGlyphs){
						NSString *utf32String = [NSString stringWithUTF32Characters:&codePt length:1];
						CFIndex count = CFStringGetLength((CFStringRef)utf32String);
						UniChar *characters = (UniChar *)malloc(sizeof(UniChar) * count);
						CFStringGetCharacters( (CFStringRef)utf32String, CFRangeMake(0, count), characters );
						Boolean gotGlyphs = CTFontGetGlyphsForCharacters( iFont, characters, glyphs, count );
						free(characters);
						NSLog( @"ERROR! no glyph at %i", codePt );
					}
				}
				
			} else {
				if(codePt>65535)
				{
					UniChar characters[2];
					CGGlyph glyphs[2];
					characters[0] = lead;
					characters[1] = trail;
					Boolean gotGlyphs = CTFontGetGlyphsForCharacters( iFont, characters, glyphs, 2 );
					
			//		CFStringGetSurrogatePairForLongCharacter
					
					if(gotGlyphs){
						NSLog( @"ERROR! unexpected glyph at %i", codePt );
					}
				}
			}
			codept++;
		}
	}
	
	// 16 bit overflows at MAX 65535
	for( NSUInteger n=65536; n<bitCount; n++ )
	{
		UTF16Char lead = LEAD_OFFSET + (n >> 10);
		UTF16Char trail = 0xDC00 + (n & 0x3FF);
		UTF32Char codepoint = (lead << 10) + trail + SURROGATE_OFFSET;		

		if( bitmapRep[n >> 3] & (((unsigned int)1) << (n  & 7)) ) {
			/* Character is present. */
			myGlyphCount++;
			
			UniChar characters[2];
			CGGlyph glyphs[2];
			
			if(codepoint!=n)
				NSLog(@"what?");
	
			characters[0] = codepoint;
			//characters[1] = trail;

			Boolean gotGlyphs = CTFontGetGlyphsForCharacters( iFont, characters, glyphs, 1 );
			if(!gotGlyphs){
				NSLog( @"ERROR! no glyph at %i", codepoint );
			}
		} else {
			/* Character not present */
			UniChar characters[2];
			CGGlyph glyphs[2];
			characters[0] = codepoint;
			Boolean gotGlyphs = CTFontGetGlyphsForCharacters( iFont, characters, glyphs, 2 );
			if(gotGlyphs){
				NSLog( @"ERROR! got unknon glyph %i", codepoint );
			}
		}
	}
	CFRelease(charSet);
	
	
	NSArray *availableFontTables = (NSArray *)CTFontCopyAvailableTables( iFont, kCTFontTableOptionNoOptions );
	for( CFIndex i=0; i<(CFIndex)[availableFontTables count] ; i++ ){
		CTFontTableTag tableTag = (CTFontTableTag)(uintptr_t)CFArrayGetValueAtIndex((CFArrayRef)availableFontTables, i);
		CFDataRef fontTable = CTFontCopyTable( iFont, tableTag, kCTFontTableOptionNoOptions );
	//	NSLog(@"%@", fontTable);
		CFRelease( fontTable );
	} 
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
	
	// Draw some metrics
	CGFloat fontAscent = CTFontGetAscent( iFont );				//55
	CGRect fontBoundingBox = CTFontGetBoundingBox( iFont );		//-68, -34, 172, 115
	CGRect glyphBoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, theGlyphs->_glyphs, NULL, theGlyphs.count ); // 5, 0, 49, 51
	CGFloat fontCapHeight = CTFontGetCapHeight( iFont);			//52.5
	CGFloat fontDescent = CTFontGetDescent( iFont );			//16
	CGFloat fontXHeight = CTFontGetXHeight( iFont );			//38
	CFIndex glyphCount = CTFontGetGlyphCount( iFont );	//20584
	
	// xheight
	CGContextBeginPath( context );
	CGContextMoveToPoint( context, 0.0f, fontXHeight );
	CGContextAddLineToPoint( context, 200.0f, fontXHeight );
	CGContextDrawPath( context, kCGPathStroke );

	// fontDescent
	CGContextBeginPath( context );
	CGContextMoveToPoint( context, 0.0f, fontAscent );
	CGContextAddLineToPoint( context, 200.0f, fontAscent );
	CGContextDrawPath( context, kCGPathStroke );
	
	// draw the glyph's path
	CGContextScaleCTM( context, (200.0f / glyphBoundingBox.size.width)*0.99f, (200.0f / glyphBoundingBox.size.height)*0.99f );
	CGContextTranslateCTM( context, -glyphBoundingBox.origin.x, -glyphBoundingBox.origin.y );
	
	CGContextSetAllowsAntialiasing( context, true );
	CGContextSetInterpolationQuality( context, kCGInterpolationNone );
	
	CGContextBeginPath( context );
	CGContextAddPath( context, glyphPath );
	CGContextSetRGBFillColor( context, 0.0f, 0.0f, 0.0f, 1.0f );
	CGContextFillPath( context );
	
	// get image from the context
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


@end