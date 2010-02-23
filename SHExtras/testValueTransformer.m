//
//  testValueTransformer.m
//  SHExtras
//
//  Created by Steven Hooley on 10/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "testValueTransformer.h"
#import "QCClasses.h"
#import "ClassDeconstruction.h"

@implementation testValueTransformer

// ===========================================================
// - transformedValueClass:
// ===========================================================
+ (Class)transformedValueClass
{
    return [NSString class];
}

// ===========================================================
// - allowsReverseTransformation:
// ===========================================================
+ (BOOL)allowsReverseTransformation
{
    return YES;
}

// ===========================================================
// - transformedValue:
// ===========================================================
- (id)transformedValue:(id)aValue
{
	NSDictionary* usrInfo = [aValue userInfo];
	// NSArray* allKeys = [usrInfo allKeys];
	// NSLog(@"all keys is %@", allKeys);
	
	NSString* name = [usrInfo objectForKey:@"name"];
	if(name){
		return name;
	} else if([aValue respondsToSelector:@selector(identifier)])
	{
//		NSLog(@"testValueTransformer: aValue is %@", [aValue identifier]);
		if([aValue identifier])
			return [aValue identifier];
		else {
			NSString* description = [NSObject describeObject:[[[[aValue class] superclass]superclass]superclass] classObject:YES];
			//NSString* description = [(QCPatch*)aValue describeSelf];
			// NSLog(@"key is %@", [aValue userInfo]);
	//		NSLog(@"key is %@",description);
	//		key
	//		userInfo
	//		identifier
		}
	} 
	return @"macro patch";
}

// ===========================================================
// - reverseTransformedValue:
// ===========================================================
- (id)reverseTransformedValue:(id)value
{
	NSLog(@"testValueTransformer.m: tring to reverse the transformation for %@", [value description] );
	return value;
}

@end
