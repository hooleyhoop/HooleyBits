//
//  SHPhotoshopImportUI.m
//  SHExtras
//
//  Created by Steven Hooley on 20/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHPhotoshopImportUI.h"
#import "SHPhotoshopFileStuff.h"
#include <Carbon/Carbon.h>
#include <Quicktime/Quicktime.h>

/*
 *
*/
@implementation SHPhotoshopImportUI

//=========================================================== 
// + viewNibName
//=========================================================== 
+ (id) viewNibName {
	return @"SHPhotoshopImportUI";
}

//=========================================================== 
// - addOutputPort
//=========================================================== 
//- (void) addOutputPort:(id)fp8 {
//	[[self patch] addOutputPort];
//}

//=========================================================== 
// - removeOutputPort
//=========================================================== 
//- (void) removeOutputPort:(id)fp8 {
//	[[self patch] removeOutputPort];
//}

//=========================================================== 
// - openImage
//=========================================================== 
- (IBAction) openImage:(id)fp8 
{
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    NSString *    extensions = @"tiff/tif/TIFF/TIF/jpg/jpeg/JPG/JPEG/PSD/psd";
    NSArray *     types = [extensions pathComponents];
	[openPanel beginSheetForDirectory: NULL
                                 file: NULL
                                types: types
                       modalForWindow: [[self view]window]
                        modalDelegate: self
                       didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: NULL];
}

//=========================================================== 
// - openPanelDidEnd: returnCode: contextInfo:
//=========================================================== 
- (void)openPanelDidEnd: (NSOpenPanel*)panel returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    if (returnCode == NSOKButton)
    {
        // user did select an image...
		// [SHPhotoshopFileStuff openImageURL:[[panel URLs] objectAtIndex: 0]];
		NSLog(@"SHPhotoshopImportUI: openPanelDidEnd");
		[[self patch] setURL:[[panel URLs] objectAtIndex: 0]];
    }
}

//=========================================================== 
// - setImageViewContent
//=========================================================== 
-(void) setImageViewContent:(NSImage*)anImage
{
	[_theInspectorImageView setImage:anImage];
}

 
//=========================================================== 
// - theInspectorImageView
//=========================================================== 
- (QCFileImageView *)theInspectorImageView {
    return [[_theInspectorImageView retain] autorelease];
}

- (void)setTheInspectorImageView:(QCFileImageView *)value {
    if (_theInspectorImageView != value) {
        [_theInspectorImageView release];
		[value retain];
        _theInspectorImageView = value;
    }
}



@end
