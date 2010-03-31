//
//  HoolText.h
//  SHExtras
//
//  Created by Steven Hooley on 02/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;

/*
 *
*/
@interface HoolText : QCPatch {

	    QCGLImagePort *outputImagePort;

}

@end
