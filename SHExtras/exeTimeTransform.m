//
//  exeTimeTransform.m
//  SHExtras
//
//  Created by Steven Hooley on 10/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "exeTimeTransform.h"
#import "QCClasses.h"

@implementation exeTimeTransform



+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
//   NSFont *font = [NSFont fontWithName:aValue size:12];
//	return [font displayName];
//	NSLog(@"testValueTransformer: aValue is %i", (int)[((QCPatch*)aValue) valueForKeyPath:@"_lastExecutionTime"]);
	NSNumber* lastExecutionTime = [((QCPatch*)aValue) valueForKeyPath:@"_lastExecutionTime"];
	return lastExecutionTime;
}


@end
