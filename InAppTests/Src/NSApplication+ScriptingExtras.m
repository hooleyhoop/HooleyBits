//
//  NSApplication+ScriptingExtras.m
//  InAppTests
//
//  Created by steve hooley on 09/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "NSApplication+ScriptingExtras.h"


@implementation NSApplication (NSApplication_ScriptingExtras)




/* kvc method for the 'special version' AppleScript property.
 
 We have defined the 'special version' string AppleScript property as read only
 in the scripting definition file so we only provide a getter method here.	
 */
- (NSString*) specialVersion {
	NSString *theResult = [NSString stringWithString:@"1.0"];
	NSLog(@"app's special version = %@", theResult);
	return theResult;
}




/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSNumber* gInputValue = nil;


/* kvc methods for the 'input value' integer AppleScript property.  these are 
 implemented in the same way as most getter and setter methods, except
 we do an extra initialization check in the getter method. */
- (NSNumber*) inputValue {
	/* initial value */
	if ( gInputValue == nil ) {
		gInputValue = [[NSNumber alloc] initWithLong: 0];
	}
	NSLog(@"app's input value = %@", gInputValue);
	/* return the input value */
    return [[gInputValue retain] autorelease];
}

- (void) setInputValue:(NSNumber*)value {
	NSLog(@"set app's input value to %@", value);
    if (gInputValue != value) {
        [gInputValue release];
        gInputValue = [value copy];
    }
}




/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSNumber* gScalingFactor = nil;


/* kvc methods for the 'scaling factor' real AppleScript property.  these are 
 implemented in the same way as most getter and setter methods, except
 we do an extra initialization check in the getter method. */
- (NSNumber*) scalingFactor {
	/* initial value */
	if ( gScalingFactor == nil ) {
		gScalingFactor = [[NSNumber alloc] numberWithDouble: 1.0];
	}
	NSLog(@"app's scaling factor = %@", gScalingFactor);
	/* return the scaling factor value */
    return [[gScalingFactor retain] autorelease];
}

- (void) setScalingFactor:(NSNumber*)value {
	NSLog(@"set app's scaling factor to %@", value);
    if (gScalingFactor != value) {
        [gScalingFactor release];
        gScalingFactor = [value copy];
    }
}




/* kvc methods for the 'output value' real AppleScript property.
 
 We have defined the 'output value' AppleScript property as read only
 in the scripting definition file so we only provide a getter method here.
 
 To illustrate a calculated property value, the 'output value' property
 is calculated as the product of the 'input value' property and
 the 'scaling factor' property.
 */
- (NSNumber*) outputValue {
	NSNumber* theResult;
	theResult = [NSNumber numberWithDouble:
				 ([gInputValue doubleValue] * [gScalingFactor doubleValue])];
	NSLog(@"app's output value = %@", theResult);
	return theResult;
}




/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSString* gDescription = nil;


/* kvc methods for the 'description' string AppleScript property.  These are 
 implemented in the same way as most getter and setter methods, except
 we do an extra initialization check in the getter method. */
- (NSString*) description {
	/* initial value */
	if ( gDescription == nil ) {
		gDescription = [[NSString alloc] initWithString: @"no description"];
	}
	NSLog(@"app's description = %@", gDescription);
	/* return the description value */
    return [[gDescription retain] autorelease];
}

- (void) setDescription:(NSString*)value {
	NSLog(@"set app's description to %@", value);
    if (gDescription != value) {
        [gDescription release];
        gDescription = [value copy];
    }
}



/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSNumber* gReady = nil;

/* kvc methods for the 'ready' boolean AppleScript property.  These are 
 implemented in the same way as most getter and setter methods, except
 we do an extra initialization check in the getter method. */
- (NSNumber*) ready {
	/* initial value */
	if ( gReady == nil ) {
		gReady = [[NSNumber alloc] initWithBool: YES];
	}
	NSLog(@"app's ready flag = %@", gReady);
	/* return the simplicity value */
    return [[gReady retain] autorelease];
}

- (void) setReady:(NSNumber*)value {
	NSLog(@"set app's ready flag to %@", value);
    if (gReady != value) {
        [gReady release];
        gReady = [value copy];
    }
}



/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSDate* gModificationDate = nil;

/* kvc methods for the 'modification date' date AppleScript property.
 These are implemented in the same way as most getter and setter
 methods, except we do an extra initialization check in the
 getter method. */
- (NSDate*) modificationDate {
	/* initial value */
	if ( gModificationDate == nil ) {
		gModificationDate = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
	}
	NSLog(@"app's modification date = %@", gModificationDate);
	/* return the modification date */
    return [[gModificationDate retain] autorelease];
}

- (void) setModificationDate:(NSDate*)value {
	NSLog(@"set the modification date");
    if (gModificationDate != value) {
        [gModificationDate release];
        gModificationDate = [value copy];
    }
}




/* The decodeSimplicity method is a utility method for converting
 the four character codes used to represent items in our enumeration
 to string values for easy reading. */

- (NSString*) decodeSimplicity:(NSNumber*)simplicityCode {
	NSString *theResult;
	switch ([simplicityCode longValue]) {
		case kSLBasic: theResult = @"Basic"; break;
		case kSLIntroductory: theResult = @"Introductory"; break;
		case kSLAdvanced: theResult = @"Advanced"; break;
		case kSLDifficult: theResult = @"Difficult"; break;
		default: theResult = @"Unknown"; break;
	}
	return [NSString stringWithString:theResult];
}





/* our application items are implemented as a category of NSApplication so,
 as such, we don't have any instance variables for storing our application
 class' data.  So, we use globals for that storage.  */
NSNumber *gSimplicityLevel = nil;			

/* kvc methods for the 'simplicity level' AppleScript property.
 
 this property uses an AppleScript enumeration defined in our
 scripting definition file.  The interesting thing to note here
 is that there is really nothing special you have to do in order
 to use enumeration values - they are stored in NSNumbers.*/
- (NSNumber*) simplicityLevel {
	/* initial value */
	if ( gSimplicityLevel == nil ) {
		gSimplicityLevel = [[NSNumber alloc] initWithUnsignedLong: kSLBasic];
	}
	NSLog(@"app's simplicity level = %@", [self decodeSimplicity:gSimplicityLevel]);
	/* return the simplicity value */
    return [[gSimplicityLevel retain] autorelease];
}

- (void) setSimplicityLevel:(NSNumber*)value {
	NSLog(@"set app's simplicity level to %@", [self decodeSimplicity:value]);
    if (gSimplicityLevel != value) {
        [gSimplicityLevel release];
        gSimplicityLevel = [value copy];
    }
}



/* kvc methods for the 'scaling factor' AppleScript property.
 
 This is another example of a calculated, read-only property.
 Here we map the various simplicity levels defined in the
 enumeration to arbitrary floating point values.  This method
 illustrates how you can use the constants used by AppleScript
 to represent enumerated values in your Objective-C program. */
- (NSNumber*) simplicityFactor {
	double theFactor;
	NSNumber* theResult;
	switch ([gSimplicityLevel unsignedLongValue]) {
		case kSLBasic: theFactor = 1.2; break;
		case kSLIntroductory: theFactor = 17.3; break;
		case kSLAdvanced: theFactor = 27; break;
		case kSLDifficult: theFactor = 9000; break;
		default: theFactor = 0.0; break;
	}
	theResult = [NSNumber numberWithDouble: theFactor ];
	NSLog(@"app's simplicity factor = %@", theResult);
	return theResult;
}


@end