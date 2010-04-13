//
//  GlyphRenderer.m
//  TypeSetter
//
//  Created by steve hooley on 08/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "GlyphRenderer.h"

static CGPoint alignPointToUserSpace( CGContextRef context, CGPoint pt ) {

	pt = CGContextConvertPointToDeviceSpace(context, pt);
	// ensure that it is corner of device pixel
	pt.x = floor(pt.x);
	pt.y = floor(pt.y);
	return CGContextConvertPointToUserSpace(context, pt);
}

static CGSize alignSizeToUserSpace( CGContextRef context, CGSize siz ) {
	
	siz = CGContextConvertSizeToDeviceSpace(context, siz);
	// ensure that it is corner of device pixel
	siz.width = floor(siz.width);
	siz.height = floor(siz.height);
	return CGContextConvertSizeToUserSpace(context, siz);
}

static CGRect alignRectToUserSpace( CGContextRef context, CGRect rec ) {
	
	rec = CGContextConvertRectToDeviceSpace(context, rec);
	// ensure that it is corner of device pixel
	rec.origin.x = floor(rec.origin.x);
	rec.origin.y = floor(rec.origin.y);
	rec.size.width = floor(rec.size.width);
	rec.size.height = floor(rec.size.height);
	return CGContextConvertRectToUserSpace(context, rec);
}

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

- (void)drawNonOverlappingGlphs:(NSString *)iString inContext:(CGContextRef)windowContext {
	
	NSParameterAssert(iString);
	NSParameterAssert(windowContext);

	// get font and string
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"Times-Bold", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
    assert(iFont != NULL && iString != NULL);
	
    // Get our string length.
    NSUInteger count = [iString length];
	
    // Allocate our buffers for characters and glyphs.
	UniChar *characters = (UniChar *)malloc(sizeof(UniChar) * count);
	CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert( characters != NULL );
    assert( glyphs != NULL );
	
    // Get the characters from the string.
    CFStringGetCharacters( (CFStringRef)iString, CFRangeMake(0, count), characters );
	CTFontGetGlyphsForCharacters( iFont, characters, glyphs, count );
	
	CGFloat targetHeight = 400.f;
	CGRect fontBoundsBox = CTFontGetBoundingBox( iFont ); // -- need the descender and every fucking thing! grrrr!

	CGFloat fontHeight = fontBoundsBox.size.height; // 122.554688
	CGFloat glyphScale = targetHeight / fontHeight; // 3.26384902
	if( glyphScale<1.0f )
		glyphScale = 1.0f;
	
	CGFloat pixelWidth = 1.0f/glyphScale;

	CGFloat scaledFontHeight = ceilf( glyphScale * fontHeight);

	// prepare context
	CGContextSetAllowsAntialiasing( windowContext, true );
	CGContextSetInterpolationQuality( windowContext, kCGInterpolationNone );
	
	CGColorRef rectCol = CGColorCreateGenericRGB( 0.3f, 0.3f, 1.0f, 0.5f );
	CGColorRef redCol = CGColorCreateGenericRGB( 1.0f, 0.0f, 0.0f, 1.0f );
	CGColorRef greenCol = CGColorCreateGenericRGB( 0.0f, 1.0f, 0.0f, 1.0f );
	CGColorRef blackCol = CGColorCreateGenericRGB( 0.0f, 0.0f, 0.0f, 1.0f );
	
	CGContextScaleCTM( windowContext, glyphScale, glyphScale );

	// need black background!
	CGContextSetFillColorWithColor( windowContext, blackCol );
	CGContextFillRect( windowContext, CGRectMake(0.0f,0.0f,1000.0f, 1000.0f));
	
	CGPoint startPos = alignPointToUserSpace( windowContext, CGPointMake( 0, -fontBoundsBox.origin.y ) );
	CGContextTranslateCTM( windowContext, startPos.x, startPos.y );	
	
	// draw each glyph
	for( NSUInteger glyphIndex=0; glyphIndex<count; glyphIndex++ ) {
		
		CGGlyph glyphToPaint = glyphs[glyphIndex];
		CGRect glyphToPaintBoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, &glyphToPaint, NULL, 1 );
		CGPathRef glyphToPaint_path = CTFontCreatePathForGlyph( iFont, glyphToPaint, NULL );
		
		// translate bounding box (rect comprising font height and glyph width) to zero - of course everything is now scaled, no need to compensate
		CGPoint originPos = alignPointToUserSpace( windowContext, CGPointMake( -glyphToPaintBoundingBox.origin.x, 0 ) );
		CGContextTranslateCTM( windowContext, originPos.x, originPos.y );	

		// draw glyph body
		CGContextAddRect( windowContext,  CGRectMake( glyphToPaintBoundingBox.origin.x, fontBoundsBox.origin.y, glyphToPaintBoundingBox.size.width, fontBoundsBox.size.height ) );
		CGContextSetFillColorWithColor( windowContext, rectCol );
//		CGContextFillPath( windowContext );		
		
		// draw glyph1 bounding box
//		CGContextAddRect( windowContext, glyphToPaintBoundingBox );
//		CGContextSetFillColorWithColor( windowContext, rectCol );
//		CGContextFillPath( windowContext );		
		
		// draw glyph1
		CGContextAddPath( windowContext, glyphToPaint_path );
		CGContextSetFillColorWithColor( windowContext, redCol );
		CGContextFillPath( windowContext );		
		
		// TODO: This makes no sense..
		originPos = alignPointToUserSpace( windowContext, CGPointMake( glyphToPaintBoundingBox.size.width + pixelWidth*1.1, 0 ) );
		CGContextTranslateCTM( windowContext, originPos.x, originPos.y );
		
		// hmm - no overlap!
		CGContextTranslateCTM( windowContext, glyphToPaintBoundingBox.origin.x, 0 );
		
		CGPathRelease(glyphToPaint_path);
	}
		
	CGColorRelease(blackCol);
	CGColorRelease(greenCol);
	CGColorRelease(redCol);
	CGColorRelease(rectCol);

	free(characters);
	free(glyphs);
	CFRelease(fdesc);
	CFRelease(iFont);
}

	

- (void)testOverlapDrawing:(CGContextRef)windowContext {

	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"Times-Bold", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
	NSString *iString = @"Aj";
   assert(iFont != NULL && iString != NULL);
	
    // Get our string length.
    NSUInteger count = [iString length];
	
    // Allocate our buffers for characters and glyphs.
	UniChar *characters = (UniChar *)malloc(sizeof(UniChar) * count);
	CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert( characters != NULL );
    assert(glyphs != NULL);
	
    // Get the characters from the string.
    CFStringGetCharacters( (CFStringRef)iString, CFRangeMake(0, count), characters );
	CTFontGetGlyphsForCharacters( iFont, characters, glyphs, count );
	CGGlyph glyph1 = glyphs[0];
	CGGlyph glyph2 = glyphs[1];

	CGPathRef glyphPath1 = CTFontCreatePathForGlyph( iFont, glyph1, NULL );
	CGPathRef glyphPath2 = CTFontCreatePathForGlyph( iFont, glyph2, NULL );
	
	// draw glyph 1 - find the rightmost pixel
	//	-- pick the _SCALE_ to test at
	//	-- get a red image of glyph 1 in its bounds
	CGRect glyph1BoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, &glyph1, NULL, 1 ); // 5, 0, 49, 51
	CGRect glyph2BoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, &glyph2, NULL, 1 ); // 5, 0, 49, 51


	//-- what scale is needed to transform xHeight to 200 px
	//-- dont scale down. ie scale >= 1.0f
	CGFloat targetHeight = 400.f;
	CGRect fontBoundsBox = CTFontGetBoundingBox( iFont ); // -- need the descender and every fucking thing! grrrr!s
	CGFloat fontHeight = fontBoundsBox.size.height;
	CGFloat glyphScale = targetHeight / fontHeight;
	if( glyphScale<1.0f )
		glyphScale = 1.0f;
	
	// draw 1 pixel
	CGFloat pixelWidth = 1.0f/glyphScale;
	pixelWidth = pixelWidth - pixelWidth/10.f; //make sure pixel width is slightly less than pixel incase of error
	
	// -- make a new context the size of glyph1 bounds
	//	-- with backing buffer
	CGFloat scaledGlyph1Width = ceilf(glyphScale * glyph1BoundingBox.size.width + 6*pixelWidth );
	CGFloat scaledGlyph1Height = ceilf(glyphScale * fontHeight);
	
	size_t bitsPerComponent = 8;
	size_t componentsPerPixel = 4;
	size_t bitsPerPixel = bitsPerComponent * componentsPerPixel;
	size_t bytesPerRow = ( scaledGlyph1Width * bitsPerPixel + 7)/8;	
	size_t dataLength = bytesPerRow * scaledGlyph1Height;
	UInt32 *restrict bitmap = malloc( dataLength );
	memset( bitmap, 0, dataLength );
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
	CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst;

	CGContextRef hittestContext = CGBitmapContextCreate (
												  bitmap,
												  scaledGlyph1Width, scaledGlyph1Height,
												  bitsPerComponent,
												  bytesPerRow,						// bytes per row
												  colorspace,
												  bitmapInfo
												  );
	
	CGContextSetAllowsAntialiasing( hittestContext, true );
	CGContextSetInterpolationQuality( hittestContext, kCGInterpolationNone );
	
	CGContextScaleCTM( hittestContext, glyphScale, glyphScale );

	CGColorRef rectCol = CGColorCreateGenericRGB( 0.0f, 0.0f, 1.0f, 0.8f );
	CGColorRef redCol = CGColorCreateGenericRGB( 1.0f, 0.0f, 0.0f, 1.0f );
	CGColorRef greenCol = CGColorCreateGenericRGB( 0.0f, 1.0f, 0.0f, 1.0f );
	CGColorRef blackCol = CGColorCreateGenericRGB( 0.0f, 0.0f, 0.0f, 1.0f );
	
	// need black background!
	CGContextSetFillColorWithColor( hittestContext, blackCol );
	CGContextFillRect( hittestContext, CGRectMake(0.0f,0.0f,400.0f,400.0f));
	
	// translate bounding box to zero - of course everything is now scaled, no need to compensate
	CGFloat red_xTranslate = -glyph1BoundingBox.origin.x + pixelWidth;
	CGFloat red_yTranslate = -fontBoundsBox.origin.y;
	CGContextTranslateCTM( hittestContext, red_xTranslate, red_yTranslate );	
	
	// draw glyph1 bounding box
	CGContextAddRect( hittestContext, glyph1BoundingBox );
	CGContextSetFillColorWithColor( hittestContext, rectCol );
	CGContextFillPath( hittestContext );		
	
	// draw glyph1
	CGContextAddPath( hittestContext, glyphPath1 );
	CGContextSetFillColorWithColor( hittestContext, redCol );
	CGContextFillPath( hittestContext );		
	
	// draw glyp 2 - find the leftmost pixel
	//	-- get a green image of glyph 2 in ints bounds
	//	draw image 2 into image 1 using some kind of add mode so that image 2 overlaps at the right edge by 1 pixel
	CGContextSetBlendMode( hittestContext, kCGBlendModeLighten ); // This should make us draw pure yellow where we overlap

	// TODO: This makes no sense..
	CGFloat green_xTranslate = glyph1BoundingBox.size.width + pixelWidth*7;
	CGFloat green_yTranslate = 0;
	CGContextTranslateCTM( hittestContext, green_xTranslate, green_yTranslate );	
	
	// so, we have advanced by the width of glyph-one. At this position glyph-two bounding-box could still well draw over glyph 2 bounding-box (if it has a negative origin)
	// This is probably what we want -- and we assume the actual glyphs are not overlapping -- Just to be certain tho we will assert it (we do the first translation at the end of the loop)
	
	// What limit do we have on this loop?
	NSUInteger iterationLimit = glyph1BoundingBox.size.width;
	for( NSUInteger tryIndex=0; tryIndex<iterationLimit; tryIndex++ )
	{
		// draw glyph2 bounding box
		CGContextAddRect( hittestContext, glyph2BoundingBox );
		CGContextSetFillColorWithColor( hittestContext, greenCol );
		CGContextFillPath( hittestContext );	

		// draw glyph2
//		CGContextAddPath( hittestContext, glyphPath2 );
//		CGContextSetFillColorWithColor( hittestContext, greenCol );
//		CGContextFillPath( hittestContext );

//		// grab overlap region as memory
//		// -- fuck yeah lets start extracting columns
//		UInt32 * restrict baseAddr = (UInt32 *)CGBitmapContextGetData(hittestContext);
//		NSAssert(baseAddr!=nil, @"eh");
//
//		NSUInteger jokeWidth = scaledGlyph1Width;
//		NSUInteger jokeHeight = scaledGlyph1Height;
//
//		NSUInteger overlapWidth = 3;
//		for( NSUInteger i=0; i<overlapWidth; i++ )
//		{
//			for( NSUInteger j=0; j<jokeHeight; j++ )
//			{
//				// hunt for yellow pixel - // 3, 7, 11, 15, 2, 6, 10, 14, 1, 5, 9, 13, 0, 4, 8, 12
//
//				NSUInteger row = j * jokeWidth;
//				NSUInteger col = jokeWidth - 1 - i;
//				NSUInteger pixelIndex = row + col;
//				
//				UInt32 *pixAddress = (UInt32 *)baseAddr+pixelIndex;
//
//				UInt8 *base = (UInt8 *)pixAddress;
//				UInt8 red = base[1];
//				UInt8 green = base[2];
//				UInt8 blue = base[3];
//				UInt8 alpha = base[0];
//				
//				//NSLog(@"Index: %i, %i, %i %i", red, green, blue, alpha);
//				if( red==255 && green==255){
//TODO:					assert tryIndex!=0 @"fucked up our assumption that the glyphs dont start in overlapping position"
//					NSLog(@"HIT! %i", tryIndex);
//					goto shitStack;
//				}
//			}
//		}
	CGContextTranslateCTM( hittestContext, -pixelWidth, 0 );	

	}
shitStack:
	NSLog(@"w");
	
	// -- draw new context into window context
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData( NULL, bitmap, dataLength, NULL);
	CGImageRef cgImage = CGImageCreate( scaledGlyph1Width, scaledGlyph1Height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorspace, bitmapInfo, dataProvider, NULL, false, kCGRenderingIntentDefault );
	CGContextDrawImage( windowContext, CGRectMake( 6, 6, scaledGlyph1Width, scaledGlyph1Height), cgImage );
	
	CGImageRelease( cgImage );
	CGDataProviderRelease(dataProvider);
	CGContextRelease(hittestContext);
	CGColorSpaceRelease(colorspace);
	free(bitmap);
	CGColorRelease(blackCol);
	CGColorRelease(greenCol);
	CGColorRelease(redCol);
	CGColorRelease(rectCol);
	CGPathRelease(glyphPath1);
	CGPathRelease(glyphPath2);
	free(characters);
	free(glyphs);
	CFRelease(fdesc);
	CFRelease(iFont);
	

//		if so overlap advance is (glyph1.bounds_SCALE_.width-1.0f) / _SCALE_
//			
//			else
//				shift image 2 left by 1 pixel (overlap is now 2)
//				draw image 2 into image 1
//				test each column in overlap, starting in rightmost, until we find red and green
//				if we find red and green advance is (glyph1.bounds_SCALE_.width-2.0f) / _SCALE_
//					
//					continue shifting left until we find overlap
					
}

- (void)renderAString:(CGContextRef)context {
	
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"HiraMinPro-W3", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
	NSString *iString = @"abcdefghijklmnopqrstuvwxyz";
    assert(iFont != NULL && iString != NULL);
	
    // Get our string length.
    NSUInteger count = [iString length];
	
    // Allocate our buffers for characters and glyphs.
	UniChar *characters = (UniChar *)malloc(sizeof(UniChar) * count);
    assert(characters != NULL);
	
	CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * count);
    assert(glyphs != NULL);
	
    // Get the characters from the string.
    CFStringGetCharacters( (CFStringRef)iString, CFRangeMake(0, count), characters );
	
    // Get the glyphs for the characters.
    CTFontGetGlyphsForCharacters(iFont, characters, glyphs, count);
	
    // Do something with the glyphs here, if a character is unmapped
	// Draw a string with low level core text primitives
	for( NSUInteger i=0; i<count; i++ )
	{
		CGGlyph gl = glyphs[i];
		CGPathRef glyphPath = CTFontCreatePathForGlyph( iFont, gl, NULL );

//		draw
		CGContextSetAllowsAntialiasing( context, true );
		CGContextSetInterpolationQuality( context, kCGInterpolationNone );		
		CGContextBeginPath( context );
		CGContextAddPath( context, glyphPath );
		CGContextSetRGBFillColor( context, 1.0f, 0.0f, 0.0f, 1.0f );
		CGContextFillPath( context );
		
		char advanceType[] = "METRICS_ADVANCE\n";
		double advance = 0;
		// advance - This is bounding box touching! Not the same as glyphs touching.
		if( !strcmp( advanceType, "BOUNDING_BOX_ADVANCE\n" )) {
			CGRect glyphBoundingBox = CTFontGetBoundingRectsForGlyphs( iFont, kCTFontDefaultOrientation, &gl, NULL, 1 ); // 5, 0, 49, 51
			advance = glyphBoundingBox.size.width;
			
		// advance - This is bounding box touching! Not the same as glyphs touching.
		} else if( !strcmp( advanceType, "METRICS_ADVANCE\n" )) {
			advance = CTFontGetAdvancesForGlyphs( iFont, kCTFontDefaultOrientation, &gl, NULL, 1 );

		// advance so they are optically touching
		} else if( !strcmp( advanceType, "OPTICAL_ADVANCE\n" )) {
			if(i>0){				

			}
		} else {
			NSLog(@"You nana");
		}

		CGContextTranslateCTM( context, (CGFloat)advance, 0.0f );
		
		CGPathRelease(glyphPath);
	}
	
    // Free our buffers
	free(characters);
	free(glyphs);	
	
	CFRelease(fdesc);
	CFRelease(iFont);
}

- (CGImageRef)glyphImage {
	
	// get the path
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)@"HiraMinPro-W3", 72.0f ); 
	CTFontRef iFont = CreateFont( fdesc, 72.0f );
	
	CFCharacterSetRef charSet = CTFontCopyCharacterSet(iFont );
	NSData *charsetBitmap = [(NSCharacterSet *)charSet bitmapRepresentation];
	unsigned char *restrict bitmapRep = (unsigned char *)[charsetBitmap bytes];
	
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
	
	unsigned char bbit_0 = ( testByte & (((unsigned int)1) << (0 & 7)) );
	unsigned char bbit_1 = ( testByte & (((unsigned int)1) << (1 & 7)) );
	unsigned char bbit_2 = ( testByte & (((unsigned int)1) << (2 & 7)) );
	unsigned char bbit_3 = ( testByte & (((unsigned int)1) << (3 & 7)) );
	unsigned char bbit_4 = ( testByte & (((unsigned int)1) << (4 & 7)) );
	unsigned char bbit_5 = ( testByte & (((unsigned int)1) << (5 & 7)) );
	unsigned char bbit_6 = ( testByte & (((unsigned int)1) << (6 & 7)) );
	unsigned char bbit_7 = ( testByte & (((unsigned int)1) << (7 & 7)) );

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
	NSLog(@"Not snow leopard!");
#else
	CTFontCopyAttribute( iFont, kCTFontFormatAttribute); // 10.6 only!
#endif
			
	// new muthafucking way
	NSUInteger codept = 0; 
	for( NSUInteger n=0; n<byteCount; n++ )
	{
		unsigned char theByte = bitmapRep[n];
		for( NSUInteger j=0; j<8; j++ ){
			BOOL bbit = ( theByte & (((unsigned int)1) << (j & 7)) );
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

		if( bitmapRep[n >> 3] & (((unsigned int)1) << (n & 7)) ) {
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
	
	CGPathRef glyphPath = CTFontCreatePathForGlyph( iFont, [theGlyphs glyphAtIndex:0], NULL );
	
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
	
	// wrong!
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


@end
