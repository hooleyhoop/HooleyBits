//
//  BBStringRenderer.m
//  BBExtras
//
//  Created by Jonathan del Strother on 07/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "BBStringRenderer.h"
#import "QCClasses.h"
#import <OpenGL/gl.h>
#import "Atsui.h"

#if __BIG_ENDIAN__
	#define GL_COLOR_TYPE GL_UNSIGNED_INT_8_8_8_8_REV
#else
	#define GL_COLOR_TYPE GL_UNSIGNED_INT_8_8_8_8
#endif

@implementation BBTextPlus

+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 3;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return NO;
}
//
//+ (int)timeMode
//{
//	return 1;	//Allow external time patch
//}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [BBStringRendererUI class];
}

	
- (id)initWithIdentifier:(id)fp8
{
	// Do your initialization of variables here 
	if (![super initWithIdentifier:fp8])
		return nil;
	
	[inputLeading setDoubleValue:0.0];
	[inputLeading setMinDoubleValue:-4.0];
	[inputLeading setMaxDoubleValue:+4.0];

	[inputKerning setDoubleValue:0.0];
	[inputKerning setMinDoubleValue:-2.0];
	[inputKerning setMaxDoubleValue:2.0];
	
	[inputString setStringValue:@"Hello World"];
	
	[inputFontName setStringValue:@"Lucida Grande"];
	
	
	[inputGlyphCount setDoubleValue:1.0];
	[inputGlyphCount setMinDoubleValue:0.0];
	[inputGlyphCount setMaxDoubleValue:1.0];
	
	[inputGlyphSize setDoubleValue:0.1];
//	[inputGlyphSize setMinDoubleValue:6.0];
//	[inputGlyphSize setMaxDoubleValue:200.0];
	
	[inputTextAlignment setDoubleValue:0.0];
	[inputTextAlignment setMinDoubleValue:0.0];
	[inputTextAlignment setMaxDoubleValue:3.0];
	
	[inputWidth setMinDoubleValue:0.0];
	
	[inputHeight setDoubleValue:0.0];

	atsui = [[Atsui alloc] initWithString:[inputString stringValue]];
	
	return self;
}
	
- (void)dealloc
{
	[atsui release];
	[bitmapImage release];
	[super dealloc];
}
	
- (id)setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	[super setup:fp8];
	
	//On closing the viewer, we lose our outputImage image.  Need to set it up again on reopen, so...
	forceRefresh = YES;
	
	return fp8;
}

-(BOOL)colorEnabled
{
	return [atsui colorEnabled];
}

-(void)setColorEnabled:(BOOL)value
{
	[atsui setColorEnabled:value];
	[self stateUpdated];
}

-(BOOL)htmlEnabled
{
	return [atsui htmlEnabled];
}
-(void)setHTMLEnabled:(BOOL)value
{
	[atsui setHTMLEnabled:value];
	[self stateUpdated];	
}

// restore color/html state
- (BOOL)setState:(id)state
{
	[super setState: state];
	BOOL colorEnabled = [[state valueForKey:@"colorEnabled"] boolValue];
	BOOL htmlEnabled = [[state valueForKey:@"htmlEnabled"] boolValue];
	[atsui setColorEnabled:colorEnabled];
	[atsui setHTMLEnabled:htmlEnabled];
	return TRUE;
}

// return the color/html state
- (id)state
{
	NSMutableDictionary* state = [[super state] mutableCopy];
	[state setValue:[NSNumber numberWithBool:[atsui colorEnabled]] forKey:@"colorEnabled"];
	[state setValue:[NSNumber numberWithBool:[atsui htmlEnabled]] forKey:@"htmlEnabled"];
	return [state autorelease];
}


-(void)updateString
{
	[atsui setFontName:[inputFontName stringValue]];
	[atsui setDisplayPercentage:[inputGlyphCount doubleValue]];
	[atsui setPointSize:overSampling*viewHeight*[inputGlyphSize doubleValue]];
	[atsui setString:[inputString stringValue]];
	[atsui setGlowSize:[inputGlowSize doubleValue]];
	[atsui setGlowColor:[inputGlowColor value]];
	[atsui setLineBreakWidth:overSampling*targetWidth];
	[atsui setImageHeight:overSampling*roundtol(viewHeight*[inputHeight doubleValue])];
	[atsui setTextAlignment:roundtol([inputTextAlignment doubleValue])];
	[atsui setLeading:[inputLeading doubleValue]];
	[atsui setKerning:[inputKerning doubleValue]*overSampling];
	[atsui setMaxTextureSize:[QCOpenGLContext maxSupportedTextureSizeForTarget:GL_TEXTURE_RECTANGLE_EXT]];

	if (![atsui textureNeedsRefresh] && !forceRefresh)
		return;
		
	forceRefresh = NO;
	
	NSData* dataBuffer = [atsui dataBuffer];
	NSSize textureSize = [atsui textureSize];

	if ((textureSize.width > 0)&&(textureSize.height > 0))
	{
		BOOL color = [atsui colorEnabled];
		int bytesPerRow = textureSize.width * (color ? 4 : 1);
		bytesPerRow += (16 - bytesPerRow%16)%16;		// ensure it is a multiple of 16
		int format = color ? GL_RGBA : GL_LUMINANCE;
		int type = GL_UNSIGNED_BYTE; //color ? GL_COLOR_TYPE : GL_UNSIGNED_BYTE;
		
		char* buffer = (char*)[dataBuffer bytes];
		if (buffer)
		{	
			//If our rendering dimensions changed, recreate our bitmap
			if ((prevBytesPerRow!=bytesPerRow)||(prevHeight!=textureSize.height)|| !bitmapImage)
			{
				prevBytesPerRow = bytesPerRow;
				prevHeight = textureSize.height;
				if (bitmapImage)
					[bitmapImage release];
					
				bitmapImage = [[QCGLBitmapImage alloc] initWithBuffer:buffer bytesPerRow:bytesPerRow format:format type:type pixelsWide:textureSize.width pixelsHigh:textureSize.height releaseCallback:NULL callbackUserInfo:0 options:NULL];
				[outputImage setImageValue:bitmapImage];
			}
			else	//Same rendering dimensions?  Just tell the bitmap that its contents have changed
			{
				[bitmapImage didChangeBytes];	//Maybe we should be using (willChangeBytes -> update ATSUI -> didChangeBytes) ?
			}
		}
	}
	else
	{
		[outputImage setImageValue:nil];
	}
	
	[outputLineCount setDoubleValue:[atsui lineCount]];
}

- (BOOL)execute:(QCOpenGLContext*)context time:(double)fp12 arguments:(id)fp20
{
	// This is where the execution of your patch happens.
	// Everything in this method gets executed once
	// per 'clock cycle', which is available in fp12 (time).

	// Read/Write any ports in here too.
	
	viewHeight = [context viewportResolution].height;
	targetWidth = [inputWidth doubleValue] * [context viewportResolution].width;
	
	if (targetWidth > 1300)
		overSampling = 1.25;
	else
		overSampling = 1.5;
				
	[self updateString];

	QCGLBitmapImage* image = [outputImage imageValue];

	if (image != nil)
	{
		if ([inputWidth doubleValue] > 0.0)
			[outputWidth setDoubleValue:[inputWidth doubleValue]];
		else
			[outputWidth setDoubleValue:[image pixelsWide]/[context viewportResolution].width];
			
		
		if ([inputHeight doubleValue] > 0.0)
			[outputHeight setDoubleValue:[inputHeight doubleValue]];
		else
			[outputHeight setDoubleValue:[outputWidth doubleValue] * ([image pixelsHigh]/(float)[image pixelsWide])];
	}

	return YES;

}

@end
