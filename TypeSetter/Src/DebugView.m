//
//  DebugView.m
//  TypeSetter
//
//  Created by steve hooley on 11/03/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "DebugView.h"
#import "GlyphRenderer.h"
#import "PlaceHolderImage.h"
#import "ImageWindow.h"
#import "WindowController.h"
#import "FontWrapper.h"


@implementation DebugView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setNeedsDisplay:YES];
    }
    return self;
}

- (void)awakeFromNib {
	
	PlaceHolderImage *tempImage = [PlaceHolderImage placeHolderWithSize:CGSizeMake(400,400)];
	ImageWindow *tempImageWindow = [ImageWindow showImage:tempImage];
}

// highest-level = framesetter. The framesetter object uses other Core Text objects, such as typesetter, line, and glyph run objects, to accomplish its work: creating frame objects, which are lines of glyphs laid out within a shape.
// Clients who need to intervene in the text layout process at a lower level can deal with lower level objects, such as line objects. Line objects can draw themselves individually or be used to obtain glyph information
// NSAttributedString = CFAttributedStringRef
// framesetter output is a frame object containing an array of lines. The frame can draw itself directly into a graphic context. 
// A typesetter performs the fundamental text layout operations of character-to-glyph conversion and positioning of those glyphs into lines.
// A line object contains glyph-run objects.
// A glyph run is a set of consecutive glyphs sharing the same attributes and direction. Glyph runs can draw themselves into a graphic context,
// NSFont = CTFontRef
// NSFontDescriptor = CTFontDescriptorRef

//CGFont has CGFontGetGlyphBBoxes and CGFontGetGlyphAdvances
//
//i need a very Specific idea here!
CGImageRef _createPNGWithURL( CFURLRef URL ) {
	
	CGDataProviderRef src = CGDataProviderCreateWithURL(URL);
	CGImageRef image = CGImageCreateWithPNGDataProvider(src, nil, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(src);
	return image;
}

- (void)drawRect:(NSRect)rect {

	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]  graphicsPort];
	
	FontWrapper *hooFont = [[[FontWrapper alloc] initWithName:@"Georgia" size:72.0f] autorelease];

	GlyphRenderer *gr = [[GlyphRenderer alloc] init];

	if(false)
	{
		[[NSColor blueColor] set];
		NSRectFill(rect);
		
		// Initialize a graphics context and set the text matrix to a known value.
		
		/* 
		 * Use Core Text to draw some strings 
		 */
		CGContextSetTextMatrix( context, CGAffineTransformIdentity );
		
		// Initialize a rectangular path.
		CGMutablePathRef path = CGPathCreateMutable();
		CGRect bounds = CGRectMake( 10.0f, 10.0f, 200.0f, 200.0f );
		CGPathAddRect(path, NULL, bounds);
		
		// Initialize an attributed string.
		CFStringRef string = CFSTR("We hold this truth to be self-evident, that  everyone is created equal.");
		CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), string);
		
		// Create a color and add it as an attribute to the string.
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat components[] = { 1.0f, 0.0f, 0.0f, 0.8f };
		CGColorRef red = CGColorCreate(rgbColorSpace, components);
		CGColorSpaceRelease(rgbColorSpace);
		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 50), kCTForegroundColorAttributeName, red);
		
		// Create the framesetter with the attributed string.
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
		CFRelease(attrString);
		
		// Create the frame and draw it into the graphics context
		CTFrameRef frame = CTFramesetterCreateFrame( framesetter, CFRangeMake(0, 0), path, NULL);
		CFRelease(framesetter);
		CTFrameDraw(frame, context);
		CFRelease(frame);
		
		/* 
		 * Just try drawing a normal image
		 *
		 */
		NSString *testImagePath = [[NSBundle mainBundle] pathForResource:@"Picture 4" ofType:@"png"];
		NSURL *testImageURL = [NSURL fileURLWithPath:testImagePath];
		CGImageRef testImage = _createPNGWithURL( (CFURLRef)testImageURL );
		NSAssert( testImage, @"cant find test image in bundle");
		
		CGContextSaveGState( context );
		CGContextSetAllowsAntialiasing( context, false );
		CGContextSetInterpolationQuality( context, kCGInterpolationNone );
		CGContextDrawImage( context, CGRectMake( 0, 0, CGImageGetWidth(testImage), CGImageGetHeight(testImage)), testImage );
		CGContextRestoreGState( context );
		
		CGImageRelease( testImage );
		
		/* 
		 * Draw a glyph image
		*/
		CGImageRef glyphImage = [gr glyphImage];
		CGContextDrawImage( context, CGRectMake( 0, 0, CGImageGetWidth(glyphImage), CGImageGetHeight(glyphImage)), glyphImage );
		CGImageRelease( glyphImage );
	}
	
	// question
	// [gr inspectFont:@"FreeSans" glyph:@"AB" size:36];
	// [gr inspectFont:@"FreeSans" glyph:@"AC" size:36]; // c is offset left
	// [gr inspectFont:@"FreeSans" glyph:@"AD" size:36]; // D is kerned left
	// [gr inspectFont:@"FreeSans" glyph:@"AE" size:36]; // e is offset right
	
	/* 
	 *
	 * A Totally different program from here on down
	 *
	 *
	*/
	NSString *textToDraw = [[self.window windowController] textToDraw];

//1	[gr drawNonOverlappingGlphs:textToDraw inContext:context];
//2	[gr randomFont_drawNonOverlappingGlphs:textToDraw inContext:context];
	
	// As is, doesnt use kerning. If we use the bezier wont be hinted. cant find the symbols to draaw glyphs directly
//	[gr drawWithSuggestedAdvance:@"FreeSans" text:textToDraw inContext:context];

	[gr useCoreText:@"Georgia" text:textToDraw inContext:context];

//	[gr testOverlapDrawing:context];

//	[gr renderAString:context];

	[gr release];
}

- (IBAction)pdfIfy:(id)sender {
	
	NSData *pdfData = [self dataWithPDFInsideRect: [self bounds]];
	NSPDFImageRep *pdfRep = [NSPDFImageRep imageRepWithData:pdfData];
    NSData *imageData = [pdfRep PDFRepresentation];

	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setExtensionHidden:NO];
	[savePanel setAllowedFileTypes:[NSImage imageTypes]];
	[savePanel setAllowsOtherFileTypes:NO];
	NSInteger runResult = [savePanel runModalForDirectory:[[NSString stringWithString:@"~/Desktop"] stringByExpandingTildeInPath] file:@"Picture.pdf"];
	if(runResult == NSOKButton)
	{
		[imageData writeToURL:[savePanel URL] atomically:YES];
	}
}


@end
