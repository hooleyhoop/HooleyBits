//
//  classToStringValueTransformer.m
//  SHExtras
//
//  Created by Steven Hooley on 10/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "classToStringValueTransformer.h"
#import "QCClasses.h"

@implementation classToStringValueTransformer


+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
//   NSFont *font = [NSFont fontWithName:aValue size:12];
//	return [font displayName];
//	NSLog(@"testValueTransformer: aValue is %@", [[aValue identifier]class]);
	return NSStringFromClass([aValue class]);
}


@end
