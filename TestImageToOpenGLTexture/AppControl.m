//
//  AppControl.m
//  TestImageToOpenGLTexture
//
//  Created by Steve Hooley on 07/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AppControl.h"
#import "TextureWrapper.h"
#import "HooleyTexturedRect.h"
#import "OpenGLView.h"

#import <QuartzCore/QuartzCore.h>


@implementation AppControl

- (id)init
{
    if ((self = [super init]) != nil) 
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{
}

/* make sure the openglView is all setup before we kick off */
- (void)applicationDidFinishLaunching:(NSNotification*)notification 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:NSApp];

	/* load image data */
	NSString* imagePath = [[[NSBundle bundleForClass:[self class]] pathForImageResource:@"kitten.jpg"] stringByResolvingSymlinksInPath];
	NSData* jpgData = [NSData dataWithContentsOfFile: imagePath];
	if(!jpgData){
		NSLog(@"Image is Missing");
		[[NSApplication sharedApplication] terminate: self];
	}
	CIImage* uncompressedImage = [CIImage imageWithData:jpgData];
	CGRect bounds = [uncompressedImage extent];
	
	/* scale to desired size */
	CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
	[transform setValue:uncompressedImage forKey:@"inputImage"];
	NSAffineTransform *affineTransform = [NSAffineTransform transform];
	float targetWidth = 400;
	float targetHeight = 300;
	float scaleX = targetWidth/ bounds.size.width;
	float scaleY = targetHeight/ bounds.size.height;
	
	[affineTransform scaleXBy:scaleX yBy:scaleY];
	[transform setValue:affineTransform forKey:@"inputTransform"];
	CIImage * scaledImage = [transform valueForKey:@"outputImage"];
	
	/* crop - may or may not be neccassary (?) */
	CIFilter *crop = [CIFilter filterWithName:@"CICrop"];
	[crop setValue:[CIVector vectorWithX:floorf(0)
									   Y:floorf(0)
									   Z:ceilf(targetWidth)
									   W:ceilf(targetHeight)] forKey:@"inputRectangle"];
	
	[crop setValue:scaledImage forKey:@"inputImage"];
	CIImage * croppedImage = [crop valueForKey:@"outputImage"];	
	
	/* the extent filter can be useful here to tidy up edge pixels */
	
	/* render the ciimage in to vram */
	TextureWrapper* openglTexture = [TextureWrapper textureWithImage: croppedImage cntx:[simpleView ciCntx]];
	
	/* make a drawable object our view knows how to draw */
	HooleyTexturedRect* htr = [HooleyTexturedRect rectWithTexture:openglTexture];
	
	[simpleView addDrawableShape: htr];
}


- (OpenGLView *)simpleView {
    return simpleView;
}

- (void)setSimpleView:(OpenGLView *)value {
    if (simpleView != value) {
        [simpleView release];
        simpleView = [value retain];
    }
}


@end
