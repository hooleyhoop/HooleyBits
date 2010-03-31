//
//  SHPatch.m
//  SHExtras
//
//  Created by Steven Hooley on 17/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHPatch.h"


@implementation QCPatch (SHPatch)

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
	BOOL automatic = NO;
 
    if ([theKey isEqualToString:@"name"]) {
        automatic=YES;
    } else {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

// ===========================================================
// - name:
// ===========================================================
- (NSString*) name
{
	NSLog(@"getting name!!");
	NSDictionary* usrInfo = [self userInfo];
	NSString* name = [usrInfo objectForKey:@"name"];
	if(name){
		return name;
	} else if([self respondsToSelector:@selector(identifier)])
	{
		id identif = [self identifier];
		if(identif)
			return identif;
		else {
			/* we are up shit creak */
			// NSString* description = [NSObject describeObject:[[[[self class] superclass]superclass]superclass] classObject:YES];
		}
	} 
	return @"macro patch";
}


// ===========================================================
// - setName:
// ===========================================================
- (void) setName:(NSString*)aName
{
	NSLog(@"trying to set name! %@", aName);
}

// ===========================================================
// - classAsString:
// ===========================================================
- (NSString*) classAsString {
	return NSStringFromClass([self class]);
}


//=========================================================== 
// isSelected
//=========================================================== 
- (BOOL) isSelected
{
	NSDictionary* usrInfo = [self userInfo];
	NSArray* allKeys = [usrInfo allKeys];
	if([allKeys indexOfObject:@".selected"])
		return NO;
	return YES;
}



@end
