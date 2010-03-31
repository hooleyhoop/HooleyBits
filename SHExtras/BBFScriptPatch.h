//
//  BBFScriptPatch.h
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#include <FScript/FScript.h>

@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch, FSInterpreter;

@interface BBFScriptPatch : QCPatch {

	QCVirtualPort		*inputPort;
	QCVirtualPort		*outputPort;
	
	int numInputs;
	int numOutputs;
	NSMutableArray*		myInputPorts;
	NSMutableArray*		myOutputPorts;
	
	NSString*			script;

	FSInterpreter*		theInterpreter;

}

- (void)execute;

- (void)addInputPort;
- (void)removeInputPort;

- (void)addOutputPort;
- (void)removeOutputPort;

- (NSMutableArray *)myInputPorts;
- (NSMutableArray *)myOutputPorts;
- (void)setMyInputPorts:(NSMutableArray *)value;
- (void)setMyOutputPorts:(NSMutableArray *)value;

- (NSString *)script;
- (void)setScript:(NSString *)value;

- (FSInterpreter *)theInterpreter;
- (void)setTheInterpreter:(FSInterpreter *)value;

@end
