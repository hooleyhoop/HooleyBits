//
//  AppControl.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AppControl.h"
#import "PBView.h"
#import "FloorGrid.h"
#import "PB3DView.h"
#import "PBCamera.h"

/*
 *
*/
@implementation AppControl

#pragma mark -
#pragma mark class methods

#pragma mark init methods
- (id)init {

	self = [super init];
	if(self) 
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	}
	return self;
}

- (void)dealloc {

	[super dealloc];
}

- (void)awakeFromNib
{
		if (!NSClassFromString(@"FScriptMenuItem"))	
		{ // Check that it's not already loaded
			NSString* fscriptPath = @"/Library/Frameworks/FScript.framework";
			BOOL loadFScript = NO;
			if ([[NSFileManager defaultManager] fileExistsAtPath:fscriptPath])
				loadFScript = YES;
			else {
				fscriptPath = [@"~/Library/Frameworks/FScript.framework" stringByExpandingTildeInPath];
				if ([[NSFileManager defaultManager] fileExistsAtPath:fscriptPath])
					loadFScript = YES;
			}
			if (loadFScript) {
				[[NSBundle bundleWithPath:fscriptPath] load];
				[[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];
			} else
				NSLog(@"Couldn't find FScript");	
		}
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:NSApp];

	// the grid is a hypothetical grid that we are allways in the centre of..
	// as the camera moves it makes new tiles infront of us and desroys
	// those behind us
	floorGrid = [[FloorGrid alloc] init];
	[pbView setFloorGrid: floorGrid];
	[pb3dView setFloorGrid: floorGrid];
	[pbView start:nil];
	[pb3dView start:nil];
}


#pragma mark action methods
- (IBAction)step:(id)sender
{
	[pb3dView inceraseCurrentTime:1/25.0];
}

#pragma mark accessor methods
- (PBView *)pbView {
	return pbView;
}
- (void)setPbView:(PBView *)value
{
	if(pbView!=value){
		[pbView release];
		pbView = [value retain];
	}
}

- (PB3DView *)pb3dView {
	return pb3dView;
}

- (void)setPb3dView:(PB3DView *)value
{
	if(pb3dView!=value){
		[pb3dView release];
		pb3dView = [value retain];
	}
}

- (NSNumber *)cameraX {

	PBCamera* camera = [pb3dView camera];
	if(camera)
		return [NSNumber numberWithFloat:[camera pos].cartesian.x];
	else return [NSNumber numberWithInt:-1];
}

- (NSNumber *)cameraY { 
	PBCamera* camera = [pb3dView camera];
	if(camera)
		return [NSNumber numberWithFloat:[camera pos].cartesian.y];
	else return [NSNumber numberWithInt:-1];	
}

- (NSNumber *)cameraZ {
	PBCamera* camera = [pb3dView camera];
	if(camera)
		return [NSNumber numberWithFloat:[camera pos].cartesian.z];
	else return [NSNumber numberWithInt:-1];
}

- (void)setCameraX:(NSNumber *)value {
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setPosX:[value floatValue] Y:pos.cartesian.y Z:pos.cartesian.z ];
	}
}

- (void)setCameraY:(NSNumber *)value { 
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setPosX:pos.cartesian.x Y:[value floatValue] Z:pos.cartesian.z ];
	}
}
- (void)setCameraZ:(NSNumber *)value {
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setPosX:pos.cartesian.x Y:pos.cartesian.y Z:[value floatValue] ];
	}
}

- (NSNumber *)lookAtX {
	PBCamera* camera = [pb3dView camera];
	if(camera)
			return [NSNumber numberWithFloat:[camera lookAt].cartesian.x];
	else return [NSNumber numberWithInt:-1];
}

- (NSNumber *)lookAtY {
	PBCamera* camera = [pb3dView camera];
	if(camera)
		return [NSNumber numberWithFloat:[camera lookAt].cartesian.y];
	else return [NSNumber numberWithInt:-1];
}

- (NSNumber *)lookAtZ {
	PBCamera* camera = [pb3dView camera];
	if(camera)
		return [NSNumber numberWithFloat:[camera lookAt].cartesian.z];
	else return [NSNumber numberWithInt:-1];
}

- (void)setLookAtX:(NSNumber *)value {
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setLookAtX:[value floatValue] Y:pos.cartesian.y Z:pos.cartesian.z ];
	}
}

- (void)setLookAtY:(NSNumber *)value {
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setLookAtX:pos.cartesian.x Y:[value floatValue] Z:pos.cartesian.z ];
	}
}

- (void)setLookAtZ:(NSNumber *)value {
	PBCamera* camera = [pb3dView camera];
	if(camera){
		C3DTVector pos = [camera pos];
		[camera setLookAtX:pos.cartesian.x Y:pos.cartesian.y Z:[value floatValue] ];
	}
}
@end
