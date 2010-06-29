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
	- (void)_processOS2Table;
	- (void)_processNameTable;
	- (void)_processPostTable;

	- (void)_processCMAPTable;
	// ok, so im only doing subtable type i come across - sue me
	- (void)_cmapSubTable_format0:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format2:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format4:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format6:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format12:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;
	- (void)_cmapSubTable_format14:(CFDataRef)cmapTable offset:(UInt32)subTableOffset;

	- (void)_processGLYFTable;
	- (void)_processLOCATable;
	- (void)_processLTSH;

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
		
		// NSFont is toll free bridged with CTFontRef?
		NSFont *hmmFont = [NSFont fontWithName:arg1 size:arg2];
		if(!hmmFont) {
			[NSException raise:@"Font Not Found" format:@"%@", arg1];
		}
		_numberOfGlyphs = [hmmFont numberOfGlyphs];
		NSLog(@"number of glyphs is %i", _numberOfGlyphs );
		
		CTFontDescriptorRef fontDesc = CreateFontDescriptorFromName( (CFStringRef)arg1, arg2 );
		NSFontDescriptor *fontDesc3 = [hmmFont fontDescriptor];
		_iFont = CreateFont( (CTFontDescriptorRef)fontDesc3, arg2 );
		
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

- (BOOL)knowHowToProcessFontTableNamed:(NSString *)fontTableName {
	
	NSArray *allKnownTables = [NSArray arrayWithObjects:
							   						   
							   /* Required */
							   @"head",		// Verified for opentype
							   @"hhea",		// Verified for opentype
							   @"hmtx",		// Verified for opentype
							   @"maxp",		// Verified for opentype
							   @"name",		// Naming table
							   @"OS/2",		// OS/2 and Windows specific metrics
							   @"post"			// PostScript information
							   @"cmap",		// ok, done some subtables but not all
							   
							   /* Optional */
							   
							   
							   nil];
	return NO;
}

- (void)_processFontTables {
	
	// lets see what we have got
	NSArray *availableFontTables = (NSArray *)CTFontCopyAvailableTables( _iFont, kCTFontTableOptionExcludeSynthetic );
	for( CFIndex i=0; i<(CFIndex)[availableFontTables count] ; i++ )
	{
		CTFontTableTag tableTag = (CTFontTableTag)(uintptr_t)CFArrayGetValueAtIndex((CFArrayRef)availableFontTables, i);
		NSString *fourCC = NSFileTypeForHFSTypeCode(tableTag);
		
		// CFDataRef fontTable = CTFontCopyTable( _iFont, tableTag, kCTFontTableOptionExcludeSynthetic );
		// NSAssert( [self knowHowToProcessFontTableNamed:fourCC], @"Unknown Font table %@",  fourCC );

		NSLog(@"%@", fourCC);
		//CFRelease( fontTable );
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


	// VERIFIED! head - we need to know what kind of font we are dealing with
	[self _processHEADTable];

	// VERIFIED! hhea
	[self _processHHEATable];	// horizontal header: Summary information about horizontal metrics

	// VERIFIED! maxp (partially done)
	[self _processMAXPTable];	// maximum profile: memory requirements, including nmber of glyphs

	// VERIFIED! OS/2
	[self _processOS2Table];			// OS/2: line spacing, style & weight .Mac uses  ‘head’ and ‘hhea’ instead. Also what range of characters in font?
	 
	[self _processNameTable];
	[self _processPostTable];

	/* Some Tables are more for look up, ie we dont really want to process them when we init the font 
	 At the moment i am just testing parsing the data 
	 */
	
	  
	// VERIFIED! hmtx - glyph metrics
	[self _processHMTXTable];

	// cmap
	
	// subtable 0, 4 is verified, do the rest
	[self _processCMAPTable];
	
	
	/* Optional Tables */
	// VERIFIED
	[self _processLTSH];		//	'LTSH' - Linear threshold data: The optional ‘LTSH’ table indicates when a given glyph’s size begins to scale without being affected by hinting
	
	// get locations to glyp outines before parsing GLYF table
	[self _processLOCATable];
	//	[self _processGLYFTable];
	
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
//	'head' - font header:
//	'cmap' - character to glyph mapping: ie, UNICODE to GLYPH_INDEX. All other font tables use the glyph index
//	'hhea' - horizontal header: Summary information about horizontal metrics
//	'hmtx' - horizontal metrics:
//	'maxp' - maximum profile: memory requirements, including nmber of glyphs
//	'name' - naming: text strings which an application can use to provide information about the font
//	'OS/2' - OS/2: line spacing, style & weight .Mac uses  ‘head’ and ‘hhea’ instead. Also what range of characters in font?
//	'post' - PostScript: (Postscrpt glyph names, italic angle, underline position, proportional spacing)

//	'glyf' - glyph data:
//	'loca' - index to location: The ‘loca’ table simply provides an offset (based on a glyph index) for glyph data in the ‘glyf’ table
//	'LTSH' - Linear threshold data: The optional ‘LTSH’ table indicates when a given glyph’s size begins to scale without being affected by hinting.
//	'hdmx' - horizontal device metrics: (Precalculated glyph advances (which can be hinted and so are non-linear) for various sized)
//	'GPOS' - Glyph positioning data

//	'cvt ' - control value: (Hinting?)
//	'fpgm' - font program:  (Hinting?)
//	'prep' - control value program:  (Hinting?)

//	'DSIG' - Digital signature
//	'GDEF' - Glyph definition data
//	'VDMX' - Vertical Device Metrics (line heights?)
//	'edt0' - embed font tool stuff (not needed for layout)
//	'gasp' - (grid-fitting and scan-conversion procedure) table
//	'GSUB' - Glyph substitution data


/* Not Found in Georgia */
// 'kern' - kerning:
// An OpenType font can use the ‘CFF’ table (instead of the ‘glyf’ and ‘loca’ tables) for PostScript glyphs

/* Tables found in FreeSans */
//	'head'
//	'cmap'
//	'hhea'
//	'hmtx'
//	'maxp'
//	'name'
//	'OS/2'
//	'post'

//	'glyf'
//	'loca'
//	'LTSH' << here! working down 
//	'hdmx'
//	'GPOS'

//	'cvt '
//	'fpgm'
//	'prep'

//	'kern'


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
// horizontal header: Summary information about horizontal metrics
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
	
	// Number of hMetric entries in 'hmtx' table
	CFDataGetBytes( hheaTable, CFRangeMake(loc,sizeof _numOfLongHorMetrics), (UInt8 *)&_numOfLongHorMetrics );
	_numOfLongHorMetrics = OSSwapBigToHostInt16(_numOfLongHorMetrics);
	
	CFRelease(hheaTable);
}

#pragma mark OS/2 Table 
- (void)_processOS2Table {
	
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

	// sFamilyClass: 8 subclass = 2
	// Needs more parsing 
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

#pragma mark name Table
/* This enables us to get all the strings out of the font 
 * font names, copyright notices, family names etc
 * it is not really useful to me */
- (void)_processNameTable {

	CFDataRef nameTable = CTFontCopyTable( _iFont, kCTFontTableName, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;
	
	UInt16 format;	// Format selector. Set to 0.
	CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt16(format);
	
	UInt16 count;	// The number of nameRecords in this name table.
	CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof count), (UInt8 *)&count );
	loc += sizeof count;
	count = OSSwapBigToHostInt16(count);
	
	UInt16 stringOffset;	// Offset in bytes to the beginning of the name character strings.
	CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof stringOffset), (UInt8 *)&stringOffset );
	loc += sizeof stringOffset;
	stringOffset = OSSwapBigToHostInt16(stringOffset);
	
	for( UInt16 i=0; i<count; i++ ) {
	
		UInt16 platformID;	// Platform identifier code.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof platformID), (UInt8 *)&platformID );
		loc += sizeof platformID;
		platformID = OSSwapBigToHostInt16(platformID);

		UInt16 platformSpecificID;	// Platform-specific encoding identifier.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof platformSpecificID), (UInt8 *)&platformSpecificID );
		loc += sizeof platformSpecificID;
		platformSpecificID = OSSwapBigToHostInt16(platformSpecificID);

		UInt16 languageID;	// Language identifier.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof languageID), (UInt8 *)&languageID );
		loc += sizeof languageID;
		languageID = OSSwapBigToHostInt16(languageID);

		UInt16 nameID;	// Name identifiers.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof nameID), (UInt8 *)&nameID );
		loc += sizeof nameID;
		nameID = OSSwapBigToHostInt16(nameID);

		UInt16 length;	// Name string length in bytes.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof length), (UInt8 *)&length );
		loc += sizeof length;
		length = OSSwapBigToHostInt16(length);

		UInt16 offset;	// Name string offset in bytes from stringOffset.
		CFDataGetBytes( nameTable, CFRangeMake( loc, sizeof offset), (UInt8 *)&offset );
		loc += sizeof offset;
		offset = OSSwapBigToHostInt16(offset);

		char *string = malloc(length);
		CFDataGetBytes( nameTable, CFRangeMake(offset+stringOffset, length), (UInt8 *)string );
		NSLog(@"%s",string);
		free(string);

	}
// TODO	
//	variable	name	character strings The character strings of the names. Note that these are not necessarily ASCII!
	
	CFRelease(nameTable);
}

#pragma mark Post
- (void)_processPostTable {
	
	CFDataRef postTable = CTFontCopyTable( _iFont, kCTFontTablePost, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	Fixed format;	// Format of this table
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt32(format);
	
	Fixed italicAngle	; // Italic angle in degrees
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof italicAngle), (UInt8 *)&italicAngle );
	loc += sizeof italicAngle;
	italicAngle = OSSwapBigToHostInt32(italicAngle);
	
	SInt16 underlinePosition;	// Underline position
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof underlinePosition), (UInt8 *)&underlinePosition );
	loc += sizeof underlinePosition;
	underlinePosition = OSSwapBigToHostInt16(underlinePosition);
	
	SInt16 underlineThickness;	// Underline thickness
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof underlineThickness), (UInt8 *)&underlineThickness );
	loc += sizeof underlineThickness;
	underlineThickness = OSSwapBigToHostInt16(underlineThickness);
	
	uint32 isFixedPitch;	// Font is monospaced; set to 1 if the font is monospaced and 0 otherwise (N.B., to maintain compatibility with older versions of the TrueType spec, accept any non-zero value as meaning that the font is monospaced)
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof isFixedPitch), (UInt8 *)&isFixedPitch );
	loc += sizeof isFixedPitch;
	isFixedPitch = OSSwapBigToHostInt32(isFixedPitch);
	
	uint32 minMemType42;	// Minimum memory usage when a TrueType font is downloaded as a Type 42 font
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof minMemType42), (UInt8 *)&minMemType42 );
	loc += sizeof minMemType42;
	minMemType42 = OSSwapBigToHostInt32(minMemType42);
	
	uint32 maxMemType42;	// Maximum memory usage when a TrueType font is downloaded as a Type 42 font
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof maxMemType42), (UInt8 *)&maxMemType42 );
	loc += sizeof maxMemType42;
	maxMemType42 = OSSwapBigToHostInt32(maxMemType42);
	
	uint32 minMemType1;	// Minimum memory usage when a TrueType font is downloaded as a Type 1 font
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof minMemType1), (UInt8 *)&minMemType1 );
	loc += sizeof minMemType1;
	minMemType1 = OSSwapBigToHostInt32(minMemType1);
	
	uint32 maxMemType1;	// Maximum memory usage when a TrueType font is downloaded as a Type 1 font
	CFDataGetBytes( postTable, CFRangeMake( loc, sizeof maxMemType1), (UInt8 *)&maxMemType1 );
	loc += sizeof maxMemType1;
	maxMemType1 = OSSwapBigToHostInt32(maxMemType1);
	
	if( format == IntToFixed(1) ){
		// 258 glyphs with fixed names - so no subtable needed
		[NSException raise:@"type 1 postscript format - this necer happens" format:@""];
	}
	else if( format == FloatToFixed(2) ){
	
	//	uint16	numberOfGlyphs	number of glyphs
	//	uint16	glyphNameIndex[numberOfGlyphs]	Ordinal number of this glyph in 'post' string tables. This is not an offset.
	//	Pascal string	names[numberNewGlyphs]	glyph names with length bytes [variable] (a Pascal string)
		[NSException raise:@"type 2 postscript format - this necer happens" format:@""];
	}
	else if( format == FloatToFixed(2.5) ){
		[NSException raise:@"type 2.5 postscript format - this necer happens" format:@""];
	}
	else if( format == FloatToFixed(3) ){
		/* This means no postscript character names - doesn't have a subtable */
	}
	else if( format == FloatToFixed(4) ){
		[NSException raise:@"type 4 postscript format - this necer happens" format:@""];
	}
	else 
		[NSException raise:@"Unknwn postscript format" format:@""];
	
	
	CFRelease(postTable);
}

#pragma mark hmtx Table
// VERIFIED
// hmtx	Horizontal metrics
- (void)_processHMTXTable {

	CFDataRef hmtxTable = CTFontCopyTable( _iFont, kCTFontTableHmtx, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;
	
	uint16 advanceWidth;
	int16_t leftSideBearing;
	
	for( UInt16 i=0; i<_numOfLongHorMetrics; i++ )
	{
		uint32 longHorMetric_i;

		UInt16 arrayLoc1 = loc + i * sizeof longHorMetric_i;
		
		// logHor is really a struct with 2 16bit values in
		CFDataGetBytes( hmtxTable, CFRangeMake( arrayLoc1, sizeof longHorMetric_i), (UInt8 *)&longHorMetric_i );
		
		// TODO: who knows if we should swap the bytes then extract the subvalues or extract the subvalues THEN swap the bytes?
		// longHorMetric_i = OSSwapBigToHostInt32(longHorMetric_i);
		
		// how to extract? No idea which way round these should go
		int16_t leastSignificant16Bits = (int16_t)longHorMetric_i;
		int16_t mostSignificant16Bits1 = (int16_t)(longHorMetric_i >> 16);

		advanceWidth = OSSwapBigToHostInt16(leastSignificant16Bits);
		leftSideBearing = OSSwapBigToHostInt16(mostSignificant16Bits1);
		
		NSLog(@"%i. advWid: %i, LSdBear: %i", i, advanceWidth, leftSideBearing );
	}
	
	// Then.. then.. we have an array of leftsidebearings (advanceWidth is the same as in the LAST longHorMetric_i)
	uint numberOfBitsToFollow = _numberOfGlyphs - _numOfLongHorMetrics;
	UInt16 followingArrayLoc = loc + _numOfLongHorMetrics * sizeof(uint32);
	for( UInt16 j=0; j<numberOfBitsToFollow; j++ )
	{
		UInt16 arrayLoc2 = followingArrayLoc + j * sizeof(int16_t);
		
		CFDataGetBytes( hmtxTable, CFRangeMake( arrayLoc2, sizeof leftSideBearing), (UInt8 *)&leftSideBearing );
		leftSideBearing = OSSwapBigToHostInt16(leftSideBearing);
		uint index = _numOfLongHorMetrics + j;
		NSLog(@"%i. advWid: %i, LSdBear: %i", index, advanceWidth, leftSideBearing );
	}
	
	CFRelease(hmtxTable);
}

#pragma mark Cmap Table 

/*	Ok, 1: I dont understand why so many cmap subtables.
	But i do think that understand how to use a table to go from unicode to glyphIndex (i just dont understand which table you would look in really).
	So, i see now that many unicode values could map to the same glyphIndex, so the cmap tables dont really tell us how many glyphs we have or what their ID's are */
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

		// Special Glyph Indexes
		//	Glyph Ind	Character
		//	0			unknown glyph
		//	1			null
		//	2			carriage return
		//	3			space
		
		if( subTableFormat1==0 ){
			[self _cmapSubTable_format0:cmapTable offset:subTableOffset];
		} else if( subTableFormat1==2 ){
			// Japanese, Chinese, or Korean characters.
			[self _cmapSubTable_format2:cmapTable offset:subTableOffset];
		} else if( subTableFormat1==4 ){
			[self _cmapSubTable_format4:cmapTable offset:subTableOffset];
		} else if( subTableFormat1==6 ){
			[self _cmapSubTable_format6:cmapTable offset:subTableOffset];
		} else {
			int type2 = FixedToInt(subTableFormat2);
			// These are the tables for dealing with surrogates
			if( type2==8 ){
				[NSException raise:@"Format 8" format:@"eh?"];
			} else if( type2==10 ){
				[NSException raise:@"Format 10" format:@"eh?"];
			} else if( type2==12 ){
				[self _cmapSubTable_format12:cmapTable offset:subTableOffset];
			} else if( type2==14 ){
				[self _cmapSubTable_format14:cmapTable offset:subTableOffset];
			} else {
				[NSException raise:@"CMap subtable format not found" format:@"eh?"];
			}
		}
	}
	CFRelease( cmapTable );
}

- (void)_cmapSubTable_format0:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {

	uint loc = subTableOffset;
	
	UInt16 format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc,sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt16(format);

	UInt16 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof length), (UInt8 *)&length );
	loc += sizeof length;
	length = OSSwapBigToHostInt16(length);

	UInt16 language;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof language), (UInt8 *)&language );
	loc += sizeof language;
	language = OSSwapBigToHostInt16(language);
	
	int glyphCount = 0;
	for( UInt16 i=0; i<256; i++ )
	{
		UInt8 glyphIndex_i;
		UInt16 arrayLoc = loc + i * sizeof glyphIndex_i;
		CFDataGetBytes( cmapTable, CFRangeMake(arrayLoc, sizeof glyphIndex_i), (UInt8 *)&glyphIndex_i );
		UInt16 glyphIndex_i16 = glyphIndex_i;
		// Doesn't need byte swapping!
		
		if(glyphIndex_i16!=0){
			
			NSLog(@"Char %i: %i > glyphIndex %i", glyphCount++, i, glyphIndex_i16 );
		}
	}
}

// Japanese, Chinese, or Korean characters.
struct subheader {
    UInt16 firstCode;
    UInt16 entryCount;
    SInt16 idDelta;
    UInt16 idRangeOffset;
};

- (void)_cmapSubTable_format2:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {

	uint loc = subTableOffset;
	
	UInt16	format;	// Set to 2
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt16(format);
	
	UInt16	length;	// Total table length in bytes
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof length), (UInt8 *)&length );
	loc += sizeof length;
	length = OSSwapBigToHostInt16(length);
	
	UInt16	language;	// Language code for this encoding subtable, or zero if language-independent
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof language), (UInt8 *)&language );
	loc += sizeof language;
	language = OSSwapBigToHostInt16(language);
	
	UInt16 subHeaderKeys[256];	// Array that maps high bytes to subHeaders: value is index * 8
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof subHeaderKeys), (UInt8 *)&subHeaderKeys );
	loc += sizeof subHeaderKeys;
	
	uint subHeaders_addr = loc;

	for( NSUInteger firstByte = 0; firstByte<256; firstByte++ ) {
	
		struct subheader aSubHeader;
		UInt16 subHeadersIndex = OSSwapBigToHostInt16 (subHeaderKeys[firstByte]);
		UInt16 subHeadersIndex2 = subHeadersIndex / 8;
		
		uint subheaderOffset = subHeaders_addr + subHeadersIndex2*sizeof aSubHeader;
		CFDataGetBytes( cmapTable, CFRangeMake( subheaderOffset, sizeof aSubHeader), (UInt8 *)&aSubHeader );
		
		//	UInt16	glyphIndexArray[variable];	// Variable length array containing subarrays

		UInt16 firstCode = OSSwapBigToHostInt16(aSubHeader.firstCode);
		UInt16 entryCount = OSSwapBigToHostInt16(aSubHeader.entryCount);
		SInt16 idDelta = OSSwapBigToHostInt16(aSubHeader.idDelta);
		
		// offset into glyphIndexArray from here
		UInt16 idRangeOffset = OSSwapBigToHostInt16(aSubHeader.idRangeOffset);
		

		static BOOL isDone = NO;
		if( (subHeadersIndex2==0 && isDone==NO) || subHeadersIndex2>0 ){
			
			// only do this once if index is zero
			if(subHeadersIndex2==0)
				isDone=YES;
		
			UInt16 startOfRangeInGlyphIndexArray = subheaderOffset+(sizeof idDelta)*3+idRangeOffset; // (sizeof idDelta)*3 = position of idRangeOffset
			
			for( NSUInteger j=0; j<entryCount; j++) {
				
				UInt16 p;
				UInt16 offset = startOfRangeInGlyphIndexArray+(j*sizeof p);
				CFDataGetBytes( cmapTable, CFRangeMake( offset, sizeof p), (UInt8 *)&p );
				p = OSSwapBigToHostInt16(p);
				if(p!=0)
					p = p+idDelta;
				
				NSLog(@"HiByte %0x - char[%0x], index %i", firstByte, firstCode+j, p);
			}
		}
	}
	NSLog(@"fini?");
}

- (void)_cmapSubTable_format4:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {

	uint loc = subTableOffset;

	// header
	UInt16 format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt16(format);

	UInt16 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof length), (UInt8 *)&length );
	loc += sizeof length;
	length = OSSwapBigToHostInt16(length);

	// uint end = (UInt8 *)(&cmapTable)+subTableOffset+length;

	UInt16 language; // Zero if language independant
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof language), (UInt8 *)&language );
	loc += sizeof language;
	language = OSSwapBigToHostInt16(language);

	UInt16 segCountX2;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof segCountX2), (UInt8 *)&segCountX2 );
	loc += sizeof segCountX2;
	segCountX2 = OSSwapBigToHostInt16(segCountX2);

	UInt16 searchRange;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof searchRange), (UInt8 *)&searchRange );
	loc += sizeof searchRange;
	searchRange = OSSwapBigToHostInt16(searchRange);

	UInt16 entrySelector;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof entrySelector), (UInt8 *)&entrySelector );
	loc += sizeof entrySelector;
	entrySelector = OSSwapBigToHostInt16(entrySelector);

	UInt16 rangeShift;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof rangeShift), (UInt8 *)&rangeShift );
	loc += sizeof rangeShift;
	rangeShift = OSSwapBigToHostInt16(rangeShift);

	// 4 parallel arrays
	UInt16 num_ranges = segCountX2/2;
	uint eachElementSpacing = num_ranges*sizeof(UInt16);
	UInt16 reservedSpace = sizeof(UInt16);
	
	for( UInt16 i=0; i<num_ranges; i++ )
	{		
		// 1st element of each parallel array
		uint arrayLoc = loc + i * sizeof(UInt16);

		// search for the first endCode that is greater than or equal to the character code to be mapped
		//  If the corresponding startCode is less than or equal to the character code, then use the corresponding idDelta and idRangeOffset to map the character code to the glyph index
		// Otherwise, the missing character glyph is returned. To ensure that the search will terminate, the final endCode value must be 0xFFFF. This segment need not contain any valid mappings. It can simply map the single character code 0xFFFF to the missing character glyph, glyph 0.
		// If the idRangeOffset value for the segment is not 0, the mapping of the character codes relies on the glyphIndexArray.
		// The character code offset from startCode is added to the idRangeOffset value. This sum is used as an offset from the current location within idRangeOffset itself to index out the correct glyphIdArray value. This indexing method works because glyphIdArray immediately follows idRangeOffset in the font file. The address of the glyph index is given by the following equation:
		// glyphIndexAddress = idRangeOffset[i] + 2 * (c - startCode[i]) + (Ptr) &idRangeOffset[i]
		// If the idRangeOffset is 0, the idDelta value is added directly to the character code to get the corresponding glyph index:
		// glyphIndex = idDelta[i] + c

		uint endCodeLoc = arrayLoc + 0 * eachElementSpacing;
		UInt16 endCode_i;
		CFDataGetBytes( cmapTable, CFRangeMake( endCodeLoc, sizeof endCode_i), (UInt8 *)&endCode_i );
		endCode_i = OSSwapBigToHostInt16(endCode_i);

		// after the first elements in the array there is a single space
		// endCodeLoc[0], endCodeLoc[1], endCodeLoc[2], reserved, startCode[0], startCode[1], startCode[2], delta[0], delta[1], etc
		
		uint startCodeLoc = arrayLoc + 1*eachElementSpacing + reservedSpace;
		UInt16 startCode_i;
		CFDataGetBytes( cmapTable, CFRangeMake( startCodeLoc, sizeof startCode_i), (UInt8 *)&startCode_i );
		startCode_i = OSSwapBigToHostInt16(startCode_i);

		// so we have char 0xstartCode_i to char 0xendCode_i

		uint deltaLoc = arrayLoc + 2*eachElementSpacing + reservedSpace;
		SInt16 idDelta_i;
		CFDataGetBytes( cmapTable, CFRangeMake( deltaLoc, sizeof idDelta_i), (UInt8 *)&idDelta_i );
		idDelta_i = OSSwapBigToHostInt16(idDelta_i);

		uint rangeOffsetLoc = arrayLoc + 3*eachElementSpacing + reservedSpace;
		UInt16 idRangeOffset_i;
		CFDataGetBytes( cmapTable, CFRangeMake( rangeOffsetLoc, sizeof idRangeOffset_i), (UInt8 *)&idRangeOffset_i );
		idRangeOffset_i = OSSwapBigToHostInt16(idRangeOffset_i);

		if( idRangeOffset_i==0 ) {
			for( NSUInteger j=startCode_i; j<=endCode_i; j++ ) {
				UInt16 glyphIndex = idDelta_i+j;
				NSLog( @"char %x -> Index %i", j, glyphIndex );
			}
		} else {
			for( NSUInteger j=startCode_i; j<=endCode_i; j++ ) 
			{
				uint glyphIndexAddress = idRangeOffset_i + (j-startCode_i)*2 + rangeOffsetLoc;
				// NSLog( @"address %i", glyphIndexAddress );
				
				UInt16 glyphIndex;
				CFDataGetBytes( cmapTable, CFRangeMake( glyphIndexAddress, sizeof glyphIndex), (UInt8 *)&glyphIndex );
				glyphIndex = OSSwapBigToHostInt16(glyphIndex);
				NSLog( @"%i: char %x -> Index %i", i, j, glyphIndex );
			}			
		}
		
		NSAssert( rangeOffsetLoc <= (subTableOffset+length), @"well this was obviously wrong dick sweart %i, %i", loc, length );
	}

	// Okidoki - soooo, there follows a variable length array which the commented out code below iterates over,
	// we dont use it like this tho, the values in the array are accessed above when idRangeOffset_i!=0
	//	uint endPoint = subTableOffset + length;
	//	loc += 4*sizeof(UInt16)*num_ranges + reservedSpace;
	//	UInt16 wordsLeft = (endPoint-loc)/2;
	//	
	//	// variable length array if glyph indexes
	//	for( NSUInteger i=0; i<wordsLeft; i++ )
	//	{
	//		UInt16 glyphIndexArray_variable;
	//		uint array_i_Loc = loc+sizeof(UInt16)*i;
	//		CFDataGetBytes( cmapTable, CFRangeMake( array_i_Loc, sizeof glyphIndexArray_variable), (UInt8 *)&glyphIndexArray_variable );
	//		NSLog( @"Just for reference %i", array_i_Loc );
	//		glyphIndexArray_variable = OSSwapBigToHostInt16(glyphIndexArray_variable);
	//	}
	
}

- (void)_cmapSubTable_format6:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {
	
	[NSException raise:@"why did i di this?" format:@""];
	
	uint loc = subTableOffset;
	
	// header
	UInt16 format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt16(format);
	
	UInt16 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof length), (UInt8 *)&length );
	loc += sizeof length;
	length = OSSwapBigToHostInt16(length);
	
	UInt16 language; // Zero if language independant
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof language), (UInt8 *)&language );
	loc += sizeof language;
	language = OSSwapBigToHostInt16(language);
	
	UInt16 firstCode;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof firstCode), (UInt8 *)&firstCode );
	loc += sizeof firstCode;
	firstCode = OSSwapBigToHostInt16(firstCode);
	
	UInt16 entryCount;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof entryCount), (UInt8 *)&entryCount );
	loc += sizeof entryCount;
	entryCount = OSSwapBigToHostInt16(entryCount);
	
	UInt16 desiredItem = 0;
	NSAssert( desiredItem<entryCount, @"woohoo merrggggh");
	
	UInt16 arrayLoc = loc + desiredItem * 2;
	//NSAssert( arrayLoc<length, @"woohoo merrggggh");
	//UInt16 glyphIndexArray;
	
	UInt16 gyphindex;
	CFDataGetBytes( cmapTable, CFRangeMake(arrayLoc, sizeof gyphindex), (UInt8 *)&gyphindex );
	gyphindex = OSSwapBigToHostInt16(gyphindex);
	
	// NSLog(@"Example glyph index from table 6 is %i", gyphindex ); // check to see if this glyph id is a special one
}

// Table for surrogates?
- (void)_cmapSubTable_format12:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {
	
	uint loc = subTableOffset;

	Fixed format;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof format), (UInt8 *)&format );
	loc += sizeof format;
	format = OSSwapBigToHostInt32(format);
		
	UInt32 length;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof length), (UInt8 *)&length );
	loc += sizeof length;
	length = OSSwapBigToHostInt32(length);
	
	UInt32 language; // Zero if language independant
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof language), (UInt8 *)&language );
	loc += sizeof language;
	language = OSSwapBigToHostInt32(language);
	
	UInt32 nGroups;
	CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof nGroups), (UInt8 *)&nGroups );
	loc += sizeof nGroups;
	nGroups = OSSwapBigToHostInt32(nGroups);
	
	for( UInt32 i=0; i<nGroups; i++ ){
		
		UInt32 startCharCode;
		CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof startCharCode), (UInt8 *)&startCharCode );
		loc += sizeof startCharCode;
		startCharCode = OSSwapBigToHostInt32(startCharCode);

		UInt32 endCharCode;
		CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof endCharCode), (UInt8 *)&endCharCode );
		loc += sizeof endCharCode;
		endCharCode = OSSwapBigToHostInt32(endCharCode);

		UInt32 startGlyphID;
		CFDataGetBytes( cmapTable, CFRangeMake(loc, sizeof startGlyphID), (UInt8 *)&startGlyphID );
		loc += sizeof startGlyphID;
		startGlyphID = OSSwapBigToHostInt32(startGlyphID);
		
		for( UInt32 j=startCharCode, k=0; j<=endCharCode; j++, k++ ) {
			UInt32 glyphIndex = startGlyphID+k;
			NSLog( @"%i: char code %x -> Index %i", i, j, glyphIndex );
		}
	}
}

/* Experimental */
void getByte( CFDataRef *tablePtr, uint *locPtr, UInt8 *valPtr ) {

	CFDataGetBytes( *tablePtr, CFRangeMake(*locPtr, sizeof *valPtr), (UInt8 *)valPtr );
	*locPtr = *locPtr + sizeof *valPtr;
}

void getUInt16( CFDataRef *tablePtr, uint *locPtr, UInt16 *valPtr ) {
	
	CFDataGetBytes( *tablePtr, CFRangeMake(*locPtr, sizeof *valPtr), (UInt8 *)valPtr );
	*locPtr = *locPtr + sizeof *valPtr;
	*valPtr = OSSwapBigToHostInt16(*valPtr);
}

// combine 3 bytes - i dont know how else to do it!
void getUInt24( CFDataRef *tablePtr, uint *locPtr, UInt32 *valPtr ) {
	
	UInt8 byte1, byte2, byte3;
	getByte( tablePtr, locPtr, &byte1 );
	getByte( tablePtr, locPtr, &byte2 );
	getByte( tablePtr, locPtr, &byte3 );
	
	*valPtr = byte1;
	*valPtr = (*valPtr << 8) | byte2;
	*valPtr = (*valPtr << 8) | byte3;
}

void getUInt32( CFDataRef *tablePtr, uint *locPtr, UInt32 *valPtr ) {
	
	CFDataGetBytes( *tablePtr, CFRangeMake(*locPtr, sizeof *valPtr), (UInt8 *)valPtr );
	*locPtr = *locPtr + sizeof *valPtr;
	*valPtr = OSSwapBigToHostInt32(*valPtr);
}

// http://blogs.adobe.com/typblography/UVS_in_OT.htm
- (void)_cmapSubTable_format14:(CFDataRef)cmapTable offset:(UInt32)subTableOffset {
	
	uint loc = subTableOffset;

	UInt16 format;						// Subtable format. Set to 14
	getUInt16( &cmapTable, &loc, &format );

	UInt32 length;						// Byte length of this subtable (including this header)
	getUInt32( &cmapTable, &loc, &length );

	UInt32 numVarSelectorRecords;		// Number of Variation Selector Records	
	getUInt32( &cmapTable, &loc, &numVarSelectorRecords );

	// Variation Selector Records
	for( NSUInteger i=0; i<numVarSelectorRecords; i++ ) {
		
		// varSelectors are in ascending order and no 2 the same
		// UINT24 varSelector				// varSelector	Variation selector
		UInt32 varSelector;
		getUInt24( &cmapTable, &loc, &varSelector );

		UInt32 defaultUVSOffset;			// Offset to Default UVS Table. May be 0.
		getUInt32( &cmapTable, &loc, &defaultUVSOffset );
		
		UInt32 nonDefaultUVSOffset;			// Offset to Non-Default UVS Table. May be 0.
		getUInt32( &cmapTable, &loc, &nonDefaultUVSOffset );
		
		if(defaultUVSOffset) {

			uint offset = subTableOffset+defaultUVSOffset;

			UInt32 numUnicodeValueRanges;	// Number of ranges that follow
			getUInt32( &cmapTable, &offset, &numUnicodeValueRanges );

			for (NSUInteger j=0; j<numUnicodeValueRanges; j++) {

				UInt32 startUnicodeValue;	// First value in this range
				getUInt24( &cmapTable, &loc, &startUnicodeValue );
				
				UInt8 additionalCount;		// Number of additional values in this range
				getByte( &cmapTable, &loc, &additionalCount );
					
				for( NSUInteger k=0; k<(1+additionalCount); k++) {
					UInt32 baseUnicodeValue = startUnicodeValue + k;
					NSLog( @"<U+%0x, U+%0x> = glyphID == you have to look up base character for this" , baseUnicodeValue, varSelector );
				}
			}
			
		} else if(nonDefaultUVSOffset) {
			
			uint offset = subTableOffset+nonDefaultUVSOffset;
			
			UInt32 numUVSMappings;			// Number of UVS Mappings that follow
			getUInt32( &cmapTable, &offset, &numUVSMappings );

			for (NSUInteger j=0; j<numUVSMappings; j++) {
				
				UInt32 baseUnicodeValue;
				getUInt24( &cmapTable, &loc, &baseUnicodeValue );

				UInt16 glyphID;
				getUInt16( &cmapTable, &loc, &glyphID );
				
				NSLog( @"<U+%0x, U+%0x> = glyphID %i" , baseUnicodeValue, varSelector, glyphID );
			}
			
		} else {
			[NSException raise:@"defaultUVSOffset or nonDefaultUVSOffset" format:@""];
		}
	}
	
	
	[NSException raise:@"still to do" format:@""];
	
}

#pragma mark Maxp Table
// maximum profile: memory requirements, including nmber of glyphs
- (void)_processMAXPTable {

	CFDataRef maxpTable = CTFontCopyTable( _iFont, kCTFontTableMaxp, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;

	Fixed version;

	CFDataGetBytes( maxpTable, CFRangeMake(loc, sizeof version), (UInt8 *)&version ); // 0x00010000
	loc += sizeof version;
	version = OSSwapBigToHostInt32(version);

	uint16 numberOfGlyphs;
	CFDataGetBytes( maxpTable, CFRangeMake(loc, sizeof numberOfGlyphs), (UInt8 *)&numberOfGlyphs );
	numberOfGlyphs = OSSwapBigToHostInt16(numberOfGlyphs);
	NSAssert( numberOfGlyphs==_numberOfGlyphs, @"Glyph count mismatch %i - %i", _numberOfGlyphs, numberOfGlyphs );

	// TODO
	//	maxPoints:		124
	//	maxContours:		9
	//	maxCompositePoints:	0
	//	maxCompositeContours:	0
	//	maxZones:		1
	//	maxTwilightPoints:	0
	//	maxStorage:		0
	//	maxFunctionDefs:	10
	//	maxInstructionDefs:	0
	//	maxStackElements:	512
	//	maxSizeOfInstructions:	525
	//	maxComponentElements:	0
	//	maxComponentDepth:	0      
	
	CFRelease( maxpTable );
}

#pragma mark LTSH Table
// VERIFIED
// 'LTSH' - Linear threshold data: The optional ‘LTSH’ table indicates when a given glyph’s size begins to scale without being affected by hinting.
- (void)_processLTSH {
	
	CFDataRef LTSHTable = CTFontCopyTable( _iFont, kCTFontTableLTSH, kCTFontTableOptionExcludeSynthetic );
	uint loc = 0;
	
	uint16 version;
	CFDataGetBytes( LTSHTable, CFRangeMake(loc, sizeof version), (UInt8 *)&version );
	loc += sizeof version;
	version = OSSwapBigToHostInt16(version);
	
	uint16 numGlyphs;
	CFDataGetBytes( LTSHTable, CFRangeMake(loc, sizeof numGlyphs), (UInt8 *)&numGlyphs );
	loc += sizeof numGlyphs;
	numGlyphs = OSSwapBigToHostInt16(numGlyphs);
	
	// For a given glyph Index from cmap table find ..x
	for( UInt16 i=0; i<numGlyphs; i++ )
	{
		uint8 yPels_i;
		UInt16 arrayLoc = loc + i * sizeof yPels_i;
		CFDataGetBytes( LTSHTable, CFRangeMake(arrayLoc, sizeof yPels_i), (UInt8 *)&yPels_i );
		UInt16 yPels_i16 = yPels_i;
		//yPels_i16 = OSSwapBigToHostInt16(yPels_i16);	// duh! i dont know ho to swap the endianness of a byte..	
		NSLog(@"Glyph %i - linear threshold %i", i, yPels_i16);
		NSAssert( arrayLoc<CFDataGetLength(LTSHTable), @"Overshot the LTSHTable length?");
	}
	
	CFRelease(LTSHTable);
}

#pragma mark -
#pragma mark * Optional tables *

#pragma mark glyf Table
// GLYF
- (void)_processGLYFTable {
	
	NSLog( @"** glyph table **");
	CFDataRef glyfTable = CTFontCopyTable( _iFont, kCTFontTableGlyf, kCTFontTableOptionExcludeSynthetic );
	_glyfTableLength = CFDataGetLength(glyfTable);
	
	uint loc = 0;
	int glyphCount = 0;

	// lets have a play and see what we can do with this
//	while( loc<_glyfTableLength ) {
//
//		int16_t numberOfContours;
//		CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof numberOfContours), (UInt8 *)&numberOfContours );
//		loc += sizeof numberOfContours;
//		numberOfContours = OSSwapBigToHostInt16(numberOfContours);
//		
//		int16_t xMin;
//		CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof xMin), (UInt8 *)&xMin );
//		loc += sizeof xMin;
//		xMin = OSSwapBigToHostInt16(xMin);
//
//		int16_t yMin;
//		CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof yMin), (UInt8 *)&yMin );
//		loc += sizeof yMin;
//		yMin = OSSwapBigToHostInt16(yMin);
//		
//		int16_t xMax;
//		CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof xMax), (UInt8 *)&xMax );
//		loc += sizeof xMax;
//		xMax = OSSwapBigToHostInt16(xMax);
//		
//		int16_t yMax;
//		CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof yMax), (UInt8 *)&yMax );
//		loc += sizeof yMax;
//		yMax = OSSwapBigToHostInt16(yMax);
//		
//		NSLog(@"Glyph %i has %i contours", glyphCount, numberOfContours );
//	
//		// NOT a composite glyph
//		if(numberOfContours>=0) {
//			
//			// Array of last points of each contour; n is the number of contours
//			// UInt16 endPtsOfContours[n];
//			loc += sizeof UInt16 * numberOfContours;
//			
//			// Total number of bytes for instructions
//			UInt16 instructionLength;
//			CFDataGetBytes( glyfTable, CFRangeMake(loc, sizeof instructionLength), (UInt8 *)&instructionLength );
//			loc += sizeof instructionLength;
//			instructionLength = OSSwapBigToHostInt16(instructionLength);
//			
//			// UInt8 instructions[n]
//			loc += sizeof UInt8 * instructionLength;
//			
//			UInt8 flags[n]
//			UInt8 or int16_t
//			UInt8 or int16_t
//			
//		// COMPOSITE glyph
//		} else {
//			[NSException raise:@"Composite Glyph found" format:@"blrrgg"];
////			UInt16	flags
////			UInt16	glyphIndex
////			VARIABLE	argument1
////			VARIABLE	argument2
////			Transformation Option
//		}
//		glyphCount++;
//	}
	
	CFRelease(glyfTable);
}


// ttf dump code here http://www.koders.com/info.aspx?c=ProjectInfo&pid=M3C16ME9UYQXHS38P5ZT8ARPFH

#pragma mark loca Table
// for a given glyph index, get the offset in the glyf table
// LOCA
- (void)_processLOCATable {
	
	CFDataRef locaTable = CTFontCopyTable( _iFont, kCTFontTableLoca, kCTFontTableOptionExcludeSynthetic );

	/* FOR ONE OF THESE (SHORT OR LONG) There is some dividing by 2 done or needs to be done, i dont know which THESE ARE THE SAME FOR NOW */
	// TODO: work out where the divide goes

	int nonNullGlyphCount=0;

	// SHORT OFFSETS - VERIFIED!
	if(_indexToLocFormat==0){
			
		// jusr loooping thru all of them to test it
		for( uint i=0; i<_numberOfGlyphs; i++ ) {
		
			UInt16 offset, nextOffset, length;		// NB! Different type
			
			UInt16 offsetValueLoc = i * sizeof offset;
			UInt16 nextOffsetValueLoc = offsetValueLoc + sizeof offset; // dont worry, there are n+1 entries
			NSAssert(offsetValueLoc<CFDataGetLength(locaTable), @"oops, overstepped the loca table?");

			CFDataGetBytes( locaTable, CFRangeMake( offsetValueLoc, sizeof offset ), (UInt8 *)&offset );
			CFDataGetBytes( locaTable, CFRangeMake( nextOffsetValueLoc, sizeof nextOffset ), (UInt8 *)&nextOffset );
			offset = OSSwapBigToHostInt16(offset);
			nextOffset = OSSwapBigToHostInt16(nextOffset); // this is actually just the next entry, so subtract to find the length of this entry (last 1 is a special case and is taken care of)

			offset = offset*2;
			nextOffset = nextOffset*2;

			length = nextOffset - offset;			
			if(offset>0){
				nonNullGlyphCount=nonNullGlyphCount+1;
				NSLog(@"%i Glyph index:%i Offset:%x Length:%i", nonNullGlyphCount, i, offset, length );
			}
		}
		
	// LONG OFFSETS
	} else if(_indexToLocFormat==1) {

		[NSException raise:@"NOT verified" format:@""];
		
		// jusr loooping thru all of them to test it
		for( uint i=0; i<_numberOfGlyphs; i++ ){
			
			UInt32 offset, nextOffset, length;		// NB! Different type

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
				NSLog(@"%i Glyph index:%i Offset:%i Length:%i", nonNullGlyphCount, i, offset, length );
			}
		}

	} else {
		[NSException raise:@"Unknown _indexToLocFormat" format:@"eh?"];
	}

	
	CFRelease(locaTable);
}

@end