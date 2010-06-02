//
//  FontWrapper.m
//  TypeSetter
//
//  Created by Steven Hooley on 31/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FontWrapper.h"
#import <ApplicationServices/ApplicationServices.h>

@interface FontWrapper ()
	
	- (void)_processFontTables;
	- (void)_processHEADTable;
	- (void)_processHHEATable;
	- (void)_processHMTXTable;
	- (void)_processMAXPTable;
	- (void)_processOS2;
	
	- (void)_processCMAPTable;
	- (void)_cmapSubTable_format4:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format6:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	
	- (void)_processGLYFTable;
	- (void)_processLOCATable;

@end

@implementation FontWrapper

+ (NSString *)randomFontName {
	
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

+ (void)getRandomFont:(CTFontRef *)iFont size:(CGFloat)floatSize {
	
	NSString *fontName = [self randomFontName];
	CTFontDescriptorRef fdesc = CreateFontDescriptorFromName( (CFStringRef)fontName, floatSize );
	assert( fdesc!=NULL );
	//	CGFontRef cgFont = CGFontCreateWithFontName( (CFStringRef)fontName );
	
	
	*iFont = CreateFont( fdesc, floatSize );
	assert( iFont!=NULL);
	
	CFRelease(fdesc);
	//	CFRelease(cgFont);
}

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

#pragma mark -
- (id)initWithName:(NSString *)arg1 size:(CGFloat)arg2 {

	self = [super init];
	if(self){
		
		NSFont *hmmFont = [NSFont fontWithName:arg1 size:72.0f];
		NSLog(@"number of glyphs is %i", [hmmFont numberOfGlyphs]);
		
		CTFontDescriptorRef fontDesc = CreateFontDescriptorFromName( (CFStringRef)arg1, arg2 );
	
		NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
										kCTFontNameAttribute, arg1,
										kCTFontSizeAttribute, [NSNumber numberWithFloat:arg2],
										[NSArray array], kCTFontCascadeListAttribute,
										nil];
		CTFontDescriptorRef fontDesc2 = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attributesDict);
		CTFontDescriptorRef fontDesc3 = [hmmFont fontDescriptor];
		
		_iFont = CreateFont( fontDesc3, arg2 );
		assert( _iFont!=NULL );
		CFRelease(fontDesc);
		
		[self _processFontTables];
	}
	return self;
}

- (void)dealloc {
	
	CFRelease(_iFont);

	[super dealloc];
}

- (void)_processFontTables {
	
	// lets see what we have got
	NSArray *availableFontTables = (NSArray *)CTFontCopyAvailableTables( _iFont, kCTFontTableOptionExcludeSynthetic );
	for( CFIndex i=0; i<(CFIndex)[availableFontTables count] ; i++ )
	{
		CTFontTableTag tableTag = (CTFontTableTag)(uintptr_t)CFArrayGetValueAtIndex((CFArrayRef)availableFontTables, i);
		NSString *fourCC = NSFileTypeForHFSTypeCode(tableTag);
		//	CFDataRef fontTable = CTFontCopyTable( _iFont, tableTag, kCTFontTableOptionExcludeSynthetic );
		NSLog(@"%@", fourCC);
		//	CFRelease( fontTable );
	}
	CFRelease(availableFontTables);
	
	/* Required Tables - See http://www.microsoft.com/typography/otspec/otff.htm#otttables */
	//	cmap	Character to glyph mapping
	//	head	Font header
	//	hhea	Horizontal header
	//	hmtx	Horizontal metrics
	//	maxp	Maximum profile
	//	name	Naming table
	//	OS/2	OS/2 and Windows specific metrics
	//	post	PostScript information


	// head - we need to know what kind of font we are dealing with
	[self _processHEADTable];

	// hhea
	[self _processHHEATable];

	// maxp
	[self _processMAXPTable];

	// OS/2
	[self _processOS2];
	 
	
	/* Some Tables are more for look up, ie we dont really want to process them when we init the font 
	 At the moment i am just testing parsing the data 
	 */
	
	  
	// hmtx - glyph metrics
	[self _processHMTXTable];

	// cmap
	[self _processCMAPTable];
	
	// name
	
	// post
	
	/* Optional Tables */
	[self _processGLYFTable];
	[self _processLOCATable];
}

// fourcc()

//	CFDataRef kernTable = CTFontCopyTable( iFont, kCTFontTableKern, kCTFontTableOptionExcludeSynthetic );
//	Fixed version;
//	uint32 nTables; 
//	NSAssert1( sizeof(version) == 4 , @"dih %i", sizeof(version) );
//	CFDataGetBytes(kernTable, CFRangeMake(0,4), &version);
//	CFDataGetBytes(kernTable, CFRangeMake(4,4), &nTables);

//	uint8_t panose[10];
//    CFDataGetBytes(os2Table, (CFRange){ 32, 10 }, panose);
//	CFRelease(kernTable);

// Useful TrueType info
// http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&item_id=IWS-Chapter08

/* Tables in Georgia */
//	'DSIG' - Digital signature
//	'GDEF' - Glyph definition data
//	'GPOS' - Glyph positioning data
//	'GSUB' - Glyph substitution data
//	'LTSH' - Linear threshold data: The optional ‘LTSH’ table indicates when a given glyph’s size begins to scale without being affected by hinting. 
//	'OS/2' - OS/2: line spacing, style & weight .Mac uses  ‘head’ and ‘hhea’ instead. Also what range of characters in font?
//	'VDMX' - Vertical Device Metrics (line heights?)
//	'cmap' - character to glyph mapping: ie, UNICODE to GLYPHID. All other font tables use the glyph id
//	'cvt ' - control value: (Hinting?)
//	'edt0' - embed font tool stuff (not needed for layout)
//	'fpgm' - font program:  (Hinting?)
//	'gasp' - (grid-fitting and scan-conversion procedure) table
//	'glyf' - glyph data:
//	'hdmx' - horizontal device metrics: (Precalculated glyph advances (which can be hinted and so are non linear) for various sized)
//	'head' - font header:
//	'hhea' - horizontal header: Summary information about horizontal metrics
//	'hmtx' - horizontal metrics:
//	'loca' - index to location: The ‘loca’ table simply provides an offset (based on a glyph id) for glyph data in the ‘glyf’ table
//	'maxp' - maximum profile: memory requirements, including nmber of glyphs
//	'name' - naming: text strings which an application can use to provide information about the font
//	'post' - PostScript: (Postscrpt glyph names, italic angle, underline position, proportional spacing)
//	'prep' - control value program:  (Hinting?)

/* Not Found in Georgia */
// 'kern' - kerning:
// An OpenType font can use the ‘CFF’ table (instead of the ‘glyf’ and ‘loca’ tables) for PostScript glyphs

/* Tables found in FreeSans */
//	'OS/2'
//	'Zapf'
//	'cmap'
//	'cvt '
//	'feat'
//	'fond'
//	'fpgm'
//	'glyf'
//	'hdmx'
//	'head'
//	'hhea'
//	'hmtx'
//	'just'
//	'loca'
//	'maxp'
//	'morx'
//	'name'
//	'post'
//	'prep'
//	'prop'

#pragma mark -
#pragma mark * Required tables *

#pragma mark Head Table 

- (void)_processHEADTable {

	CFDataRef headTable = CTFontCopyTable( _iFont, kCTFontTableHead, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	Fixed version;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof version), (UInt8 *)&version );
	loc += sizeof version;
	version = OSSwapBigToHostInt32(version);
	
	Fixed fontRevision;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof fontRevision), (UInt8 *)&fontRevision );
	loc += sizeof fontRevision;
	fontRevision = OSSwapBigToHostInt32(fontRevision);
	
	uint32 checkSumAdjustment;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof checkSumAdjustment), (UInt8 *)&checkSumAdjustment );
	loc += sizeof checkSumAdjustment;
	checkSumAdjustment = OSSwapBigToHostInt32(checkSumAdjustment);
	
	uint32 magicNumber;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof magicNumber), (UInt8 *)&magicNumber );
	loc += sizeof magicNumber;
	magicNumber = OSSwapBigToHostInt32(magicNumber);
	
	uint16 flags;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof flags), (UInt8 *)&flags );
	loc += sizeof flags;
	flags = OSSwapBigToHostInt16(flags);
	
	// process flags
	BOOL bit0 = flags & 1<<0;
	BOOL bit1 = flags & 1<<1;
	BOOL bit2 = flags & 1<<2;
	BOOL bit3 = flags & 1<<3;
	BOOL bit4 = flags & 1<<4;
	BOOL bit5 = flags & 1<<5;
	BOOL bit6 = flags & 1<<6;
	BOOL bit7 = flags & 1<<7;
	BOOL bit8 = flags & 1<<8;
	BOOL bit9 = flags & 1<<9;
	BOOL bit10 = flags & 1<<10;
	BOOL bit11 = flags & 1<<11;
	BOOL bit12 = flags & 1<<12;
	BOOL bit13 = flags & 1<<13;
	BOOL bit14 = flags & 1<<14;
	BOOL bit15 = flags & 1<<15;

	BOOL baselineForFontAt_y_equals_zero = bit0;
	BOOL leftSidebearingPointAt_x_equals_zero = bit1;
	BOOL instructionsMayDependOnPointSize = bit2;
	BOOL forcePpemToIntegerValues = bit3;
	BOOL instructionsMayAlterAdvanceWidth = bit4;
	NSAssert( (bit5 | bit6 | bit7 | bit8 | bit9 | bit10 )==NO, @"Endian Problems?" );
	NSAssert( (bit14 | bit15 )==NO, @"Endian Problems?" );
	
	uint16 unitsPerEm;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof unitsPerEm), (UInt8 *)&unitsPerEm );
	loc += sizeof unitsPerEm;
	unitsPerEm = OSSwapBigToHostInt16(unitsPerEm);
	
	uint64_t created;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof created), (UInt8 *)&created );
	loc += sizeof created;
	created = OSSwapBigToHostInt64(created);
	
	uint64_t modified;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof modified), (UInt8 *)&modified );
	loc += sizeof modified;
	modified = OSSwapBigToHostInt64(modified);
	
	int16_t xMin;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof xMin), (UInt8 *)&xMin );
	loc += sizeof xMin;
	xMin = OSSwapBigToHostInt16(xMin);
	
	int16_t yMin;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof yMin), (UInt8 *)&yMin );
	loc += sizeof yMin;
	yMin = OSSwapBigToHostInt16(yMin);
	
	int16_t xMax;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof xMax), (UInt8 *)&xMax );
	loc += sizeof xMax;
	xMax = OSSwapBigToHostInt16(xMax);
	
	int16_t yMax;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof yMax), (UInt8 *)&yMax );
	loc += sizeof yMax;
	yMax = OSSwapBigToHostInt16(yMax);
	
	uint16 macStyle;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof macStyle), (UInt8 *)&macStyle );
	loc += sizeof macStyle;
	macStyle = OSSwapBigToHostInt16(macStyle);
	
	uint16 lowestRecPPEM;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof lowestRecPPEM), (UInt8 *)&lowestRecPPEM );
	loc += sizeof lowestRecPPEM;
	lowestRecPPEM = OSSwapBigToHostInt16(lowestRecPPEM);
	
	int16_t fontDirectionHint;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof fontDirectionHint), (UInt8 *)&fontDirectionHint );
	loc += sizeof fontDirectionHint;
	fontDirectionHint = OSSwapBigToHostInt16(fontDirectionHint);
	
	// we need this to get an outlines, assuming truetype outline format
	CFDataGetBytes( headTable, CFRangeMake(loc, sizeof _indexToLocFormat), (UInt8 *)&_indexToLocFormat );
	loc += sizeof _indexToLocFormat;
	_indexToLocFormat = OSSwapBigToHostInt16(_indexToLocFormat);
	
	int16_t glyphDataFormat;
	CFDataGetBytes( headTable, CFRangeMake(loc,sizeof glyphDataFormat), (UInt8 *)&glyphDataFormat );
	glyphDataFormat = OSSwapBigToHostInt16(glyphDataFormat);
	
	CFRelease( headTable );
}

#pragma mark hhea Table 

- (void)_processHHEATable {
	
	CFDataRef hheaTable = CTFontCopyTable( _iFont, kCTFontTableHhea, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	Fixed version;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof version), (UInt8 *)&version );
	loc += sizeof version;
	version = OSSwapBigToHostInt32(version);
	
	int16_t ascent;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof ascent), (UInt8 *)&ascent );
	loc += sizeof ascent;
	ascent = OSSwapBigToHostInt16(ascent);
	
	int16_t descent;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof descent), (UInt8 *)&descent );
	loc += sizeof descent;
	descent = OSSwapBigToHostInt16(descent);
	
	int16_t lineGap;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof lineGap), (UInt8 *)&lineGap );
	loc += sizeof lineGap;
	lineGap = OSSwapBigToHostInt16(lineGap);
	
	uint16 advanceWidthMax;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof advanceWidthMax), (UInt8 *)&advanceWidthMax );
	loc += sizeof advanceWidthMax;
	advanceWidthMax = OSSwapBigToHostInt16(advanceWidthMax);
	
	int16_t minLeftSideBearing;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof minLeftSideBearing), (UInt8 *)&minLeftSideBearing );
	loc += sizeof minLeftSideBearing;
	minLeftSideBearing = OSSwapBigToHostInt16(minLeftSideBearing);
	
	int16_t minRightSideBearing;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof minRightSideBearing), (UInt8 *)&minRightSideBearing );
	loc += sizeof minRightSideBearing;
	minRightSideBearing = OSSwapBigToHostInt16(minRightSideBearing);
	
	int16_t xMaxExtent;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof xMaxExtent), (UInt8 *)&xMaxExtent );
	loc += sizeof xMaxExtent;
	xMaxExtent = OSSwapBigToHostInt16(xMaxExtent);
	
	int16_t caretSlopeRise;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof caretSlopeRise), (UInt8 *)&caretSlopeRise );
	loc += sizeof caretSlopeRise;
	caretSlopeRise = OSSwapBigToHostInt16(caretSlopeRise);
	
	int16_t caretSlopeRun;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof caretSlopeRun), (UInt8 *)&caretSlopeRun );
	loc += sizeof caretSlopeRun;
	caretSlopeRun = OSSwapBigToHostInt16(caretSlopeRun);
	
	int16_t caretOffset;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof caretOffset), (UInt8 *)&caretOffset );
	loc += sizeof caretOffset;
	caretOffset = OSSwapBigToHostInt16(caretOffset);
	
	int16_t reserved1;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof reserved1), (UInt8 *)&reserved1 );
	loc += sizeof reserved1;
	reserved1 = OSSwapBigToHostInt16(reserved1);
	
	int16_t reserved2;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof reserved2), (UInt8 *)&reserved2 );
	loc += sizeof reserved2;
	reserved2 = OSSwapBigToHostInt16(reserved2);
	
	int16_t reserved3;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof reserved3), (UInt8 *)&reserved3 );
	loc += sizeof reserved3;
	reserved3 = OSSwapBigToHostInt16(reserved3);

	int16_t reserved4;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof reserved4), (UInt8 *)&reserved4 );
	loc += sizeof reserved4;
	reserved4 = OSSwapBigToHostInt16(reserved4);
	
	int16_t metricDataFormat;
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof metricDataFormat), (UInt8 *)&metricDataFormat );
	loc += sizeof metricDataFormat;
	metricDataFormat = OSSwapBigToHostInt16(metricDataFormat);
	
	uint16 numOfLongHorMetrics; // Number of hMetric entries in 'hmtx' table
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof numOfLongHorMetrics), (UInt8 *)&numOfLongHorMetrics );
	numOfLongHorMetrics = OSSwapBigToHostInt16(numOfLongHorMetrics);
	
	CFRelease(hheaTable);
}

#pragma mark OS/2 Table 
- (void)_processOS2 {
	
	CFDataRef os2Table = CTFontCopyTable( _iFont, kCTFontTableOS2, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	uint16	version;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof version), (UInt8 *)&version );
	loc += sizeof version;
	version = OSSwapBigToHostInt16(version);
	
	int16_t	xAvgCharWidth;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof xAvgCharWidth), (UInt8 *)&xAvgCharWidth );
	loc += sizeof xAvgCharWidth;
	xAvgCharWidth = OSSwapBigToHostInt16(xAvgCharWidth);
	
	uint16	usWeightClass;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usWeightClass), (UInt8 *)&usWeightClass );
	loc += sizeof usWeightClass;
	usWeightClass = OSSwapBigToHostInt16(usWeightClass);

	uint16	usWidthClass;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usWidthClass), (UInt8 *)&usWidthClass );
	loc += sizeof usWidthClass;
	usWidthClass = OSSwapBigToHostInt16(usWidthClass);

	uint16	fsType;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof fsType), (UInt8 *)&fsType );
	loc += sizeof fsType;
	fsType = OSSwapBigToHostInt16(fsType);

	int16_t	ySubscriptXSize;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySubscriptXSize), (UInt8 *)&ySubscriptXSize );
	loc += sizeof ySubscriptXSize;
	ySubscriptXSize = OSSwapBigToHostInt16(ySubscriptXSize);

	int16_t	ySubscriptYSize;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySubscriptYSize), (UInt8 *)&ySubscriptYSize );
	loc += sizeof ySubscriptYSize;
	ySubscriptYSize = OSSwapBigToHostInt16(ySubscriptYSize);

	int16_t	ySubscriptXOffset;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySubscriptXOffset), (UInt8 *)&ySubscriptXOffset );
	loc += sizeof ySubscriptXOffset;
	ySubscriptXOffset = OSSwapBigToHostInt16(ySubscriptXOffset);

	int16_t	ySubscriptYOffset;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySubscriptYOffset), (UInt8 *)&ySubscriptYOffset );
	loc += sizeof ySubscriptYOffset;
	ySubscriptYOffset = OSSwapBigToHostInt16(ySubscriptYOffset);

	int16_t	ySuperscriptXSize;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySuperscriptXSize), (UInt8 *)&ySuperscriptXSize );
	loc += sizeof ySuperscriptXSize;
	ySuperscriptXSize = OSSwapBigToHostInt16(ySuperscriptXSize);

	int16_t	ySuperscriptYSize;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySuperscriptYSize), (UInt8 *)&ySuperscriptYSize );
	loc += sizeof ySuperscriptYSize;
	ySuperscriptYSize = OSSwapBigToHostInt16(ySuperscriptYSize);

	int16_t	ySuperscriptXOffset;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySuperscriptXOffset), (UInt8 *)&ySuperscriptXOffset );
	loc += sizeof ySuperscriptXOffset;
	ySuperscriptXOffset = OSSwapBigToHostInt16(ySuperscriptXOffset);

	int16_t	ySuperscriptYOffset;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ySuperscriptYOffset), (UInt8 *)&ySuperscriptYOffset );
	loc += sizeof ySuperscriptYOffset;
	ySuperscriptYOffset = OSSwapBigToHostInt16(ySuperscriptYOffset);

	int16_t	yStrikeoutSize;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof yStrikeoutSize), (UInt8 *)&yStrikeoutSize );
	loc += sizeof yStrikeoutSize;
	yStrikeoutSize = OSSwapBigToHostInt16(yStrikeoutSize);

	int16_t	yStrikeoutPosition;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof yStrikeoutPosition), (UInt8 *)&yStrikeoutPosition );
	loc += sizeof yStrikeoutPosition;
	yStrikeoutPosition = OSSwapBigToHostInt16(yStrikeoutPosition);

	int16_t	sFamilyClass;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sFamilyClass), (UInt8 *)&sFamilyClass );
	loc += sizeof sFamilyClass;
	sFamilyClass = OSSwapBigToHostInt16(sFamilyClass);

	uint8_t	panose[10];
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof panose), (UInt8 *)&panose );
	loc += sizeof panose;
	
	u_int32_t ulUnicodeRange1;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulUnicodeRange1), (UInt8 *)&ulUnicodeRange1 );
	loc += sizeof ulUnicodeRange1;
	ulUnicodeRange1 = OSSwapBigToHostInt32(ulUnicodeRange1);

	u_int32_t ulUnicodeRange2;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulUnicodeRange2), (UInt8 *)&ulUnicodeRange2 );
	loc += sizeof ulUnicodeRange2;
	ulUnicodeRange2 = OSSwapBigToHostInt32(ulUnicodeRange2);

	u_int32_t ulUnicodeRange3;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulUnicodeRange3), (UInt8 *)&ulUnicodeRange3 );
	loc += sizeof ulUnicodeRange3;
	ulUnicodeRange3 = OSSwapBigToHostInt32(ulUnicodeRange3);

	u_int32_t ulUnicodeRange4;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulUnicodeRange4), (UInt8 *)&ulUnicodeRange4 );
	loc += sizeof ulUnicodeRange4;
	ulUnicodeRange4 = OSSwapBigToHostInt32(ulUnicodeRange4);

	int8_t	achVendID[4];
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof achVendID), (UInt8 *)&achVendID );
	loc += sizeof achVendID;

	uint16	fsSelection;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof fsSelection), (UInt8 *)&fsSelection );
	loc += sizeof fsSelection;
	fsSelection = OSSwapBigToHostInt16(fsSelection);

	uint16	usFirstCharIndex;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usFirstCharIndex), (UInt8 *)&usFirstCharIndex );
	loc += sizeof usFirstCharIndex;
	usFirstCharIndex = OSSwapBigToHostInt16(usFirstCharIndex);

	uint16	usLastCharIndex;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usLastCharIndex), (UInt8 *)&usLastCharIndex );
	loc += sizeof usLastCharIndex;
	usLastCharIndex = OSSwapBigToHostInt16(usLastCharIndex);

	int16_t	sTypoAscender;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sTypoAscender), (UInt8 *)&sTypoAscender );
	loc += sizeof sTypoAscender;
	sTypoAscender = OSSwapBigToHostInt16(sTypoAscender);

	int16_t	sTypoDescender;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sTypoDescender), (UInt8 *)&sTypoDescender );
	loc += sizeof sTypoDescender;
	sTypoDescender = OSSwapBigToHostInt16(sTypoDescender);
	
	int16_t	sTypoLineGap;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sTypoLineGap), (UInt8 *)&sTypoLineGap );
	loc += sizeof sTypoLineGap;
	sTypoLineGap = OSSwapBigToHostInt16(sTypoLineGap);
	
	uint16	usWinAscent;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usWinAscent), (UInt8 *)&usWinAscent );
	loc += sizeof usWinAscent;
	usWinAscent = OSSwapBigToHostInt16(usWinAscent);
	
	uint16	usWinDescent;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usWinDescent), (UInt8 *)&usWinDescent );
	loc += sizeof usWinDescent;
	usWinDescent = OSSwapBigToHostInt16(usWinDescent);
	
	u_int32_t ulCodePageRange1;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulCodePageRange1), (UInt8 *)&ulCodePageRange1 );
	loc += sizeof ulCodePageRange1;
	ulCodePageRange1 = OSSwapBigToHostInt32(ulCodePageRange1);

	u_int32_t ulCodePageRange2;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof ulCodePageRange2), (UInt8 *)&ulCodePageRange2 );
	loc += sizeof ulCodePageRange2;
	ulCodePageRange2 = OSSwapBigToHostInt32(ulCodePageRange2);
	
	int16_t	sxHeight;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sxHeight), (UInt8 *)&sxHeight );
	loc += sizeof sxHeight;
	sxHeight = OSSwapBigToHostInt16(sxHeight);

	int16_t	sCapHeight;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof sCapHeight), (UInt8 *)&sCapHeight );
	loc += sizeof sCapHeight;
	sCapHeight = OSSwapBigToHostInt16(sCapHeight);
	
	uint16	usDefaultChar;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usDefaultChar), (UInt8 *)&usDefaultChar );
	loc += sizeof usDefaultChar;
	usDefaultChar = OSSwapBigToHostInt16(usDefaultChar);
	
	uint16	usBreakChar;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usBreakChar), (UInt8 *)&usBreakChar );
	loc += sizeof usBreakChar;
	usBreakChar = OSSwapBigToHostInt16(usBreakChar);

	uint16	usMaxContext;
	CFDataGetBytes( os2Table, CFRangeMake(loc,sizeof usMaxContext), (UInt8 *)&usMaxContext );
	usMaxContext = OSSwapBigToHostInt16(usMaxContext);
	
	CFRelease(os2Table);
}

#pragma mark hmtx Table 
- (void)_processHMTXTable {
	
	CFDataRef hmtxTable = CTFontCopyTable( _iFont, kCTFontTableHmtx, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;
	
//	longHorMetric hMetrics

	CFRelease(hmtxTable);
}

#pragma mark Cmap Table 

/*	Ok, 1: I dont understand why so many cmap subtables.
	But i do think that understand how to use a table to go from unicode to glyphID (i just dont understand which table you would look in really).
	So, i see now that many unicode values could map to the same glyphID, so the cmap tables dont really tell us how many glyphs we have or what their ID's are */
- (void)_processCMAPTable {
	
	CFDataRef cmapTable = CTFontCopyTable( _iFont, kCTFontTableCmap, kCTFontTableOptionExcludeSynthetic );

	uint loc = 0;
	uint16 version, numberOfTables;

	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&version ); // 0x00010000
	version = OSSwapBigToHostInt16(version);
	loc +=2;
	CFDataGetBytes( cmapTable, CFRangeMake(2,2), (UInt8 *)&numberOfTables );
	numberOfTables = OSSwapBigToHostInt16(numberOfTables);
	loc +=2;

	for( NSUInteger i=0; i<numberOfTables; i++ ) {
	
		UInt16 platformID, platformSpecificID;
		UInt32 subTableOffset;
		CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&platformID );
		platformID = OSSwapBigToHostInt16(platformID); // 0==Apple unicode
		loc +=2;
		
		// This refers to language in the name table?
		CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&platformSpecificID );
		platformSpecificID = OSSwapBigToHostInt16(platformSpecificID);
		loc +=2;
		
		CFDataGetBytes( cmapTable, CFRangeMake(loc,4), (UInt8 *)&subTableOffset );
		subTableOffset = OSSwapBigToHostInt32(subTableOffset);
		loc +=4;
		NSAssert( subTableOffset<CFDataGetLength(cmapTable), @"How can offset be outside the table?" );
		
		UInt16 subTableFormat1;
		Fixed subTableFormat2;

		CFDataGetBytes( cmapTable, CFRangeMake(subTableOffset,2), (UInt8 *)&subTableFormat1 );
		CFDataGetBytes( cmapTable, CFRangeMake(subTableOffset,4), (UInt8 *)&subTableFormat2 );

		subTableFormat1 = OSSwapBigToHostInt16(subTableFormat1);
		subTableFormat2 = OSSwapBigToHostInt32(subTableFormat2);

		// Special Glyph Ids
		//	Glyph Id	Character
		//	0			unknown glyph
		//	1			null
		//	2			carriage return
		//	3			space
		
		if( subTableFormat1==0 ){
			[NSException raise:@"Format 0" format:nil];
		} else if( subTableFormat1==2 ){
			[NSException raise:@"Format 2" format:nil];
		} else if( subTableFormat1==4 ){
			[self _cmapSubTable_format4:cmapTable offset:subTableOffset];
		} else if( subTableFormat1==6 ){
			[self _cmapSubTable_format6:cmapTable offset:subTableOffset];
		} else {
			// These are the tables for dealing with surrogates
			if( subTableFormat2==8 ){
				[NSException raise:@"Format 8" format:nil];
			} else if( subTableFormat2==10 ){
				[NSException raise:@"Format 10" format:nil];
			} else if( subTableFormat2==12 ){
				[NSException raise:@"Format 12" format:nil];
			} else {
				[NSException raise:@"CMap subtable format not found" format:nil];
			}
		}
	}
	CFRelease( cmapTable );
}

- (void)_cmapSubTable_format4:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {

	NSLog(@"Format 4");

	uint loc = subTableOffset;

	// header
	UInt16 format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&format );
	loc +=2;
	format = OSSwapBigToHostInt16(format);

	UInt16 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&length );
	loc +=2;
	length = OSSwapBigToHostInt16(length);

	UInt16 language; // Zero if language independant
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&language );
	loc +=2;
	language = OSSwapBigToHostInt16(language);

	UInt16 segCountX2;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&segCountX2 );
	loc +=2;
	segCountX2 = OSSwapBigToHostInt16(segCountX2);

	UInt16 searchRange;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&searchRange );
	loc +=2;
	searchRange = OSSwapBigToHostInt16(searchRange);

	UInt16 entrySelector;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&entrySelector );
	loc +=2;
	entrySelector = OSSwapBigToHostInt16(entrySelector);

	UInt16 rangeShift;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&rangeShift );
	loc +=2;
	rangeShift = OSSwapBigToHostInt16(rangeShift);

	// 4 parallel arrays
	UInt16 num_ranges = segCountX2/2;
	for( UInt16 i=0; i<num_ranges; i++ )
	{		
		UInt16 arrayLoc = loc + i * 2;

		// search for the first endCode that is greater than or equal to the character code to be mapped
		//  If the corresponding startCode is less than or equal to the character code, then use the corresponding idDelta and idRangeOffset to map the character code to the glyph index
		// Otherwise, the missing character glyph is returned. To ensure that the search will terminate, the final endCode value must be 0xFFFF. This segment need not contain any valid mappings. It can simply map the single character code 0xFFFF to the missing character glyph, glyph 0.
		// If the idRangeOffset value for the segment is not 0, the mapping of the character codes relies on the glyphIndexArray.
		// The character code offset from startCode is added to the idRangeOffset value. This sum is used as an offset from the current location within idRangeOffset itself to index out the correct glyphIdArray value. This indexing method works because glyphIdArray immediately follows idRangeOffset in the font file. The address of the glyph index is given by the following equation:
		// glyphIndexAddress = idRangeOffset[i] + 2 * (c - startCode[i]) + (Ptr) &idRangeOffset[i]
		// If the idRangeOffset is 0, the idDelta value is added directly to the character code to get the corresponding glyph index:
		// glyphIndex = idDelta[i] + c
		UInt16 endCode_i;
		CFDataGetBytes( cmapTable, CFRangeMake(arrayLoc,2), (UInt8 *)&endCode_i );
		endCode_i = OSSwapBigToHostInt16(endCode_i);
		
		arrayLoc += 2 + num_ranges * 2;	
		UInt16 startCode_i;
		CFDataGetBytes( cmapTable, CFRangeMake(arrayLoc,2), (UInt8 *)&startCode_i );
		startCode_i = OSSwapBigToHostInt16(startCode_i);
		
		arrayLoc += num_ranges * 2;
		UInt16 idDelta_i;
		CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&idDelta_i );
		idDelta_i = OSSwapBigToHostInt16(idDelta_i);
		
		arrayLoc += num_ranges * 2;
		UInt16 idRangeOffset_i;
		CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&idRangeOffset_i );
		idRangeOffset_i = OSSwapBigToHostInt16(idRangeOffset_i);

		NSLog(@"End %i, start %i", endCode_i, startCode_i);
	}
	NSAssert(loc<length, @"well this was obviously wrong dick sweart %i, %i", loc, length );
	
	// variable length array if glyph indexes
	UInt16 glyphIndexArray_variable;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&glyphIndexArray_variable );
	glyphIndexArray_variable = OSSwapBigToHostInt16(glyphIndexArray_variable);
}

- (void)_cmapSubTable_format6:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {

	NSLog(@"Format 6");
	
	uint loc = subTableOffset;
	
	// header
	UInt16 format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&format );
	loc +=2;
	format = OSSwapBigToHostInt16(format);
	
	UInt16 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&length );
	loc +=2;
	length = OSSwapBigToHostInt16(length);
	
	UInt16 language; // Zero if language independant
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&language );
	loc +=2;
	language = OSSwapBigToHostInt16(language);
	
	UInt16 firstCode;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&firstCode );
	loc +=2;
	firstCode = OSSwapBigToHostInt16(firstCode);
	
	UInt16 entryCount;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,2), (UInt8 *)&entryCount );
	loc +=2;
	entryCount = OSSwapBigToHostInt16(entryCount);
	
	UInt16 desiredItem = 0;
	NSAssert( desiredItem<entryCount, @"woohoo merrggggh");
	
	UInt16 arrayLoc = loc + desiredItem * 2;
	//NSAssert( arrayLoc<length, @"woohoo merrggggh");
	//UInt16 glyphIndexArray;
	
	UInt16 gyphid;
	CFDataGetBytes( cmapTable, CFRangeMake(arrayLoc,2), (UInt8 *)&gyphid );
	gyphid = OSSwapBigToHostInt16(gyphid);
	
	NSLog(@"Example glyph id from table 6 is %i", gyphid ); // check to see if this glyph id is a special one
}

#pragma mark Maxp Table 
- (void)_processMAXPTable {

	CFDataRef maxpTable = CTFontCopyTable( _iFont, kCTFontTableMaxp, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	Fixed version;

	CFDataGetBytes( maxpTable, CFRangeMake(loc, sizeof version), (UInt8 *)&version ); // 0x00010000
	loc += sizeof version;
	version = OSSwapBigToHostInt32(version);

	CFDataGetBytes( maxpTable, CFRangeMake(loc, sizeof _numberOfGlyphs), (UInt8 *)&_numberOfGlyphs );
	_numberOfGlyphs = OSSwapBigToHostInt16(_numberOfGlyphs);

	CFRelease( maxpTable );
}

#pragma mark -
#pragma mark * Optional tables *

#pragma mark glyf Table

- (void)_processGLYFTable {
	
	CFDataRef glyfTable = CTFontCopyTable( _iFont, kCTFontTableGlyf, kCTFontTableOptionExcludeSynthetic );
	_glyfTableLength = CFDataGetLength(glyfTable);
	CFRelease(glyfTable);
}

#pragma mark loca Table
// for a given glyph id, get the offset in the glyf table
- (void)_processLOCATable {
	
	CFDataRef locaTable = CTFontCopyTable( _iFont, kCTFontTableLoca, kCTFontTableOptionExcludeSynthetic );

	/* FOR ONE OF THESE (SHORT OR LONG) There is some dividing by 2 done or needs to be done, i dont know which THESE ARE THE SAME FOR NOW */
	// TODO: work out where the divide goes

	// SHORT OFFSETS
	if(_indexToLocFormat==0){
		
		[NSException raise:@"Havent done this yet" format:nil];
	
//		// jusr loooping thru all of them to test it
//		for( uint i=0; i<_numberOfGlyphs; i++ ){
//			
//			UInt16 arrayLoc = i * 2;
//			UInt16 offsetLoc = arrayLoc+2; // dont worry, there are n+1 entries
//
//			UInt16 offset, nextOffset, length;
//			CFDataGetBytes( locaTable, CFRangeMake( offsetValueLoc, sizeof offset ), (UInt8 *)&offset );
//			CFDataGetBytes( locaTable, CFRangeMake( nextOffsetValueLoc, sizeof nextOffset ), (UInt8 *)&nextOffset );
//			offset = OSSwapBigToHostInt16(offset);
//			nextOffset = OSSwapBigToHostInt16(nextOffset); // this is actually just the next entry, so subtract to find the length of this entry (last 1 is a special case and is taken care of)
//			offset = offset*2;
//			nextOffset = nextOffset*2;
//			length = nextOffset - offset;
//
//			NSLog(@"Glyph id:%i Offset:%i Length:%i", i, offset, length );
//		}
		
	// LONG OFFSETS
	} else if(_indexToLocFormat==1) {

		int nonNullGlyphCount=0;

		// jusr loooping thru all of them to test it
		for( uint i=0; i<_numberOfGlyphs; i++ ){
			
			UInt32 offset, nextOffset, length;

			UInt16 offsetValueLoc = i * sizeof offset;
			UInt16 nextOffsetValueLoc = offsetValueLoc + sizeof offset; // dont worry, there are n+1 entries
			NSAssert(offsetValueLoc<CFDataGetLength(locaTable), @"oops, overstepped the loca table?");

			CFDataGetBytes( locaTable, CFRangeMake( offsetValueLoc, sizeof offset ), (UInt8 *)&offset );
			CFDataGetBytes( locaTable, CFRangeMake( nextOffsetValueLoc, sizeof nextOffset ), (UInt8 *)&nextOffset );
			offset = OSSwapBigToHostInt32(offset);
			nextOffset = OSSwapBigToHostInt32(nextOffset); // this is actually just the next entry, so subtract to find the length of this entry (last 1 is a special case and is taken care of)
			
			if(i==(_numberOfGlyphs-1))
				NSLog(@"woah, last offset? %i : glyf table length %i", nextOffset, _glyfTableLength);
			NSAssert(nextOffset<=_glyfTableLength, @"Opps - this doesnt appear to be doing what i thought");
			
			length = nextOffset - offset;
			if(offset>0){
				nonNullGlyphCount=nonNullGlyphCount+1;
				NSLog(@"%i Glyph id:%i Offset:%i Length:%i", nonNullGlyphCount, i, offset, length );
			}
		}

	} else {
		[NSException raise:@"Unknown _indexToLocFormat" format:nil];
	}

	
	CFRelease(locaTable);
}

@end