//
//  BBStringRendererUI.m
//  BBExtras
//
//  Created by Jonathan del Strother on 29/08/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "BBStringRendererUI.h"
#import "BBStringRenderer.h"
#import "Logger.h"


@implementation BBStringRendererUI

-(void)setColorEnabled:(id)sender
{
	[(BBTextPlus*)[self patch] setColorEnabled:[sender intValue]];
}
-(void)setHTMLEnabled:(id)sender
{
	[(BBTextPlus*)[self patch] setHTMLEnabled:[sender intValue]];
}


+(id)viewNibName
{
	return @"BBStringRendererUI";
}

-(void)setupViewForPatch:(id)patch
{
	[colorButton setIntValue:[(BBTextPlus*)patch colorEnabled]];
	[htmlButton setIntValue:[(BBTextPlus*)patch htmlEnabled]];
	[super setupViewForPatch:patch];
}

-(BOOL)respondsToSelector:(SEL)selector
{
	NSLog(@"Responds to %@?", NSStringFromSelector(selector));
	return [super respondsToSelector:selector];
}


@end
