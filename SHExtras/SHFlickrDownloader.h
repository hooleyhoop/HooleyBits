//
//  SHFlickrDownloader.h
//  SHExtras
//
//  Created by Steven Hooley on 17/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import <ObjectiveFlickr/ObjectiveFlickr.h>

@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
		
@interface SHFlickrDownloader : QCPatch {

	QCStringPort *inputSearchString;
	QCIndexPort *inputMaxReturn;
	QCBooleanPort *outputReady;
	QCStructurePort *outputStructure;

	NSString*	_lastLookUpString;
	BOOL		_lookUpIsBusy;
	int			_lastInputMaxReturn;
	
	OFFlickrContext *context;
	OFFlickrInvocation *invoc;
}
	
+ (int)executionMode;
//+ (BOOL)allowsSubpatches;
- (id)initWithIdentifier:(id)fp8;
///- (BOOL)execute:(id)fp8 time:(double)fp12 arguments:(id)fp20;
@end

@interface SHFlickrDownloader (Execution)

- (void)startSearch:(id)sender;

- (void) setLastLookUpString:(NSString*) aString;

@end
