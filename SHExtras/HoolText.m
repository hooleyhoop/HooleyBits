//
//  HoolText.m
//  SHExtras
//
//  Created by Steven Hooley on 02/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "HoolText.h"

/*
*
*/
@implementation HoolText


#pragma mark -
#pragma mark class methods
//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL) allowsSubpatches {
	return FALSE;
}


#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;


	return self;
}

//=========================================================== 
// - setup:
//=========================================================== 
- (id) setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	[super setup:fp8];
	return fp8;
}

#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL) execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	CFStringRef textString = CFSTR("QUARTZ");
	float opaqueRed[] = {0.663,0.,0.031,1.};
	float opaqueGreen[] = {0.663,0.,0.031,1.};
	float opaqueBlue[] = {0.663,0.,0.031,1.};
	static const CGRect textBox = {0.,0.,1000,1000};
	HIThemeTextInfo textInfo = {0,kThemeStateActive,kThemeApplicationFont,kHIThemeTextHorizontalFlushLeft,kHIThemeTextVerticalFlushBottom,kHIThemeTextBoxOptionNone, kHIThemeTextTruncationNone,0,false};
	CGContextSetFillColorSpace(context, getTheRGBColorSpace());
	CGContextSetFillColor(context, opaqueRed);
	CGContextTranslateCTM(context,10,300);
	(void)HIThemeDrawTextBox(textString, &textBox, &textInfo, context, kHIThemeOrientationNormal);
	[outputImagePort setImageValue:nil];
	return YES;
}

#pragma mark accessor methods

@end
