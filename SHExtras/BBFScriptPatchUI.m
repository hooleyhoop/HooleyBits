//
//  BBFScriptPatchUI.m
//  SHExtras
//
//  Created by Steven Hooley on 05/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBFScriptPatchUI.h"
#import "BBFScriptPatch.h"

/*
 *
*/
@implementation BBFScriptPatchUI

+ (id)viewNibName
{
	return @"BBFScriptPatchUI";
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



@end
