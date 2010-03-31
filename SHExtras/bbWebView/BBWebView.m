//
//  BBWebView.m
//  SHExtras
//
//  Created by Steven Hooley on 11/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBWebView.h"


@implementation BBWebView


- (id)initWithFrame:(NSRect)frame frameName:(NSString*)frameName groupName:(NSString*)groupName{
    self = [super initWithFrame:frame frameName:frameName groupName:groupName ];
    if (self) {
		[self setDrawsBackground:NO];
    }
    return self;
}

- (BOOL) isOpaque{
	return YES;
}

@end
