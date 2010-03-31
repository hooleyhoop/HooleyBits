//
//  BBPythonPatch.m
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBPythonPatch.h"
#import "BBPythonPatchUI.h"
#import <sys/types.h>
#import "pyobjc-api.h"
#import "BBPythonProxy.h"
// #import "BBPython.h"
// #import "Tortoise.h"

#define COMILE_TO_BYTECODES 1

/*
*
*/
@implementation BBPythonPatch

static PyThreadState * mainThreadState;
static PyObject *globals;


// expose module entry point
void setUpPython()
{
  static int initialized = 0;
  if (!initialized) {
	
	BOOL pyobjcInstalled = ( PyObjC_ImportAPI != NULL ? YES : NO );
	if( ! pyobjcInstalled ) {
		NSLog(@"PyObjc not installed");
	}
  	Py_Initialize();
	PyObjC_ImportAPI( Py_None );
	PyEval_InitThreads();

	PyRun_SimpleString("import sys\n");
	PyRun_SimpleString("from Foundation import *\n");
	PyRun_SimpleString("from AppKit import *\n");
	// PyRun_SimpleString("import BBPython\n");
	// PyThreadState * mainThreadState = NULL;
	// save a pointer to the main PyThreadState object
	mainThreadState = PyThreadState_Get();
	// release the lock
	PyEval_ReleaseLock();
	initialized = 1;
  }
}


#pragma mark -
#pragma mark class methods
+ (void)initialize
{
	[super initialize];
	setUpPython();
}

//=========================================================== 
// + allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return NO;
}

//=========================================================== 
// + inspectorClassWithIdentifier:
//=========================================================== 
+ (Class)inspectorClassWithIdentifier:(id)fp8 
{
	return [BBPythonPatchUI class];
}

#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if ((self = [super initWithIdentifier:fp8]) != nil)
	{
		numOutputs = 1;
		numInputs = 1;
		_isCompiled = NO;
		_hasError = NO;
		
		[self setMyInputPorts: [NSMutableArray arrayWithCapacity:3]];
		[self setMyOutputPorts: [NSMutableArray arrayWithCapacity:3]];
		
		[self setScript:@"myObject = NSObject.alloc().init()"];
		// myString = NSString.alloc().initWithString_(u'my string')
		// myValue = valueContainer.value()
		// valueContainer.setValue_(myNewValue)
		// pool = NSAutoreleasePool.alloc().init()
		// del pool
		
		//ignore line wrap on following line
		// PyRun_SimpleString("sys.stdout.write('Hello from an embedded Python Script\n')\n");
		newInterpreterTS = PyThreadState_Swap(NULL);
		PyEval_AcquireLock();
		// PyInterpreterState * mainInterpreterState = mainThreadState->interp;
		newInterpreterTS = Py_NewInterpreter();
		if(newInterpreterTS==NULL)
		{
			PyEval_ReleaseLock();
			// NSError* err = [[[NSError alloc] initWithDomain:@"PYTHONINITERROR" code:1 userInfo:nil] autorelease];
			return nil;			
		}
		PyThreadState_Swap(newInterpreterTS);

		initBBPython();
		// tortoise_initialize();
		
		// printf("CREATED THREAD %i\n", newInterpreterTS->thread_id);
		PyImport_ImportModule("sys");

		PyRun_SimpleString("import sys\n");
		PyRun_SimpleString("import marshal\n");
		PyRun_SimpleString("from Foundation import *\n");
		PyRun_SimpleString("from AppKit import *\n");
		// PyImport_ImportModule("BBPython");
		// PyImport_ImportModule("ctypes");

		// import PyObjCTools
	
		PyObject *mname = PyString_FromString("__main__");
		mainmod = PyImport_Import(mname);
		globals = PyModule_GetDict(mainmod);

		/* Display modules to check we have imported objc successfully */
		PyRun_SimpleString("print sys.builtin_module_names\n");
		PyRun_SimpleString("print sys.modules.keys()\n");
		// [BBPythonProxy proxyFor:mname steal:YES];
		
		locals = PyDict_New();
		
		// what is this? - cant find reference to PyEval_SimpleString anywhere
		// PyEval_SimpleString("import sys\n");
		PyThreadState_Swap(NULL);
		PyEval_ReleaseLock();

		[self resetLocalVariables];

	}
	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[self setMyInputPorts: nil];
	[self setMyOutputPorts: nil];
	
	// grab the lock
	PyEval_AcquireLock();
	PyThreadState_Clear(newInterpreterTS);
	Py_EndInterpreter(newInterpreterTS);
	
	// swap my thread state out of the interpreter
	PyThreadState_Swap(NULL);
	// clear out any cruft from thread state object
	// delete my thread state object
	PyThreadState_Delete(newInterpreterTS);
	
	Py_XDECREF(locals);
	
	// release the lock
	PyEval_ReleaseLock();

	[super dealloc];
}	

// PyObject_CallObect()
// PyObject_CallFunction
#pragma mark action methods
//=========================================================== 
// - execute
//===========================================================
- (void)execute
{
	if(!_hasError)
	{
		// grab the global interpreter lock
		PyEval_AcquireLock();
		// swap in my thread state
		PyThreadState_Swap(newInterpreterTS);
		
		// [BBPythonProxy proxyFor:globals steal:YES];
		// [BBPythonProxy proxyFor:locals steal:YES];

		/* TODO check the string length before executing ! */
		PyObject *result;
		BBPythonProxy *pxRes;

#ifdef COMILE_TO_BYTECODES
		PyObject *code;
		
		if( !_isCompiled )
		{
			if([script length]<1){
				_hasError = YES;
				NSLog(@"script is empty");
				goto home;
			}
				
			if (!(code = Py_CompileString((char *)[script cString], (char *)"<console>", Py_file_input))) {
				NSLog(@"cant compile script");
				PyErr_Print();
				_hasError = YES;
				goto home;
			}
			[self setCompiledCode: [BBPythonProxy proxyFor:code steal:YES]];
			_isCompiled = YES;
		}
		@try {

			result = PyEval_EvalCode((PyCodeObject *)[compiledCode original], globals, locals);
		} @catch( NSException* e ) {
//			} @finally {
			NSLog(@"BBPythonPatch.m: Exception while executing script %@", e);
		}
		if (!result) {
			PyErr_Print();
			NSLog(@"Error execution returned NULL");
			_hasError = YES;
			goto home;
		}
#else
		// execute some python code	
		// PyRun_SimpleString([script UTF8String]);
		result = PyRun_StringFlags([script UTF8String], Py_file_input, globals, locals, NULL);

#endif
		pxRes = [BBPythonProxy proxyFor:result steal:YES];
		NSLog(@"Result was %@", [[[NSAttributedString alloc] initWithString:[pxRes description] attributes:[NSDictionary dictionary]] autorelease]);

	home:
		// clear the thread state
		PyThreadState_Swap(NULL);
		// release our hold on the global interpreter
		PyEval_ReleaseLock();
	}
}

//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	/* reset state when starting from the beggining - wont work in MCreate */
	if(compositionTime<0.5)
		[self resetLocalVariables];
	[self execute];
	return YES;
}

//=========================================================== 
// - addOutputPort
//=========================================================== 
- (void)addOutputPort 
{
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[QCVirtualPort class], @"class",
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"name",@"someOutput",
			@"description",@"an image.",
			nil], @"attributes", 
		nil];
	id port = [self createOutputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"output_%i", [myOutputPorts count]+1]];
	[myOutputPorts addObject:port];
	numOutputs += 1;
	_isCompiled = NO;
	_hasError = NO;
	[self resetLocalVariables];
}

- (void)resetLocalVariables
{
	if(locals){
		PyEval_AcquireLock();
		PyThreadState_Swap(newInterpreterTS);
		PyDict_Clear(locals);
		PyDict_SetItem(locals, PyString_FromString("self"), PyObjC_IdToPython(self));
		PyDict_SetItem(locals, PyString_FromString("inputs"), PyObjC_IdToPython([self inputs]));
		PyDict_SetItem(locals, PyString_FromString("outputs"), PyObjC_IdToPython([self outputs]));
		PyThreadState_Swap(NULL);		
		PyEval_ReleaseLock();

	} 
	//else 
//	{
//		NSLog(@"why?");
//	}
}

//=========================================================== 
// - removeOutputPort
//=========================================================== 
- (void)removeOutputPort 
{
	if ([myOutputPorts count] < 1) return;
	numOutputs -= 1;
	id port = [myOutputPorts lastObject];
	[self deleteOutputPortForKey:[self keyForPort:port]];
	[myOutputPorts removeLastObject];
	_isCompiled = NO;
	_hasError = NO;
	[self resetLocalVariables];
}


//=========================================================== 
// - addInputPort
//=========================================================== 
- (void)addInputPort 
{
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[QCVirtualPort class], @"class",
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"name",@"someInput",
			@"description",@"an image.",
			nil], @"attributes", 
		nil];
	id port = [self createInputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"input_%i", [myInputPorts count]+1]];
	[myInputPorts addObject:port];
	numInputs += 1;
	_isCompiled = NO;
	_hasError = NO;
	[self resetLocalVariables];
}

//=========================================================== 
// - removeInputPort
//=========================================================== 
- (void)removeInputPort 
{
	if ([myInputPorts count] < 1) return;
	numInputs -= 1;
	id port = [myInputPorts lastObject];
	[self deleteInputPortForKey:[self keyForPort:port]];
	[myInputPorts removeLastObject];
	_isCompiled = NO;
	_hasError = NO;
	[self resetLocalVariables];
}

// restore ports
- (BOOL)setState:(id)state 
{
	[super setState: state];
	int desiredNumInputPorts = [[state valueForKey:@"inputCount"] intValue];
	int desiredNumOutputPorts = [[state valueForKey:@"outputCount"] intValue];
	while ([myInputPorts count] < desiredNumInputPorts) { [self addInputPort];}
	while ([myOutputPorts count] < desiredNumOutputPorts) { [self addOutputPort];}
	[self setScript:[state valueForKey:@"script"]];
	return YES;
}

// return the number of desired ports along with super's state so we can restore needed ports when reloading
- (id)state
{
	NSMutableDictionary* state = [[[super state] mutableCopy] autorelease];
	[state setValue:[NSNumber numberWithInt:[myInputPorts count]] forKey:@"inputCount"];
	[state setValue:[NSNumber numberWithInt:[myOutputPorts count]] forKey:@"outputCount"];
	[state setValue:script forKey:@"script"];
	return state;
}

#pragma mark accessor methods
- (NSMutableArray *)myInputPorts
{
	return myInputPorts;
}

- (NSMutableArray *)myOutputPorts
{
	return myOutputPorts;
}

- (void)setMyInputPorts:(NSMutableArray *)value
{
	if(myInputPorts!=value){
		[myInputPorts release];
		myInputPorts = [value retain];
	}
}

- (void)setMyOutputPorts:(NSMutableArray *)value
{
	if(myOutputPorts!=value){
		[myOutputPorts release];
		myOutputPorts = [value retain];
	}
}

- (NSString *)script 
{
    return script;
}

- (void)setScript:(NSString *)value {
    if (script != value) {
        [script release];
        script = [value retain];
		_isCompiled = NO;
		_hasError = NO;
		[self resetLocalVariables];
    }
}

- (PyThreadState *)newInterpreterTS
{
	return newInterpreterTS;
}


- (BBPythonProxy *)compiledCode
{
	return compiledCode;
}

- (void)setCompiledCode:(BBPythonProxy *)value
{
	if(compiledCode!=value){
		[compiledCode release];
		compiledCode = [value retain];
	}
}

@end
