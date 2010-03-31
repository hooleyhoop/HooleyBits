//
//  SHPhotoshopFileStuff.m
//  SHExtras
//
//  Created by Steven Hooley on 23/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHPhotoshopFileStuff.h"
#import "SHPhotoshopImport.h"
#include <Carbon/Carbon.h>


//
// Create a colorspace for the main display
// 
CGColorSpaceRef getDisplayRGBColorSpace(void)
{
    CMProfileRef sysprof = NULL;
    CGColorSpaceRef dispColorSpace = NULL;

    // Get the system profile (which represents the profile for the main display
    if (CMGetSystemProfile(&sysprof) == noErr)
    {
	// Build a CGColorSpaceRef from the system profile
	dispColorSpace = CGColorSpaceCreateWithPlatformColorSpace(sysprof);
	CMCloseProfile(sysprof);
    }
    return dispColorSpace;
}

/*
 *
*/
@implementation SHPhotoshopFileStuff


//=========================================================== 
// - openImageURL
//=========================================================== 
+ (void)openImageURL:(NSURL*)url patch:(SHPhotoshopImport*)aPatch shouldCrop:(BOOL)cropFlag
{
    // use ImageIO to get the CGImage, image properties, and the image-UTType
    //
    Boolean gotFSRef = false;
    FSRef myBundleRef;
    OSStatus 	status;
    FSSpec 	fileFSSpec;
    OSErr 	err;
    GraphicsImportComponent	graphicsImporter;
	unsigned long imageCount, imageIndex;
	ImageDescriptionHandle desc = NULL;
	Rect naturalBounds;
	CGImageRef image = NULL;
	MatrixRecord matrix;
	UserData userData = 0;
	
    // get an FSRef for our file
    gotFSRef = CFURLGetFSRef((CFURLRef)url, &myBundleRef);
    // get an FSSpec for the same file, which we can
    // pass to GetGraphicsImporterForFile below
    status = FSGetCatalogInfo(&myBundleRef, kFSCatInfoNone, NULL, NULL, &fileFSSpec, NULL);	
	
    // find a graphics importer for our image file
    err = GetGraphicsImporterForFile(&fileFSSpec, &graphicsImporter);
	err = GraphicsImportGetNaturalBounds( graphicsImporter, &naturalBounds );
	
	// ask the graphics importer how many images there are in this file
	err = GraphicsImportGetImageCount( graphicsImporter, &imageCount );
	
    CGImageSourceRef isr = CGImageSourceCreateWithURL( (CFURLRef)url, NULL);
  	NSLog(@"SHPhotoshopImportUI: There are %i images", imageCount);
	
	// [aPatch resetOutputs];

	for( imageIndex = 1; imageIndex <= imageCount; imageIndex++ ) 
	{	
		// set the index value for the image we want to draw
		err = GraphicsImportSetImageIndex( graphicsImporter, imageIndex );
		
		// each image in the file can have different dimensions, depth, etc.
		// if the image has an alpha, use StraightAlpha graphics mode to draw
		err = GraphicsImportGetImageDescription( graphicsImporter, &desc );
		//NSLog(@"ERROR: Image Depth is %i", (*desc)->depth);

		int alphaMode = graphicsModePreWhiteAlpha;
		// graphicsModePreWhiteAlpha     = 257,
		// graphicsModePreBlackAlpha     = 258,
	
//		if(premultFlag)
//			alphaMode = graphicsModeStraightAlpha;
		if( (*desc)->depth == 32 ){
			err = GraphicsImportSetGraphicsMode( graphicsImporter, alphaMode, NULL );
		} else {
			err = GraphicsImportSetGraphicsMode( graphicsImporter, ditherCopy, NULL );
		//	NSLog(@"ERROR: Image Depth is %@");
		}

		SetIdentityMatrix( &matrix );
		GraphicsImportGetDefaultMatrix( graphicsImporter, &matrix );
		err = GraphicsImportSetMatrix( graphicsImporter, &matrix );
		
		err = GraphicsImportCreateCGImage(graphicsImporter, &image, kGraphicsImportCreateCGImageUsingCurrentSettings );
		
		// create a new user data structure
		err = NewUserData( &userData );
		// extract metadata from an image and add it to an already alocated user data structure
		err = GraphicsImportGetMetaData( graphicsImporter, userData );
		
		// [SHPhotoshopFileStuff showUserData:&userData importer:&graphicsImporter];
	
		if(isr)
		{
			// options for getting image and meta data
			// - create a 'cached' image
			// - allow float pixel data
	//d		NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceShouldCache, (id)kCFBooleanTrue, (id)kCGImageSourceShouldAllowFloat, NULL];
	//d		image = CGImageSourceCreateImageAtIndex(isr, imageIndex, options);
			// get the meta data for the image at index 0
	//d		NSDictionary* meta = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(isr, imageIndex, (CFDictionaryRef)options);
			if(image)
			{
				// _imageProperties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(isr, 0, (CFDictionaryRef)_imageProperties);            
				// _imageUTType = (NSString*)CGImageSourceGetType(isr);
				// [_imageUTType retain];

				/* does it have an alpha ?*/
				
				// create offscreen context..
				// Create the bitmap
				void  *bitmapData;
				CGContextRef bitmapContext = NULL;
				CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

				CGImageRef cachedImage;

				int width2 = CGImageGetWidth(image);
				int height2 = CGImageGetHeight(image);

				float xPos=0, yPos=0, xTranslate=0, yTranslate=0;

				/* see if the natural bounds have changed */
				Rect layerNaturalBounds;
				err = GraphicsImportGetBoundsRect( graphicsImporter, &layerNaturalBounds );
				if( noErr != err ){
					layerNaturalBounds.left = 0;
					layerNaturalBounds.right = width2;
					layerNaturalBounds.top = 0;
					layerNaturalBounds.bottom = height2;
				}
				// printf( "Image has bounds rectangle (%d,%d,%d,%d).\n", layerNaturalBounds.left, layerNaturalBounds.top, layerNaturalBounds.right, layerNaturalBounds.bottom );
				
				int	bitsPerPixel, bitmapBytesPerRow, bitmapByteCount;
				int width3, height3;
				bitsPerPixel = CGImageGetBitsPerPixel(image);

				if(GetMatrixType(&matrix)==translateMatrixType)
				{
					int a1 = matrix.matrix[0][0];
					int a7 = matrix.matrix[2][0];
					int a8 = matrix.matrix[2][1];
					// int a2 = matrix.matrix[0][1]; // int a3 = matrix.matrix[0][2]; // int a4 = matrix.matrix[1][0]; // int a5 = matrix.matrix[1][1]; // int a6 = matrix.matrix[1][2]; // int a9 = matrix.matrix[2][2];
					// NSLog(@"%i, %i, %i", a1, a2, a3); NSLog(@"%i, %i, %i", a4, a5, a6); NSLog(@"%i, %i, %i", a7, a8, a9); NSLog(@" ");
					xTranslate = a7/a1;
					yTranslate = (a8/a1);
				}
					
				if(cropFlag)
				{
					/* each layer is its natural size */
					width3 = layerNaturalBounds.right-layerNaturalBounds.left;
					height3 =layerNaturalBounds.bottom-layerNaturalBounds.top;
					bitmapBytesPerRow = bitsPerPixel/4 * width3; //width2  * 4;
					bitmapByteCount = bitmapBytesPerRow * height3;
					xPos = 0;
					yPos = height2-height3; /* hmm, think the cord space is different */
					
				} else {
					/* each layer is comp size */
					width3  = width2;
					height3 = height2;
					bitmapBytesPerRow = CGImageGetBytesPerRow(image);
					bitmapByteCount = bitmapBytesPerRow * height2;
					/* layer has to be positioned within the larger canvas */
					xPos = xTranslate;
					yPos = yTranslate;
				}


				bitmapData = malloc(bitmapByteCount);
				
				/* empty offscreen buffer */
				bitmapContext = CGBitmapContextCreate(bitmapData /* data */,
					width3   /* width */, 
					height3  /* height */, 
					CGImageGetBitsPerComponent(image)  /* bitsPerComponent */, 
					bitmapBytesPerRow /* bytesPerRow */, 
					colorSpace /* colorspace */,
					kCGImageAlphaPremultipliedLast); /* CGImageBitmapInfo */
				if(!bitmapContext)
				{
					NSLog(@"SHPhotoshopFileStuff ERROR! Cant make bitmap context");
				}			
				
				//yOffset	- moves down, + moves up	
				CGContextDrawImage(bitmapContext, CGRectMake(xPos, -yPos, width2, height2), image);
				//	CGContextFillRect( bitmapContext, CGRectMake(0, 0, 100, 100));

				// Create a new image from the now modified bitmap context
				cachedImage = CGBitmapContextCreateImage(bitmapContext);
				
				float centreX = layerNaturalBounds.left + width3/2.0;
				float centreY = height2 -(layerNaturalBounds.top + height3/2.0);
				float compCentreX = width2/2.0;
				float compCentreY = height2/2.0;
				float xCentreOffset = centreX-compCentreX;
				float yCentreOffset = centreY-compCentreY;
				NSNumber* xPosN =[NSNumber numberWithFloat:xCentreOffset];
				NSNumber* yPosN =[NSNumber numberWithFloat:yCentreOffset];
				[aPatch addImage:(id)cachedImage atPoint:[NSArray arrayWithObjects:xPosN, yPosN, nil]];

					
				//		CFRelease(cachedImage);
				free (bitmapData);
				CGColorSpaceRelease(colorSpace);

			}
			DisposeHandle( (Handle)desc );

		}


		// set up the matrix
//		SetIdentityMatrix( &matrix );
//		GraphicsImportGetDefaultMatrix( importer, &matrix );
//		err = GraphicsImportSetMatrix( importer, &matrix );

//		SetPortWindowPort( window );
//		EraseRect( &windowBounds );
		
		// draw the image
//		err = GraphicsImportDraw( importer );

//		pause();
	} /* end for */
        CloseComponent(graphicsImporter);
		// not needed DisposeHandle( (Handle)desc );

}	

//	if( desc && *desc ) {
//		// print basic statistics from the image description.
//		printf( "Image width:   %d\n", (*desc)->width );
//		printf( "Image height:  %d\n", (*desc)->height );
//		printf( "Depth:         %d\n", (*desc)->depth );
//		BlockMoveData( (*desc)->name, name, sizeof(name) );
//		CopyPascalStringToC(name, (char *)name);
//		printf( "Format:        %s\n", name);
//		printf( "Resolution:    %.1f x %.1f dpi\n", Fix2X((*desc)->hRes), Fix2X((*desc)->vRes) );
//
//		// an image description may contain a CLUT (Color Look Up Table)
//		if( ((*desc)->depth < 16) || ((*desc)->depth > 32) ) {
//			// get the CTable from the image description
//			err = GetImageDescriptionCTable( desc,			// importer instance
//											 &colorTable );	// ptr to CTabHandle
//			if( colorTable ) {
//				printf( "\nImage has a color table.\n" );
//				DisposeCTable( colorTable );
//			}
//		}
//	}

//=========================================================== 
// + showUserData
//=========================================================== 
+ (MatrixRecord) getMatrix:(GraphicsImportComponent*)aImporter
{
	MatrixRecord defaultMatrix;
	OSErr err = noErr;	
	err = GraphicsImportGetDefaultMatrix( *aImporter, &defaultMatrix );
	if( noErr == err )
		printf( "Image has default matrix (matrix type %d).\n", GetMatrixType( &defaultMatrix ) );
	return defaultMatrix;
}


//=========================================================== 
// + showUserData
//=========================================================== 
+ (void) showUserData:(UserData*)aUserData importer:(GraphicsImportComponent*)aImporter
{
	Handle h = NULL;
	OSType udType;
	short count, i;
	OSErr err = noErr;
	char nul = 0;
	h = NewHandle(0);
	Ptr p;
	MatrixRecord defaultMatrix;
	RGBColor defaultOpColor;
	Rect defaultSourceRect;
	Handle colorSyncProfile = NULL;
	RgnHandle defaultClip = NULL;
	long defaultGraphicsMode;
	short drawsAllPixels;
	
	//  retrieve the first user data type from the user data list
	udType = GetNextUserDataType( *aUserData,	// user data list
								  0 );		// user data type, 0 to retrieve first user data type
	if( 0 != udType ) {
		printf( "\nMeta-data:\n" );
		do {
			// determine the number of items of a given type in a user data list
			count = CountUserDataType( *aUserData, udType );
			for( i = 1; i <= count; i++ ) {
				// if the first letter of udType is 0xA9, the copyright symbol,
				// then use GetUserDataText instead of GetUserData
				// there's a list of interesting user data types in <Movies.h>
				if( (udType>>24) == 0xA9 ) {
					// retrieve language-tagged text from an item
					err = GetUserDataText( *aUserData,		// user data list
										   h,				// handle to recieve the data
										   udType,			// user item's type value
										   i,				// item's index value
										   langEnglish );	// language code of text to be retrieved
					// nul-terminate the string in the handle.
					PtrAndHand( &nul, h, 1 );
					// turn any CRs into spaces (to work around SIOUX behavior).
					p = *h; while( *p ) { if( *p == 13 ) *p = ' '; p++; };
					HLock( h );
					printf( "  %c%c%c%c: %s\n", (char)(udType>>24), (char)(udType>>16),
							(char)(udType>>8), (char)udType, *h );
					HUnlock( h );
				}
				else {
					// get a specified user data item
					err = GetUserData( *aUserData,	// user data list
									   h,			// handle to recieve the data
									   udType,		// user item's type value
									   i );			// item's index value
					printf( "  %c%c%c%c: [%d bytes]\n", (char)(udType>>24), (char)(udType>>16),
							(char)(udType>>8), (char)udType, GetHandleSize(h) );
				}
			}
			//  retrieve the next user data type from the user data list
			udType = GetNextUserDataType( *aUserData, udType );
		} while( 0 != udType );
	}
	DisposeUserData( *aUserData );
	DisposeHandle( h );
	printf( "\n" );

	// print out some more esoteric properties
	err = GraphicsImportGetDefaultMatrix( *aImporter, &defaultMatrix );
	if( noErr == err )
		printf( "Image has default matrix (matrix type %d).\n", GetMatrixType( &defaultMatrix ) );

	err = GraphicsImportGetMatrix( *aImporter, &defaultMatrix);
	if( noErr == err )
		printf( "Image has matrix (matrix type %d).\n", GetMatrixType( &defaultMatrix ) );
		  
	err = GraphicsImportGetDefaultClip( *aImporter, &defaultClip );
	if( noErr == err )
		printf( "Image has default clip.\n" );

	err = GraphicsImportGetClip( *aImporter,  &defaultClip);
	if( noErr == err )
		printf( "Image has clip.\n" );
		  
	err = GraphicsImportGetDefaultGraphicsMode( *aImporter, &defaultGraphicsMode, &defaultOpColor );
	if( noErr == err )
		printf( "Image has default graphics mode %d.\n", defaultGraphicsMode );

	err = GraphicsImportGetDefaultSourceRect( *aImporter, &defaultSourceRect );
	if( noErr == err )
		printf( "Image has default source rectangle (%d,%d,%d,%d).\n", defaultSourceRect.left, defaultSourceRect.top, defaultSourceRect.right, defaultSourceRect.bottom );

	err = GraphicsImportGetSourceRect( *aImporter, &defaultSourceRect);
	if( noErr == err )
		printf( "Image has source rectangle (%d,%d,%d,%d).\n", defaultSourceRect.left, defaultSourceRect.top, defaultSourceRect.right, defaultSourceRect.bottom );
		
	err = GraphicsImportGetBoundsRect( *aImporter, &defaultSourceRect);
 	if( noErr == err )
		printf( "Image has bounds rectangle (%d,%d,%d,%d).\n", defaultSourceRect.left, defaultSourceRect.top, defaultSourceRect.right, defaultSourceRect.bottom );
		 
	err = GraphicsImportGetDestRect(*aImporter,  &defaultSourceRect);
  	if( noErr == err )
		printf( "Image has dest rectangle (%d,%d,%d,%d).\n", defaultSourceRect.left, defaultSourceRect.top, defaultSourceRect.right, defaultSourceRect.bottom );
		
	err = GraphicsImportGetColorSyncProfile( *aImporter, &colorSyncProfile );
	if( ( noErr == err ) && ( NULL != colorSyncProfile ) )
		printf( "Image has a ColorSync profile (%d bytes).\n", GetHandleSize( colorSyncProfile ) );

	// might this image have holes?
	drawsAllPixels = graphicsImporterDrawsAllPixels;
	// find out if the graphics importer expects to draw every pixel
	// as some image file formats permit non-rectangular images or images
	// with transparent regions when such an image is drawn, not every
	// pixel in the boundary rectangle will be changed
	// ignore any error
	GraphicsImportDoesDrawAllPixels( *aImporter,			// importer instance
									 &drawsAllPixels );	// ptr to value describing predicted drawing behaviour
	switch( drawsAllPixels ) {
		case graphicsImporterDrawsAllPixels:
			printf( "Image will overwrite every pixel in its DestRect.\n" );
			break;
		case graphicsImporterDoesntDrawAllPixels:
			printf( "Image will not overwrite every pixel in its DestRect.\n" );
			break;
		case graphicsImporterDontKnowIfDrawAllPixels:
			printf( "Image may or may not overwrite every pixel in its DestRect.\n" );
			break;
	}

	// Note: In a multiple-image file, the image description, metadata,
	// default settings, etc. can be different for each image.

	if( defaultClip ) 
		DisposeRgn( defaultClip );
}

//=========================================================== 
// + CIImageFromCGImageRef
//=========================================================== 
+ (CIImage*) CIImageFromCGImageRef:(CGImageRef)aCGImageRef
{
	CIImage *testImage = nil;
    testImage = [CIImage imageWithCGImage:aCGImageRef];
	return testImage;
}

//=========================================================== 
// + NSImageFromCGImageRef
//=========================================================== 
+ (NSImage*)NSImageFromCGImageRef:(CGImageRef)aCGImageRef
{
// . If you have a CGImageRef object, the simplest way to create a corresponding Cocoa image is to lock focus on an NSImage object and draw your Quartz image using the CGContextDrawImage function
// NSBitmapImageRep the bitmapData
				// draw into NSImage 
//				NSImage newImage
//				[newImage lockFocus];
//				
//				 CGContextDrawImage ( CGContextRef context, CGRect rect, CGImageRef image);
//				[newImage unlockFocus];
	return nil;
}

@end
