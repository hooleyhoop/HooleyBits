//
//  Atsui.m
//
//  Created by Jonathan del Strother on 11/09/2005.
//  Copyright 2005 Steel Skies. All rights reserved.
//

#import "Atsui.h"
#import "Tagger.h"
#import "TextStyle.h"

@interface Atsui (private) 
-(void)setSamplingScale:(float)scale;
@end;

@implementation Atsui

static ATSUFontFallbacks fallbacks;	//Shared between all layouts

+(void)initialize
{
	// Now we will create a font substitution object and attach it to the layout. Font
	// substitution (or "fallbacks") objects are reusable, thread-safe containers
	// for your font substitution settings. A single fallbacks object can be applied to
	// just one layout, or perhaps every layout in your application, or anywhere inbetween.
	// In general, you only need to create multiple fallbacks objects if you are going to be
	// using different types of fallbacks at the same time. Otherwise, one object should
	// suffice for all layouts in an application.
	
	// Turn on default font substitution, which will search
	// all available fonts on the system for glyphs needed to draw all text in the layout.
	// For more information about the various types of font substitution available, including
	// how you can specify a specific list of fonts to be used as fallbacks, see the definition
	// of ATSUFontFallbackMethod in ATSUnicodeTypes.h.
	//
	verify_noerr( ATSUCreateFontFallbacks(&fallbacks) );
	verify_noerr( ATSUSetObjFontFallbacks(fallbacks, 0, NULL, kATSUDefaultFontFallbacks) );
}

-(id)init
{
	return [self initWithString:@""];
}

-(id)initWithString:(NSString*)string
{
	if (![super init])
		return nil;
		
	verify_noerr( ATSUCreateTextLayout(&layout) );
	verify_noerr( ATSUCreateStyle(&baseStyle) );
		
	textureSize.width =	textureSize.height = -1;
	maxTextureSize = 2048;
	imageHeight = 0;
	
	lineBreakWidth = 9999;
	
	style = [[TextStyle alloc] init];
	
	[self setPointSize:20.0];
	[self setFontName:@"Geneva"];
	[self setColor:[NSColor whiteColor]];
	
	ATSUAttributeTag		tags[3];
    ByteCount				sizes[3];
    ATSUAttributeValuePtr	values[3];
	
	// Now we apply the shared font fallbacks object to our layout.
	tags[0] = kATSULineFontFallbacksTag;
	sizes[0] = sizeof(ATSUFontFallbacks);
	values[0] = &fallbacks;
	verify_noerr( ATSUSetLayoutControls(layout, 1, tags, sizes, values) );

	[self setTextAlignment:kTextAlignCenter];

	[self setString:string];

	textureNeedsRefresh = YES;
	
	technicolor = NO;
	
	return self;
}


-(void)dealloc
{
	verify_noerr( ATSUDisposeTextLayout(layout) );
	verify_noerr( ATSUDisposeStyle(baseStyle) );
	
	[text release];
	if (uniText)
		free(uniText);
		
	[textureData release];
	
	if (buffer)
		free(buffer);
	
	[style release];
	[styleTags release];
	
	
	[super dealloc];
}

//Find the bounds of an arbitary string.
-(NSSize)textBoundsForString:(NSString*)str
{
	//We're dealing with a string that may or may not be our own text string
	//Retain our own string, and replace it with the supplied string.
	// Later, we'll set our own string back to the original value
	NSString* actualString = [text retain];
	[self setString:str];
			
    UniCharArrayOffset			layoutStart, currentStart, currentEnd;
	UniCharCount				layoutLength;
	// FInd out about this layout's text buffer
	verify_noerr( ATSUGetTextLocation(layout, NULL, NULL, &layoutStart, &layoutLength, NULL) );
	
	// Get the soft line breaks for the line width:
	ATSUAttributeTag		tags[1];
    ByteCount				sizes[1];
    ATSUAttributeValuePtr	values[1];
	Fixed lineWidth = X2Fix(lineBreakWidth);
	tags[0] = kATSULineWidthTag;
	sizes[0] = sizeof(Fixed);
	values[0] = &lineWidth;
	verify_noerr( ATSUSetLayoutControls(layout, 1, tags, sizes, values) );
	
	ItemCount numSoftBreaks;
	verify_noerr( ATSUBatchBreakLines (layout, kATSUFromTextBeginning, kATSUToTextEnd, lineWidth, &numSoftBreaks) );

	// Obtain a list of all the line break positions
	verify_noerr( ATSUGetSoftLineBreaks(layout, layoutStart, layoutLength, 0, NULL, &numSoftBreaks) );
	UniCharArrayOffset* theSoftBreaks = (UniCharArrayOffset *) malloc(numSoftBreaks * sizeof(UniCharArrayOffset));
	verify_noerr( ATSUGetSoftLineBreaks(layout, layoutStart, layoutLength, numSoftBreaks, theSoftBreaks, &numSoftBreaks) );

	//Loop over the soft breaks, rendering one by one
	currentStart = layoutStart;
	float y = 0.0;
	float maxWidth = 0.0;
	int j;
	for (j=0; j <= numSoftBreaks; j++) 
	{
		currentEnd = ((numSoftBreaks > 0 ) && (numSoftBreaks > j)) ? theSoftBreaks[j] : layoutStart + layoutLength;

		// Get the bounds of the current line and amend our y & maxWidth values to reflect the new lines
		ATSUTextMeasurement	leftEdge, rightEdge, topEdge, bottomEdge;
		ATSUGetUnjustifiedBounds(layout,currentStart,currentEnd-currentStart,&leftEdge,&rightEdge,&topEdge,&bottomEdge);

		float totalLineHeight = Fix2X(topEdge) + Fix2X(bottomEdge);
		y += totalLineHeight;
		
		if (j>0)
			y += leading*totalLineHeight*0.25;	//Leading is applied manually, but we don't want any on the first line
		
		float width = Fix2X(rightEdge) - Fix2X(leftEdge);
		if (width > maxWidth)
			maxWidth = width;
		
		// Prepare for next line
		currentStart = currentEnd;
	}
	free (theSoftBreaks);
	
	//Revert to our real string:
	[self setString:actualString];
	[actualString release];
	
	//Might occur due to leading:
	if (y<=0) y=1;
	if (maxWidth<=0) maxWidth=1;
	
	//Marydale is a dumb font, and doesn't seem to correctly report its line height.  Add 35% of line to the calculations.
	if (y>1 && maryDaleHack)
	{
		float averageLineHeight = y/(float)(numSoftBreaks+1);
		y += 0.35*averageLineHeight;
	}
	
	double padding = [style padding];
	return NSMakeSize(ceilf(maxWidth)+padding*2,ceilf(y)+padding*2);
}

-(NSSize)textBounds
{
	return [self textBoundsForString:text];
}

//Doesn't take into account linebreaks!
-(UInt32)offsetForPosition:(NSPoint)pos
{
	UniCharArrayOffset primaryOffset = 0;
	Boolean isLeading = YES;
	UniCharArrayOffset secondaryOffset = 0;
	verify_noerr(ATSUPositionToOffset(layout,X2Fix(pos.x),X2Fix(textureSize.height - pos.y),&primaryOffset,&isLeading,&secondaryOffset));
	
	if (primaryOffset != secondaryOffset)
		NSLog(@"Secondary cursor offsets not implemented yet");
	
	return primaryOffset;
}

-(void)applyStyles
{
	//Clear any previously applied styles:
	assert(layout != NULL);
	verify_noerr( ATSUSetRunStyle(layout,baseStyle,kATSUFromTextBeginning, kATSUToTextEnd));

	[style applyToLayout:layout];

	NSEnumerator *enumerator1 = [styleTags objectEnumerator];
	id tag;
	while ((tag = [enumerator1 nextObject])) 
	{
		TextStyle* inlineStyle = [TextStyle styleWithTag:tag];
		[inlineStyle applyToLayout:layout];
	}
}


-(void)generateStyles
{
	NSString* displayText = nil;
	Tagger* tagger = nil;
	if (htmlEnabled)
	{
		tagger = [[Tagger alloc] initWithString:text];
		[tagger parseString];

		[styleTags release];
		styleTags = [[tagger tags] retain];
		
		displayText = [tagger parsedString];
	}
	else
	{
		displayText = text;
	}

	
	// Before assigning text to the layout, we must first convert the string we plan to draw
	// from a CFStringRef into an array of UniChar.
    // Extract the raw Unicode from the CFString
	if (uniText)
		free(uniText);
		
    textLength = CFStringGetLength((CFStringRef)displayText);
    uniText = (UniChar *)malloc(textLength * sizeof(UniChar));
    CFStringGetCharacters((CFStringRef)displayText, CFRangeMake(0, textLength), uniText);

    // Attach the resulting UTF-16 Unicode text to the layout
    verify_noerr( ATSUSetTextPointerLocation(layout, uniText, kATSUFromTextBeginning, kATSUToTextEnd, textLength) );
	
	// To get ATSUI to apply the fallback settings on-the-fly, use the following setting.
	// To apply the settings manually, call the function ATSUMatchFontsToText().
	verify_noerr( ATSUSetTransientFontMatching(layout, true) );

	[tagger release];
}

-(void)drawTextIntoContext:(CGContextRef)cgContext
{
	ATSUAttributeTag		tags[2];
    ByteCount				sizes[2];
    ATSUAttributeValuePtr	values[2];
	
	tags[0] = kATSUCGContextTag;
	sizes[0] = sizeof(CGContextRef);
	values[0] = &cgContext;
	verify_noerr( ATSUSetLayoutControls(layout, 1, tags, sizes, values) );
	
    UniCharArrayOffset			layoutStart, currentStart, currentEnd;
	UniCharCount				layoutLength;
	// FInd out about this layout's text buffer
	verify_noerr( ATSUGetTextLocation(layout, NULL, NULL, &layoutStart, &layoutLength, NULL) );

	// Get the soft line breaks for the line width:
	ItemCount            numSoftBreaks;
	Fixed lineWidth = X2Fix(lineBreakWidth);
	verify_noerr( ATSUBatchBreakLines (layout, kATSUFromTextBeginning, kATSUToTextEnd, lineWidth, &numSoftBreaks) );

	// Obtain a list of all the line break positions
	verify_noerr( ATSUGetSoftLineBreaks(layout, layoutStart, layoutLength, 0, NULL, &numSoftBreaks) );
	UniCharArrayOffset* theSoftBreaks = (UniCharArrayOffset *) malloc(numSoftBreaks * sizeof(UniCharArrayOffset));
	verify_noerr( ATSUGetSoftLineBreaks(layout, layoutStart, layoutLength, numSoftBreaks, theSoftBreaks, &numSoftBreaks) );

	Fixed actualLineWidth = X2Fix(textureSize.width);
	tags[0] = kATSULineWidthTag;
	sizes[0] = sizeof(Fixed);
	values[0] = &actualLineWidth;
	verify_noerr( ATSUSetLayoutControls(layout, 1, tags, sizes, values) );
	
	
	//Loop over the soft breaks, rendering one by one
	currentStart = layoutStart;
	
	double padding = [style padding];
	float x = padding;
	float y = padding;
	float cgY;
	lineCount = 0;
	int j;
	for (j=0; j <= numSoftBreaks; j++) 
	{
		currentEnd = ((numSoftBreaks > 0 ) && (numSoftBreaks > j)) ? theSoftBreaks[j] : layoutStart + layoutLength;
		
		//We want to clamp the max. number of characters displayed to the displayPercentage, for easy text-reveals.
		BBCLAMP(currentEnd,0, lround(displayPercentage*layoutLength) + layoutStart);
		
		if (currentEnd <= currentStart)
			break;
			
		lineCount++;

		// This is the height of a line, the ascent and descent.
		//
		// The ascent is the amount of text that extends above the baseline.
		// The descent is the amount of text that extends below the baseline.
		// (The y-coordinate that is passed to ATSUDrawText is where the baseline will be drawn.)
		//
		// Many fonts also include "leading", which is extra space specified by the font designer
		// to be applied below the baseline when spacing apart lines. Leading is usually included
		// when fetching the descent, unless the kATSLineIgnoreFontLeading layout control is set,
		// or when using ATSUGetAttribute to fetch the descent directly from a style (in that case,
		// use kATSULeadingTag to fetch the leading separately).
		Fixed ascent, descent;
		ATSUGetLineControl(layout, currentStart, kATSULineAscentTag, sizeof(ATSUTextMeasurement), &ascent, NULL);
		ATSUGetLineControl(layout, currentStart, kATSULineDescentTag, sizeof(ATSUTextMeasurement), &descent, NULL);

		float totalLineHeight = Fix2X(ascent) + Fix2X(descent);

		// Make room for the area above the baseline.
		y += Fix2X(ascent);
		if (j>0)
			y += leading*totalLineHeight*0.25;	//Leading is applied manually, but we don't want any on the first line
		cgY = textureSize.height - y;

		// Draw the text
		verify_noerr( ATSUDrawText(layout, currentStart, currentEnd - currentStart, X2Fix(x), X2Fix(cgY)) );

		// Make room for the area beloww the baseline
		y += Fix2X(descent);
		
		// Prepare for next line
		currentStart = currentEnd;
	}
	free (theSoftBreaks);
}


-(void)createTexture
{
	if (textureData)
	{
		[textureData release];
		textureData = nil;
	}
	
	[self applyStyles];
			
	textureSize = [self textBoundsForString:text];
		
	if ((textureSize.width < lineBreakWidth)&&(lineBreakWidth != 9999.0))
		textureSize.width = lineBreakWidth;

	//If it doesn't fit, just try and fit everything into the max. texture size:
	if (textureSize.width > maxTextureSize)
		textureSize.width = maxTextureSize;
	if (textureSize.height > maxTextureSize)
		textureSize.height = maxTextureSize;
		
	if (imageHeight > 0)
		textureSize.height = imageHeight;
		
		
	int numComponents = (technicolor ? 4 : 1);
	int bytesPerRow = textureSize.width*numComponents;
	bytesPerRow += (16-bytesPerRow%16)%16;
	size_t new_bufferSize = bytesPerRow *sizeof(char) * textureSize.height;
	if (new_bufferSize != bufferSize)
	{
		if (buffer)
			free(buffer);
		NSLog(@"Allocating new buffer");
		bufferSize = new_bufferSize;
		buffer = valloc(bufferSize);
	}
	
	bzero(buffer,bufferSize);
	    
	if (!buffer)
	{
		NSLog(@"Unable to allocate buffer for %@, giving up.  Let me know if this happens.", text);
		return;
	}
		
	
	Rect rect;
	rect.top = 0;
	rect.bottom = textureSize.height;
	rect.left = 0;
	rect.right = textureSize.width;

	CGColorSpaceRef colorSpace = (technicolor ? CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB ) : NULL);
	CGContextRef cgContext = CGBitmapContextCreate(buffer,textureSize.width,textureSize.height,8,bytesPerRow,colorSpace,technicolor ? kCGImageAlphaPremultipliedLast : kCGImageAlphaOnly);

	if (cgContext== NULL)
    {
		NSLog(@"Context not created");
		return;
    }
	
	[self drawTextIntoContext:cgContext];
	
    // Tear down the CGContext
	CGContextFlush(cgContext);
	CGContextRelease((CGContextRef)cgContext);
	
	CGColorSpaceRelease(colorSpace);

	textureData = [[NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:NO] retain];
	
	textureNeedsRefresh = NO;
}

-(void)setDisplayPercentage:(float)_displayPercent
{
	displayPercentage = _displayPercent;
	BBCLAMP(displayPercentage, 0, 1);
	textureNeedsRefresh = YES;
}

-(void)setLineBreakWidth:(float)_lineBreakWidth
{
	if (_lineBreakWidth == 0.0)
		_lineBreakWidth = 9999;
		
	if (lineBreakWidth == _lineBreakWidth)
		return;

	lineBreakWidth = _lineBreakWidth;

	textureNeedsRefresh = YES;
}

-(void)setImageHeight:(float)_height
{
	if (_height == imageHeight)
		return;

	imageHeight = _height;
	
	textureNeedsRefresh = YES;
}

-(void)setFontName:(NSString*)newFontName
{
	maryDaleHack = [[newFontName lowercaseString] hasPrefix:@"marydale"];

	[style setFontName:newFontName];				
	textureNeedsRefresh = YES;
}

-(void)setColor:(NSColor*)targetColor
{
	[style setColor:targetColor];
	textureNeedsRefresh = YES;
}

-(BOOL)colorEnabled
{
	return technicolor;
}

-(void)setColorEnabled:(BOOL)val
{
	technicolor = val;
	textureNeedsRefresh = YES;
}

-(BOOL)htmlEnabled
{
	return htmlEnabled;
}

-(void)setHTMLEnabled:(BOOL)val
{
	htmlEnabled = val;
	[styleTags release];
	styleTags = nil;
	[self generateStyles];
	textureNeedsRefresh = YES;
}

-(void)setGlowColor:(NSColor*)targetColor
{
	[style setGlowColor:targetColor];
	textureNeedsRefresh = YES;
}
-(void)setGlowSize:(float)size
{
	[style setGlowSize:size];
	textureNeedsRefresh = YES;
}

-(void)setPointSize:(float)size
{
	[style setPointSize:size];
	textureNeedsRefresh = YES;
}


-(void)setLeading:(float)newValue
{
	//ATSUI style/layout controls don't support negative leading, so instead we're going to position lines manually
	if (leading == newValue)
		return;
		
	leading = newValue;	
	textureNeedsRefresh = YES;
}

-(void)setKerning:(float)newValue
{
	[style setKerning:newValue];
	textureNeedsRefresh = YES;
}

-(void)setString:(NSString*)newText
{
	if (newText == text)
		return;
	if ([newText isEqualToString:text])
		return;
		
	[text release];
	text = [newText copy];
	
	[self generateStyles];

	textureNeedsRefresh = YES;
}

-(void)setTextAlignment:(BBTextAlignment)_alignment
{
	if (textAlignment == _alignment)
		return;
	
	textAlignment = _alignment;
	
	
	ATSUAttributeTag		tags[3];
    ByteCount				sizes[3];
    ATSUAttributeValuePtr	values[3];
	
	Fract alignment;
	switch(textAlignment)
	{
		case kTextAlignLeft : alignment = kATSUStartAlignment; break;
		case kTextAlignCenter : alignment = kATSUCenterAlignment; break;
		case kTextAlignRight : alignment = kATSUEndAlignment; break;
		case kTextAlignJustified : alignment = kATSUStartAlignment; break;
		default : NSLog(@"Alignment not recognised"); 
				alignment = kATSUStartAlignment; break;
	}
		 
	tags[0] = kATSULineFlushFactorTag;
	sizes[0] = sizeof(Fract);
	values[0] = &alignment;
	
	tags[1] = kATSULineJustificationFactorTag;
	sizes[1] = sizeof(Fract);
	Fract justification = (textAlignment == kTextAlignJustified) ? kATSUFullJustification : kATSUNoJustification;
	values[1] = &justification;
	
	tags[2] = kATSULineLayoutOptionsTag;
	sizes[2] = sizeof(ATSLineLayoutOptions);
	ATSLineLayoutOptions options = kATSLineLastNoJustification;
	values[2] = &options;
		
	verify_noerr( ATSUSetLayoutControls(layout, 3, tags, sizes, values) );
	
	textureNeedsRefresh = YES;
}

-(void)setMaxTextureSize:(unsigned int)newValue
{
	if (maxTextureSize == newValue)
		return;
	maxTextureSize = newValue;
	textureNeedsRefresh = YES;
}

-(NSData*)dataBuffer
{
	if (textureNeedsRefresh)
		[self createTexture];
	return textureData;
}

-(NSSize)textureSize
{
	return textureSize;
}

-(int)lineCount
{
	return lineCount;
}


-(BOOL)textureNeedsRefresh
{
	return textureNeedsRefresh;
}
@end
