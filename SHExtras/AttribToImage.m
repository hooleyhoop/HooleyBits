//
//  AttribToImage.m
//  BBExtras
//
//  Created by Jonathan del Strother on 22/02/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AttribToImage.h"


@implementation AttribToImage

-(CIImage*)imageWithString:(NSAttributedString*)string
{
	NSSize size = [string size];

	// Build an offscreen CGContext
	int bytesPerRow = size.width*4;					//bytes per row - one byte each for argb
	bytesPerRow += (16 - bytesPerRow%16)%16;		// ensure it is a multiple of 16
	size_t byteSize = bytesPerRow * size.height;
	if (bitmapData != nil)
		free(bitmapData);
	bitmapData = malloc(byteSize);
	bzero(bitmapData, byteSize); //only necessary if don't draw the entire image
		
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
	CGContextRef cg = CGBitmapContextCreate(bitmapData,
		size.width,
		size.height,
		8, // bits per component
		bytesPerRow,
		colorSpace,
		kCGImageAlphaPremultipliedFirst); //later want kCIFormatARGB8 in CIImage

	// Draw into the offscreen CGContext
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext * nscg = [NSGraphicsContext graphicsContextWithGraphicsPort:cg flipped:NO];
	[NSGraphicsContext setCurrentContext:nscg];
			
		// Here is where you want to do all of your drawing...
		[string drawInRect:NSMakeRect(0,0,size.width/2,size.height)];

	[NSGraphicsContext restoreGraphicsState];
	CGContextRelease(cg);

	// Extract the CIImage from the raw bitmap data that was used in the offscreen CGContext
	CIImage * coreimage = [[CIImage alloc] 
		initWithBitmapData:[NSData dataWithBytesNoCopy:bitmapData length:byteSize] 
		bytesPerRow:bytesPerRow 
		size:CGSizeMake(size.width, size.height) 
		format:kCIFormatARGB8
		colorSpace:colorSpace];
				
	// Housekeeping
	CGColorSpaceRelease(colorSpace); 
		
	return coreimage;
}

-(void)setInputString:(NSString*)newString
{
	if ([_inputString isEqualToString:newString])
		return;
		
	[_inputString release];
	_inputString = [newString copy];
	stringNeedsUpdate = YES;
}

-(void)setFontName:(NSString*)newFont
{
	if ([_fontName isEqualToString:newFont])
		return;
		
	[_fontName release];
	_fontName = [newFont copy];
	stringNeedsUpdate = YES;
}

-(void)setGlyphSize:(double)newSize
{
	if (newSize == _glyphSize)
		return;
	
	_glyphSize = newSize;
	stringNeedsUpdate = YES;
}

-(void)setLeading:(double)newLeading
{
	if (newLeading == _leading)
		return;
	
	_leading = newLeading;
	stringNeedsUpdate = YES;
}

-(void)setKerning:(double)newKerning
{
	newKerning = round(newKerning);
	
	if (newKerning == _kerning)
		return;
	
	_kerning = newKerning;
	stringNeedsUpdate = YES;
}

-(void)setTextAlignment:(NSTextAlignment)newAlignment
{
	if ((newAlignment < NSLeftTextAlignment)||(newAlignment>NSNaturalTextAlignment))
		newAlignment = NSNaturalTextAlignment;
		
	if (newAlignment == _textAlignment)
		return;
		
	_textAlignment = newAlignment;
	stringNeedsUpdate = YES;
}


@end