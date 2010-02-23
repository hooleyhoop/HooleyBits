//
//  SHAEKeyframeParse_UI.m
//  SHExtras
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHAEKeyframeParseUI.h"


@implementation SHAEKeyframeParseUI


+ (id) viewNibName {
	return @"SHAEKeyframeParseUI";
}

- (void) addOutputPort:(id)fp8 {
	[[self patch] addOutputPort];
}
- (void) removeOutputPort:(id)fp8 {
	[[self patch] removeOutputPort];
}


@end
