//
//  SHUTubePatch.h
//  SHExtras
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import "WebKit/WebKit.h"
#import "WebKit/WebFrameLoadDelegate.h"
// @class SHInvisibleWindow;
@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
		
		
/*
 *
*/
@interface SHUTubePatch : QCPatch {
	
	QCStringPort*	inputURLPort;
//	QCNumberPort	*inputScale;// , *inputHeight;
//	QCBooleanPort*	inputUseTransparentWindow;
	QCGLImagePort*	outputImage;
	QCNumberPort*	outputLoadProgress;

	BOOL			_loadingFlag;
	BOOL			_playFlag;
	BOOL			_errorFlag;
	NSString		*_lastLookUpString, *_stringAttemptingToLoad;
	
	BOOL			_lastUseTransparentWindow;
	
	WebView				*_webView;
	NSWindow		*_hiddenWindow;
	
//	double			_lastScale; //_lastHeight;
	NSTimer* _timer;
}

#pragma mark action methods
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20;
- (void)loadNewURL:(id)sender;
- (void)refreshCurrentPage;
- (BOOL)setStageDimensions;
- (void) play:(BOOL)flag;
- (void)cleanUp;

#pragma mark accessor methods

- (WebView*) webView;
- (NSWindow*) hiddenWindow;
	
- (void) setLastLookUpString:(NSString*) aString;
- (void) setStringAttemptingToLoad:(NSString*) aString;


@end
