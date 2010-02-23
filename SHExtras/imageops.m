// (C) best before/Anatol Ulrich

/* 
	This is not the much sought-after inverse multiplexer. Now with less calories!
*/
#import "imageops.h"
#import "AppKit/NSBitmapImageRep.h"
#include <unistd.h>

@implementation BBExperimental : QCPatch
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
	
	return self;
}

+ (BOOL)allowsSubpatches
{
	return FALSE;
}

- (id)setup:(id)p
{
	points = [[NSMutableArray alloc] init];
	return p;
}

- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{
	QCGLBitmapImage* image = [inputImage imageValue];
	NSImage* _nsimage = [image NSImage];
	const char * bytes = [[_nsimage TIFFRepresentation] bytes];
	[points removeAllObjects];
	
	int w = 64;
	int h = 64;
	for (int y = 0; y < h; y++) {
		for (int x = 0; x < w; x++) {
			int data = (int) bytes[x*4 + y*w*4];
			if (data != 0) {
				//[points addObject:[NSArray arrayWithObjects:x,y]];
				//NSLog(@"x:%i y:%i value:%i", x, y, data);
			}

		}
	}

	return TRUE;
}

-(void)cleanup:(id)p {
	[points release];
}

@end