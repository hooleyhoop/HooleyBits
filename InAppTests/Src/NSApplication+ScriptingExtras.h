//
//  NSApplication+ScriptingExtras.h
//  InAppTests
//
//  Created by steve hooley on 09/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

@interface NSApplication (NSApplication_ScriptingExtras)


/* kvc method for the 'special version' AppleScript property.
 
 We have defined the 'special version' AppleScript property as read only
 in the scripting definition file so we only provide a getter method here.	
 */
- (NSString*) specialVersion;


/* kvc methods for the 'input value' AppleScript property. */
- (NSNumber*) inputValue;
- (void) setInputValue:(NSNumber*)value;


/* kvc methods for the 'scaling factor' AppleScript property. */
- (NSNumber*) scalingFactor;
- (void) setScalingFactor:(NSNumber*)value;


/* kvc methods for the 'output value' AppleScript property.
 
 We have defined the 'output value' AppleScript property as read only
 in the scripting definition file so we only provide a getter method here.
 
 To illustrate a calculated property value, the 'output value' property
 is calculated as the product of the 'input value' property and
 the 'scaling factor' property.
 */
- (NSNumber*) outputValue;


/* kvc methods for the 'description' AppleScript property. */
- (NSString*) description;
- (void) setDescription:(NSString*)value;


/* kvc methods for the 'ready' AppleScript property. */
- (NSNumber*) ready;
- (void) setReady:(NSNumber*)value;


/* kvc methods for the 'modification date' AppleScript property. */
- (NSDate*) modificationDate;
- (void) setModificationDate:(NSDate*)value;



/* we have defined an enumeration in our scripting definition
 file that we are using as the value stored in the simplicity level
 property.  The actual values passed back from AppleScript to
 Objective-C are encoded using the four byte codes we specified
 in the enumeration.  For convenience, we have associated those
 values with symbolic constants in the following enumeration:
 */
enum {
	kSLBasic = 'SiBa',
	kSLIntroductory = 'SiIn',
	kSLAdvanced = 'SiAd',
	kSLDifficult = 'SiDi'
};

/* and we have defined the following method for converting those
 code values into string values.  */
- (NSString*) decodeSimplicity:(NSNumber*)simplicityCode;


/* kvc methods for the 'simplicity level' AppleScript property.
 
 this property uses the enumeration discussed in the comment above.*/
- (NSNumber*) simplicityLevel;
- (void) setSimplicityLevel:(NSNumber*)value;


/* kvc methods for the 'scaling factor' AppleScript property.
 
 This is another example of a calculated property.  Here we map
 the various simplicity levels defined in the enumeration to
 arbitrary floating point values.  */
- (NSNumber*) simplicityFactor;

@end