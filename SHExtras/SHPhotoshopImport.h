//
//  SHPhotoshopImport.h
//  SHExtras
//
//  Created by Steven Hooley on 20/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
		

@interface SHPhotoshopImport : QCPatch {
	
	/* in ports */
	QCStringPort		*_inputURLPort;
	QCBooleanPort		*_embedImagesPort, *_cropLayersPort;
	
	/* out ports */
	QCStringPort		*_currentURLPort;
    NSMutableArray		*_outImagePorts, *_outPosPorts;
	
	
	int					_currentPort;
	
}

#pragma mark action methods
- (void) addImage:(id)image atPoint:(NSArray*)aPt;

- (id) addOutputPort:(Class)aClass description:(NSString*)aDesc;

#pragma mark accessor methods
- (void) setURL:(NSURL*)url;

@end
