// (C) best before/Anatol Ulrich

/* 
	the much sought-after inverse multiplexer. Now with less calories!
*/
#import "inversemux.h"
#import "inversemuxui.h"
#include <unistd.h>

@implementation BBInverseMultiplexer : QCPatch
+ (int)executionMode
{
	return 3; // "I am a Generator/Modifier"
}

- (id)initWithIdentifier:(id)fp8
{	
	if ((self = [super initWithIdentifier:fp8]) == nil) {
		[super release];
		return nil;	
	}
	
	ports = [[NSMutableArray alloc] init];
	
	// 4 output ports enabled by default so the patch is not too lonely
	for (int i=0; i < 4; i++) {
		[self addOutputPort];
	}
	
	return self;
}

+ (BOOL)allowsSubpatches
{
	return FALSE;
}

- (id)setup:(id)p
{
	return p;
}

- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{
	int index = [inputIndex indexValue];
	// no need to check for >0 in index ports
	if (index < [ports count]) {
		[[ports objectAtIndex:index] setRawValue: [inputData rawValue]];
	}
	return TRUE;
}

-(void)cleanup:(id)p {
}

- (void) addOutputPort {
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[QCVirtualPort class], @"class",
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"name",@"someInput",
			@"description",@"an image.",
			nil], @"attributes", 
		nil];
	id port = [self createOutputPortWithArguments:arguments forKey:[NSString stringWithFormat:@"output_%i", [ports count]]];
	[ports addObject:port];
	numPorts += 1;
}

- (void) removeOutputPort {
	if ([ports count] < 1) return;
	numPorts -= 1;
	id port = [ports lastObject];
	[self deleteOutputPortForKey:[self keyForPort:port]];
	[ports removeLastObject];
}

// restore ports
- (BOOL)setState:(id)state {
	[super setState: state];
	int desiredNumPorts = [[state valueForKey:@"outputCount"] intValue];
	while ([ports count] < desiredNumPorts) { [self addOutputPort];}
	return TRUE;
}

// return the number of desired ports along with super's state so we can restore needed ports when reloading
- (id)state {
	NSMutableDictionary* state = [[super state] mutableCopy];
	[state setValue:[NSNumber numberWithInt:[ports count]] forKey:@"outputCount"];
	return [state autorelease];
}

+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [BBInverseMultiplexerUI class];
}

@end