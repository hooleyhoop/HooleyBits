//
//  TextStyle.m
//  BBExtras
//
//  Created by Jonathan del Strother on 02/03/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "TextStyle.h"
#import "Tagger.h"

@implementation TextStyle

+(id)styleWithTag:(NSDictionary*)tag
{
	return [[[TextStyle alloc] initWithTag:tag] autorelease];
}

-(id)init
{
	if (![super init])
		return nil;
		
	[self setStyleStart:kATSUFromTextBeginning length:kATSUToTextEnd];
	
	//We don't want to specify any font defaults here - if this is used as a inline style, defaults would override the base text.
		
	return self;
}

-(id)initWithTag:(NSDictionary*)tag
{
	if (![self init])
		return nil;
	
	NSNumber* start = [tag objectForKey:BBTagStart];
	NSNumber* end = [tag objectForKey:BBTagEnd];
	if ((start != nil) && (end != nil))
	{
		[self setStyleStart:[start intValue] length:[end intValue]-[start intValue]];
	}
	
	tagName = [[tag objectForKey:BBTagName] copy];
	
	if ([tagName isEqualToString:@"b"]||[tagName isEqualToString:@"strong"])
	{
		bold = YES;
	}
	else if ([tagName isEqualToString:@"i"]||[tagName isEqualToString:@"em"])
	{
		italic = YES;
	}
	else if ([tagName isEqualToString:@"u"])
	{
		underline = YES;
	}
	else if ([tagName isEqualToString:@"span"])
	{
		NSDictionary* attribs = [tag objectForKey:BBTagAttributes];
		NSString* attribColor = [attribs objectForKey:@"color"];
		if (attribColor)
		{
			[self setColor:[attribColor colorFromHex]];
		}
	}
	else
	{
		[self release];
		return nil;
	}
	
	return self;
}

-(void)dealloc
{
	[fontName release];
	[tagName release];
	[color release];
	[super dealloc];
}


-(void)setStyleStart:(UniCharArrayOffset)start length:(UniCharCount)length
{
	styleStart = start;
	styleLength = length;
}

-(void)setFontName:(NSString*)newFontName
{
	if ([fontName isEqualToString:newFontName] || !newFontName || [newFontName isEqualToString:@""])
		return;
	
	[fontName release];
	fontName = [newFontName copy];
	
	applyFontName = YES;
}

-(void)setColor:(NSColor*)targetColor
{
	if ([color isEqual:targetColor])
		return;
		
	color = [[targetColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
	applyColor = YES;
}

-(void)setGlowColor:(NSColor*)targetColor
{
	if ([glowColor isEqual:targetColor])
		return;
		
	glowColor = [[targetColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
	applyColor = YES;
}

-(void)setGlowSize:(float)size
{
	glowSize = size;
}

-(void)setPointSize:(float)size
{
	if (pointSize == size)
		return;
		
	pointSize = size;
	
	applyPointSize = YES;
}


-(void)setKerning:(float)newValue
{
	if (kerning == newValue)
		return;
		
	kerning = newValue;
	applyKerning = YES;
}

#define MAX_ATTRIBS 20

-(void)applyToLayout:(ATSUTextLayout)layout
{
	//Find the existing style at our style location:
	ATSUStyle externalStyle = NULL;
	ATSUStyle* style = malloc(sizeof(ATSUStyle));
	verify_noerr( ATSUGetRunStyle(layout, styleStart, &externalStyle, NULL, NULL));
	if (externalStyle == NULL)
		verify_noerr( ATSUCreateStyle(style) );
	else
		verify_noerr( ATSUCreateAndCopyStyle(externalStyle, style) );
		
	//And apply our own style to the existing style:
	ATSUAttributeTag		tags[MAX_ATTRIBS];
    ByteCount				sizes[MAX_ATTRIBS];
    ATSUAttributeValuePtr	values[MAX_ATTRIBS];
	
	int numAttributes = 0;
	
	Fixed fixedKerning;			//These attributes need to be declared outside of the if-blocks, otherwise they've be out of scope by the time the style is actually used.
	if (applyKerning)
	{
		fixedKerning = X2Fix(kerning);
		tags[numAttributes] =	kATSUAfterWithStreamShiftTag;
		sizes[numAttributes] =	sizeof(Fixed);
		values[numAttributes] = &fixedKerning;
		numAttributes++;
	}
	
	ATSUFontID font;
	if (applyFontName)
	{
		const char* fontNameStr = [fontName fileSystemRepresentation];	
		verify_noerr( ATSUFindFontFromName(fontNameStr, strlen(fontNameStr), kFontFullName, kFontNoPlatform, kFontNoScript, kFontNoLanguage, &font) );
		if (!font)
		{
			NSRunAlertPanel(@"Couldn't load font", [NSString stringWithFormat:@"Couldn't find font %@", fontName],@"OK",nil,nil);
			return;
		}
		tags[numAttributes] =	kATSUFontTag;
		sizes[numAttributes] =	sizeof(ATSUFontID);
		values[numAttributes] = &font;
		numAttributes++;
	}

	Fixed fixedPointSize;
	if (applyPointSize)
	{
		fixedPointSize = X2Fix(pointSize);
		tags[numAttributes] = kATSUSizeTag;
		sizes[numAttributes] = sizeof(Fixed);
		values[numAttributes] = &fixedPointSize;
		numAttributes++;
	}
	
	ATSURGBAlphaColor atsuColor;
	if (applyColor)
	{
		atsuColor.red = [color redComponent];
		atsuColor.green = [color greenComponent];
		atsuColor.blue = [color blueComponent];
		atsuColor.alpha = [color alphaComponent];
		tags[numAttributes] =	kATSURGBAlphaColorTag;
		sizes[numAttributes] =	sizeof(ATSURGBAlphaColor);
		values[numAttributes] = &atsuColor;
		numAttributes++;
	}
	
	Boolean boldFlag;
	if (bold)
	{
		boldFlag = true;
		tags[numAttributes] = kATSUQDBoldfaceTag;
		sizes[numAttributes] = sizeof(Boolean);
		values[numAttributes] = &boldFlag;
		numAttributes++;
	}
	
	Boolean italicFlag;
	if (italic)
	{
		italicFlag = true;
		tags[numAttributes] = kATSUQDItalicTag;
		sizes[numAttributes] = sizeof(Boolean);
		values[numAttributes] = &italicFlag;
		numAttributes++;
	}
	
	Boolean underlineFlag;
	if (underline)
	{
		underlineFlag = true;
		tags[numAttributes] = kATSUQDUnderlineTag;
		sizes[numAttributes] = sizeof(Boolean);
		values[numAttributes] = &underlineFlag;
		numAttributes++;
	}
	
	
	Boolean shadow;
	float blurSize;
	CGSize shadowOffset;
	CGColorRef shadowColor = NULL;
	if ((glowSize > 0.0)&&(glowColor))
	{	
		shadow = true;
		tags[numAttributes] = kATSUStyleDropShadowTag;
		sizes[numAttributes] = sizeof(Boolean);
		values[numAttributes] = &shadow;
		numAttributes++;
		
		blurSize = glowSize*pointSize/20.0;
		tags[numAttributes] = kATSUStyleDropShadowBlurOptionTag;
		sizes[numAttributes] = sizeof(float);
		values[numAttributes] = &blurSize;
		numAttributes++;
		
		float components[4];
		[glowColor getComponents:components];
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef shadowColor = CGColorCreate(colorSpace, components);
		CGColorSpaceRelease(colorSpace);
		tags[numAttributes] = kATSUStyleDropShadowColorOptionTag;
		sizes[numAttributes] = sizeof(CGColorRef);
		values[numAttributes] = &shadowColor;
		numAttributes++;
		
		shadowOffset = CGSizeMake(4,-3);
		tags[numAttributes] = kATSUStyleDropShadowOffsetOptionTag;
		sizes[numAttributes] = sizeof(CGSize);
		values[numAttributes] = &shadowOffset;
		numAttributes++;
	}
	
	if (numAttributes > MAX_ATTRIBS)
	{
		NSLog(@"Increase max style attribs please");
	}
	else if (numAttributes == 0)
	{
		verify_noerr( ATSUDisposeStyle(*style) );
		return;
	}
	
	verify_noerr( ATSUSetAttributes(*style, numAttributes, tags, sizes, values) );
	
	//Add the style to the layout:
	verify_noerr( ATSUSetRunStyle(layout, *style, styleStart, styleLength) );
	
	//And junk the oldstyle.
	if (previousStyle)
	{
		verify_noerr( ATSUDisposeStyle(*previousStyle) );
		free(previousStyle);
	}

	if (shadowColor)
		CGColorRelease(shadowColor);
		
	previousStyle = style;
}

-(double)padding	//Rough guess of the necessary texture padding needed to fit the glow in.
{
	return 0;	//Because it helps Anatol's text scrolly thing, and because we're not using any glows at the moment.

	// return glowSize*pointSize/120.0;
	
	///...  the problem with basing padding off of glow size is that if you're animating the glow size, the text is going to move around.  Hmph.
	return 3.0*pointSize/40.0;
}

@end
