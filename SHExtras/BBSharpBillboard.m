//
//  BBSharpBillboard.m
//  BBExtras
//
//  Created by Jonathan del Strother on 06/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "BBSharpBillboard.h"

@implementation BBSharpBillboard

- (id)setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	[self setPixelAligned:YES];
	return fp8;
}

@end
