//
//  SHPhotoshopImportUI.h
//  SHExtras
//
//  Created by Steven Hooley on 20/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@interface SHPhotoshopImportUI : QCInspector {

	IBOutlet QCFileImageView	*_theInspectorImageView;
	
}
+ (id)viewNibName;

- (IBAction) openImage:(id)fp8;
- (void)openPanelDidEnd: (NSOpenPanel *)panel returnCode: (int)returnCode contextInfo: (void  *)contextInfo;

-(void) setImageViewContent:(NSImage*)anImage;

- (QCFileImageView *)theInspectorImageView;
- (void)setTheInspectorImageView:(QCFileImageView *)value;


@end
