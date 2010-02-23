//
//  Logger.m
//  BBExtras
//
//  Created by Jonathan del Strother on 07/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "Logger.h"

static Logger* logger = nil;

@class BBPatchLoader;


void BBLog(NSString* message,...)
{
	va_list args;
	va_start(args, message);
	[[Logger sharedLogger] log:message arguments:args];
	va_end(args);
}

@implementation Logger

+ (id)sharedLogger
{
    @synchronized(self) {
        if (logger == nil) {
            logger = [[self alloc] init];
        }
    }
    return logger;
}

-(id)init
{
	@synchronized(self)
	{
		if (logger == nil)
		{
			self = [super init];
			if (self)
			{
				logger = self;
				
				[GrowlApplicationBridge setGrowlDelegate:self];
			}
		}
	}
	
	return logger;
}
	
// -------------- Singleton overrides --------------
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (logger == nil) {
            return [super allocWithZone:zone];
        }
    }
    return logger;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release
{
    //do nothing
}
- (id)autorelease
{
    return self;
}



-(void)log:(NSString*)message arguments:(va_list)args;
{
	NSString* newMessage = [[NSString alloc] initWithFormat:message arguments:args];
	NSLog(newMessage);

	[GrowlApplicationBridge
		notifyWithTitle:@"QC Log"
		description:newMessage
		notificationName:@"QC Log Message"
		iconData:nil
		priority:1
		isSticky:0
		clickContext:nil];
	
	[newMessage release];
}



-(void)logXMLError:(NSString*)error
{
	[GrowlApplicationBridge
		notifyWithTitle:@"Feed Error Occurred"
		description:error
		notificationName:@"XML Feed Error"
		iconData:nil
		priority:1
		isSticky:0
		clickContext:nil];
}

// ----  Growl delegates//

- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray* notifications = [NSArray arrayWithObjects:@"XML Feed Error", @"QC Log Message", nil];
	NSDictionary* registrationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		notifications, GROWL_NOTIFICATIONS_ALL,
		notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
		
	return registrationDictionary;
}

- (NSString *) applicationNameForGrowl
{
	return @"Best Before Extras";
}

@end
