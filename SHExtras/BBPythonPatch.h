//
//  BBPythonPatch.h
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#include <Python/Python.h>


@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch, BBPythonProxy;

/*
 *
*/
@interface BBPythonPatch : QCPatch {

	QCVirtualPort		*input_0;
	QCVirtualPort		*output_0;
	
	int numInputs;
	int numOutputs;
	NSMutableArray*		myInputPorts;
	NSMutableArray*		myOutputPorts;
	
	NSString*			script;
	
	PyThreadState *		newInterpreterTS;

	PyObject			*mainmod;
	PyObject			*locals;
	BBPythonProxy		*compiledCode;
	
	BOOL				_isCompiled, _hasError;
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

- (PyThreadState *)newInterpreterTS;

- (BBPythonProxy *)compiledCode;
- (void)setCompiledCode:(BBPythonProxy *)value;

@end
