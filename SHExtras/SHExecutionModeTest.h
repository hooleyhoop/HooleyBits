//
//  SHExecutionModeTest.h
//  SHExtras
//
//  Created by Steven Hooley on 22/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
		
		
/*
 *
*/
@interface SHExecutionModeTest : QCPatch {

	QCNumberPort	*inputNumber, *outputNumber;
	
	NSWindow*		_madnessWindow;
}

- (NSWindow*)madnessWindow;

@end
