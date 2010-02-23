//
//  SHAEKeyframeParse.m
//  SHExtras
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHAEKeyframeParse.h"
#import "SHAEKeyframeParseUI.h"

@implementation SHAEKeyframeParse

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + timeMode:
//=========================================================== 
+ (int)timeMode {
	return 1;		//Forces continuous execution
}

//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int) executionMode
{
	return 3; // "I am a Generator/Modifier"
}

//=========================================================== 
// + allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches
{
	return FALSE;
}

//=========================================================== 
// + inspectorClassWithIdentifier:
//=========================================================== 
+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SHAEKeyframeParseUI class];
}

#pragma mark init methods
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	
	outPorts = [[NSMutableDictionary alloc] initWithCapacity:3];
	numOutPorts = 0;
	aeCompWidth=720;
	aeCompHeight=576;
	keyFrameDataString = [[NSAttributedString alloc] initWithString:@"Hello world!"];;
	return self;
}

#pragma mark action methods
//=========================================================== 
// - parseInput:
//===========================================================
- (void) parseInput
{

}

//=========================================================== 
// - execute:
//=========================================================== 
- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{
//	int index = [inputIndex indexValue];
	// no need to check for >0 in index ports
//	if (index < [outPorts count]) {
//		[[outPorts objectAtIndex:index] setRawValue: [inputData rawValue]];
//	}
	return TRUE;
}

//=========================================================== 
// - addOutputPort:
//=========================================================== 
- (void) addOutputPort 
{
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[QCVirtualPort class], @"class",
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"name",@"someInput",
			@"description",@"an image.",
			nil], @"attributes", 
		nil];
	id port = [self createOutputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"output_%i", [outPorts count]]];
	[outPorts addObject:port];
	numOutPorts += 1;
}

//=========================================================== 
// - removeOutputPort:
//=========================================================== 
- (void) removeOutputPort 
{
	if ([outPorts count] < 1) return;
	numOutPorts -= 1;
	id port = [outPorts lastObject];
	[self deleteOutputPortForKey:[self keyForPort:port]];
	[outPorts removeLastObject];
}

#pragma mark accessor methods
- (int)aeCompWidth {
    return aeCompWidth;
}

- (void)setAeCompWidth:(int)value {
	NSLog(@"new width is %i", value);
    if (aeCompWidth != value) {
        aeCompWidth = value;
    }
}

- (int)aeCompHeight {
    return aeCompHeight;
}

- (void)setAeCompHeight:(int)value {
    if (aeCompHeight != value) {
        aeCompHeight = value;
    }
}

- (NSAttributedString *)keyFrameDataString {
    return [[keyFrameDataString retain] autorelease];
}

- (void)setKeyFrameDataString:(NSAttributedString *)value {
    if (keyFrameDataString != value) {
        [keyFrameDataString release];
        keyFrameDataString = [value copy];
		
		[self parseInput];
    }
}




@end
