//
//  BBPythonPatchUI.h
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@class BBPythonTextEditor;

/*
 *
*/
@interface BBPythonPatchUI : QCInspector {

    IBOutlet BBPythonTextEditor	*textview;
}

- (IBAction)addInputPort:(id)fp8;
- (IBAction)removeInputPort:(id)fp8;

- (IBAction)addOutputPort:(id)fp8;
- (IBAction)removeOutputPort:(id)fp8;

- (IBAction)execute:(id)fp8;

- (NSString *)scriptProxy;
- (void)setScriptProxy:(NSString *)value;

@end
