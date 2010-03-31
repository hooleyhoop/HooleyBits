//
//  Inspector.h
//  BBExtras
//
//  Created by Jonathan del Strother on 03/08/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@interface BBInspector : QCPatch {
	QCGLImagePort* inputObject;
	QCGLImagePort* outputObject;
    QCStringPort *inputName;
}

@end
