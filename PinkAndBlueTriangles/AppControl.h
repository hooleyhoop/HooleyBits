//
//  AppControl.h
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBView, PB3DView, FloorGrid;

/*
 *
*/
@interface AppControl : NSObject {

	IBOutlet PBView* pbView;
	IBOutlet PB3DView* pb3dView;
	
	FloorGrid* floorGrid;
}

- (IBAction)step:(id)sender;

- (PBView *)pbView;
- (void)setPbView:(PBView *)value;

- (PB3DView *)pb3dView;
- (void)setPb3dView:(PB3DView *)value;

- (NSNumber *)cameraX;
- (NSNumber *)cameraY;
- (NSNumber *)cameraZ;
- (void)setCameraX:(NSNumber *)value;
- (void)setCameraY:(NSNumber *)value;
- (void)setCameraZ:(NSNumber *)value;

- (NSNumber *)lookAtX;
- (NSNumber *)lookAtY;
- (NSNumber *)lookAtZ;
- (void)setLookAtX:(NSNumber *)value;
- (void)setLookAtY:(NSNumber *)value;
- (void)setLookAtZ:(NSNumber *)value;

@end
