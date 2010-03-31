//
//  SHArrayController.m
//  SHExtras
//
//  Created by Steven Hooley on 17/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHArrayController.h"

// NSArrayController 
@implementation SHArrayController



- (id)arrangedObjects
{
	id obs = [super arrangedObjects];
	NSLog(@"!!!!! arranged objects is %@", obs);
	return obs;
}

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key
{
	NSLog(@"WHOOP WHOOP!");
	return nil;
}

- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath
{
	NSLog(@"WHOOP WHOOP!");
	return nil;
}

@end
