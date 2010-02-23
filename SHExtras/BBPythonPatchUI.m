//
//  BBPythonPatchUI.m
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBPythonPatchUI.h"
#import "BBPythonPatch.h"

/*
 *
*/
@implementation BBPythonPatchUI

+ (id)viewNibName
{
	return @"BBPythonPatchUI";
}

- (void)didLoadNib
{
	[super didLoadNib];
}

- (void)setupViewForPatch:(id)fp8
{
	[super setupViewForPatch:fp8];
	[textview setString:[[self patch] script]];
}

- (IBAction)addInputPort:(id)fp8
{
	[[self patch] addInputPort];
}

- (IBAction)removeInputPort:(id)fp8
{
	[[self patch] removeInputPort];
}

- (IBAction)addOutputPort:(id)fp8
{
	[[self patch] addOutputPort];
}

- (IBAction)removeOutputPort:(id)fp8
{
	[[self patch] removeOutputPort];
}

- (IBAction)execute:(id)fp8
{
	[[self patch] execute];
}

- (NSString *)scriptProxy 
{
	id patch = [self patch];
    return [patch script];
}

- (void)setScriptProxy:(NSString *)value {
    [[self patch] setScript:value];
}


@end
