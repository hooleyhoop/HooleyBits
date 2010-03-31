// (C) best before/Anatol Ulrich

/* 
	?!
*/

#import "magic_container.h"


@implementation BBMagicContainer : QCPatch
+ (int)executionMode
{
	// change this to 2 to enable auto-executing (without tickle)
	// hmm, it seems to work on its own even in mode 3 sometimes ...
	return 3; // "I am a Generator"
	
}


+ (BOOL)allowsSubpatches
{
	return TRUE;
}

- (id)setup:(id)p
{
	return p;
}

- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{
	[self executeSubpatches:currentTime arguments:args];
	return TRUE;
}

-(void)cleanup:(id)p {
}

- (BOOL)canConnectPort:(id)fp8 toPort:(id)fp12 {
	return (fp8 != fp12);
}


@end
