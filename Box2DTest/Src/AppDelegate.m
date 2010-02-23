//
//  AppDelegate.m
//  Box2DTest
//
//  Created by Steven Hooley on 4/20/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "AppDelegate.h"
#import "Box2dWrapper.h"

@implementation AppDelegate


- (void)awakeFromNib {
	 _box2dWrapper = [[Box2dWrapper alloc] init];
}

@end
