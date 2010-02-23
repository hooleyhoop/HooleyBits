//
//  PDDac.m
//  SHMathOperators
//
//  Created by Steve Hooley on 13/03/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PDDac.h"
#import "s_audio.h"
#import <SHNodeGraph/SHInputAttribute.h>
#import <SHNodeGraph/SHOutputAttribute.h>


#define SAMPLE_RATE         (44100)
#define NUM_SECONDS            (0.25)
#define SAMPLES_PER_FRAME       (2)

#define FREQUENCY           (220.0f)
#define PHASE_INCREMENT     (2.0f * FREQUENCY / SAMPLE_RATE)
#define FRAMES_PER_BLOCK    (100)


//Class output1Class;
static BOOL initError = YES;

/*
 *
 *
*/
@implementation PDDac


#pragma mark -
#pragma mark class methods
+ (NSString*) pathWhereResides{ return @"/PureData";}

//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	//output1Class = NSClassFromString( @"SHNumber" );
	//if(output1Class)
	initError = NO;
}

#pragma mark init methods
// ===========================================================
// - initWithParentNodeGroup:
// ===========================================================
- (id)initWithParentNodeGroup:(SHNodeGroup*)aNG
{	
	//NSLog(@"PDDac.m: initing ok");
	if(!initError){
		if(self=[super initWithParentNodeGroup:aNG])
		{
			[self initInputs];
			[self initOutputs];

			int audioindev		= 0;
			int chindev			= 2;
			int audiooutdev		= 0;
			int choutdev		= 2;
			
			// when we delete this node we should turn this off...
			// Of Course this is now blocking.. this isnt strictly necasary.. !!!!!
			sys_open_audio(1,&audioindev,1,&chindev,1,&audiooutdev,1,&choutdev,44100,50,1);
			
			/* replace the buffer in outAttribure with the global 'sys_soundout' */
			[(id)[portAudioOut value] replaceDataBuffer:sys_soundout length:512];

			// register with the run loop our critical routine that needs calling each time through the loop before evaluate
			//	- (int) advanceTimePerFrame		 
			SEL theSelector					= @selector(advanceTimePerFrame);
			NSMethodSignature *aSignature	= [[self class] instanceMethodSignatureForSelector:theSelector];
			_advanceTimeInvocation			= [[NSInvocation invocationWithMethodSignature:aSignature]retain];
			[_advanceTimeInvocation setSelector:theSelector];			
			[_advanceTimeInvocation setTarget:self];	// invocation doesnt retain arguments
			// [anInvocation setArgument:nil atIndex:2];	// 		
			[aNG addAdvanceTimeInvocation:_advanceTimeInvocation];
			
			// similar to connecting with an interconnector but doesnt need to check
			// for compatible selectors and stuff
			//[in1 affects:out1];
			//[in2 affects:out1];
		} 
		return self;
	}
	return nil;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {
	[_advanceTimeInvocation release];
	_advanceTimeInvocation = nil;
    [super dealloc];
}




#pragma mark action methods








#pragma mark accessor methods


@end
