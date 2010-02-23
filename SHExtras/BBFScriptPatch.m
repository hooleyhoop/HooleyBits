//
//  BBFScriptPatch.m
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBFScriptPatch.h"
#import "BBFScriptPatchUI.h"
#import <sys/types.h>

#define DEGREES_TO_RADIANS  (3.1415926535897932384626433832795029L/180.0)


@implementation BBFScriptPatch

#pragma mark -
#pragma mark class methods
+ (void)initialize
{
	[super initialize];
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
	return [BBFScriptPatchUI class];
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
		
		[self setMyInputPorts: [NSMutableArray arrayWithCapacity:3]];
		[self setMyOutputPorts: [NSMutableArray arrayWithCapacity:3]];
		
		[self setScript:@"An empty Script"];
		
		[self setTheInterpreter: [FSInterpreter interpreter]];
		[theInterpreter setObject:self forIdentifier:@"patch"];

	}
	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[self setTheInterpreter: nil];
	
	[self setMyInputPorts: nil];
	[self setMyOutputPorts: nil];

	[super dealloc];
}	


#pragma mark action methods
//=========================================================== 
// - execute
//===========================================================
- (void)execute
{
	theInterpreter = [FSInterpreter interpreter];
	FSInterpreterResult* execResult = [theInterpreter execute: script];
	id result = nil;
	if([execResult isOK]){
		result = [execResult result];
		if(!result){
			NSLog(@"BBFScriptPatch.m: Failed to execute save string for node");
			return;
		}
	}
	NSLog(@"BBFScriptPatch: result is %@", result);
}

//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
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
	id port = [self createOutputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"output_%i", [myOutputPorts count]]];
	[myOutputPorts addObject:port];
	numOutputs += 1;
}

//=========================================================== 
// - removeOutputPort
//=========================================================== 
- (void)removeOutputPort 
{
	if ([myOutputPorts count] < 2) return;
	numOutputs -= 1;
	id port = [myOutputPorts lastObject];
	[self deleteOutputPortForKey:[self keyForPort:port]];
	[myOutputPorts removeLastObject];
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
	id port = [self createInputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"input_%i", [myInputPorts count]]];
	[myInputPorts addObject:port];
	numInputs += 1;
}

//=========================================================== 
// - removeInputPort
//=========================================================== 
- (void)removeInputPort 
{
	if ([myInputPorts count] < 2) return;
	numInputs -= 1;
	id port = [myInputPorts lastObject];
	[self deleteInputPortForKey:[self keyForPort:port]];
	[myInputPorts removeLastObject];
}

// restore ports
- (BOOL)setState:(id)state 
{
	[super setState: state];
	int desiredNumInputPorts = [[state valueForKey:@"inputCount"] intValue];
	int desiredNumOutputPorts = [[state valueForKey:@"outputCount"] intValue];
	while ([myInputPorts count] < desiredNumInputPorts) { [self addInputPort];}
	while ([myOutputPorts count] < desiredNumOutputPorts) { [self addOutputPort];}
	return YES;
}

// return the number of desired ports along with super's state so we can restore needed ports when reloading
- (id)state
{
	NSMutableDictionary* state = [[[super state] mutableCopy] autorelease];
	[state setValue:[NSNumber numberWithInt:[myInputPorts count]] forKey:@"inputCount"];
	[state setValue:[NSNumber numberWithInt:[myOutputPorts count]] forKey:@"outputCount"];
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
	NSLog(@"BBPythonPatch.m: Returning script");
    return script;
}

- (void)setScript:(NSString *)value {
	NSLog(@"BBPythonPatch.m: setString %@", value);
    if (script != value) {
        [script release];
        script = [value retain];
    }
}

- (FSInterpreter *)theInterpreter
{
	return theInterpreter;
}

- (void)setTheInterpreter:(FSInterpreter *)value
{
	if(theInterpreter!=value){
		[theInterpreter release];
		theInterpreter = [value retain];
	}
}

@end
