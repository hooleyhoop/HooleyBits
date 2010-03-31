//
//  SHSwapIns.h
//  SHExtras
//
//  Created by Steven Hooley on 07/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch;
				
@interface SHSwapIns : QCPatch {

BOOL isSwapped;
QCBooleanPort *inputSwap;
QCBooleanPort *inputReset;
QCNumberPort* inputValue1;
QCNumberPort* inputValue2;
QCNumberPort* output1;
QCNumberPort* output2;
	
}

	

@end