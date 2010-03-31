//
//  Notifier.m
//  BBExtras
//
//  Created by Jonathan del Strother on 12/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "Notifier.h"

static Notifier* sharedNotifier = nil;

@implementation Notifier

+ (id)defaultCenter
{
//	NSLog(@"///");
	if (!sharedNotifier)
	{
		sharedNotifier = [[Notifier alloc] init];
	}
	return sharedNotifier;
	
}

//- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
//{
//	NSLog(@"%@->%@ is observing %@ for %@", observer, NSStringFromSelector(aSelector), aName, anObject);
//	[super addObserver:observer selector:aSelector name:aName object:anObject];
//}
//
//@class QCNumberPort;
//-(void)postNotificationName:(NSString *)notificationName object:(id)anObject userInfo:(NSDictionary *)userInfo
//{
//	if ([anObject isKindOfClass:[QCNumberPort class]])
//		NSLog(@"Posting %@ about %@ with %@", notificationName, anObject, userInfo);
//	[super postNotificationName:notificationName object:anObject userInfo:userInfo];	
//}

@end
