// (C) 2006 best before / Anatol Ulrich

#import "rendering_dimensions.h"

@implementation BBRenderingDimensions : QCPatch
+ (int)executionMode
{
	return 3; // whatever...
}

+ (BOOL)allowsSubpatches
{
	return NO;
}

- (id)setup:(id)p
{
	return p; // ?
}

- (BOOL)execute:(QCOpenGLContext*)qcglctx time:(double)exec_time arguments:(id)arg
{
	NSSize resolution = [qcglctx viewportResolution];
	NSSize widthHeight = [qcglctx viewportFrame:TRUE].size; // TODO: find out what the boolean does
	NSLog(@"some rather pointless info: %f %f", resolution.width, resolution.height);
	double real_resolution = resolution.width;
	double width_px = widthHeight.width;
	double height_px = widthHeight.height;	
	double width = width_px / real_resolution;
	double height = height_px / real_resolution;
	double aspect_ratio = width/height;
	
    [outputWidth setDoubleValue:width];
    [outputHeight setDoubleValue:height];
	[outputWidthPx setDoubleValue:width_px];
    [outputHeightPx setDoubleValue:height_px];
    [outputResolution setDoubleValue: real_resolution];
    [outputAspectRatio setDoubleValue: aspect_ratio];
	
	return YES;
}

- (void)cleanup:(id)p
{
}

@end