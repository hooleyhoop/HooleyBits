//
//  CustomApplication.m
//  iphonePlay
//
//  Created by Steven Hooley on 5/31/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "CustomApplication.h"


@implementation CustomApplication

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
	return [super sendAction:action to:target from:sender forEvent:event];
}


- (void)sendEvent:(UIEvent *)event {
	[super sendEvent:event];
}

@end
