//
//  BBInterpolationPatch.h
//  SHExtras
//
//  Created by Steven Hooley on 16/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
	
@class LWEnvelope;

/*
 *
*/
@interface BBInterpolationPatch : QCPatch {
	
	QCNumberPort	*outputValue;
	LWEnvelope*		_envelope;
}



#pragma mark accessor methods
- (LWEnvelope *)envelope;
- (void)setEnvelope:(LWEnvelope *)value;

//- (NSString*) name;

@end
