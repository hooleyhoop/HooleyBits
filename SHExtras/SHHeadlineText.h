//
//  SHHeadlineText.h
//  SHExtras
//
//  Created by Steven Hooley on 02/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import "Atsui.h"

@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;

/*
 *
*/
@interface SHHeadlineText : QCPatch {

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

- (id) initWithIdentifier:(id)fp8;
- (id) setup:(id)fp8;
- (BOOL) execute:(QCOpenGLContext*)fp8 time:(double)fp12 arguments:(id)fp20;
-(void) updateString;

- (void)setColorEnabled:(BOOL)value;
- (BOOL)htmlEnabled;
- (void)setHTMLEnabled:(BOOL)value;
- (BOOL)colorEnabled;



@end
