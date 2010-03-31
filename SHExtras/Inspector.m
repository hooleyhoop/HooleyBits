//
//  Inspector.m
//  BBExtras
//
//  Created by Jonathan del Strother on 03/08/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "Inspector.h"


@implementation BBInspector

+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 3;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return NO;
}

- (BOOL)execute:(QCOpenGLContext*)context time:(double)fp12 arguments:(id)fp20
{
	NSLog(@"%@: %@", [inputName value], [[inputObject value] description]);	
	[outputObject setImageValue:[inputObject imageValue]];
	return YES;
}

@end
