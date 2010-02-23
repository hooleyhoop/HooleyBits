//
//  BBStringRenderer.h
//  BBExtras
//
//  Created by Jonathan del Strother on 07/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import "Atsui.h"

@class BBStringRendererUI;

@interface BBTextPlus : QCImagePatch {
    QCStringPort *inputString;
    QCStringPort *inputFontName;
    QCNumberPort *inputGlyphSize;
    QCNumberPort *inputGlyphCount;
    QCNumberPort *inputLeading;
    QCNumberPort *inputKerning;
    QCNumberPort *inputWidth;
    QCNumberPort *inputHeight;
	QCNumberPort *inputTextAlignment;
	QCNumberPort *inputGlowSize;
	QCColorPort *inputGlowColor;
    QCGLImagePort *outputImage;
    QCNumberPort *outputWidth;
    QCNumberPort *outputHeight;
    QCNumberPort *outputLineCount;
	
	unsigned char * bitmapData;
	
	Atsui* atsui;
	BOOL forceRefresh;
	
	double targetWidth;
	
	float viewHeight;
	float overSampling;
	
	
	QCGLBitmapImage* bitmapImage;
	int prevBytesPerRow;
	int prevHeight;
}

+ (int)executionMode;
+ (BOOL)allowsSubpatches;
- (id)initWithIdentifier:(id)fp8;
- (id)setup:(id)fp8;
- (BOOL)execute:(QCOpenGLContext*)fp8 time:(double)fp12 arguments:(id)fp20;
-(BOOL)colorEnabled;
-(void)setColorEnabled:(BOOL)value;
-(BOOL)htmlEnabled;
-(void)setHTMLEnabled:(BOOL)value;

@end



@interface BBTextPlus (QCInspector)
+ (Class)inspectorClassWithIdentifier:(id)fp8;
@end