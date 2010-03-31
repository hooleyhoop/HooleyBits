//
//  SHGlobalVarManager.h
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//
#ifndef __SHSHGlobalVarManager
#define __SHSHGlobalVarManager

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@class SHNumberPort;

@interface SHGlobalVarManager : NSObject {

	@public
	NSMutableDictionary *_values, *_ports;
}

#pragma mark -
#pragma mark class methods
+ (SHGlobalVarManager*) defaultManager;
+ (void) disposeCachedInstance;

#pragma mark action methods
- (void) addPort:(SHNumberPort*)aPort withKey:(NSString*)aKey;

- (void) removePort:(SHNumberPort*)aPort;

- (void) changeKeyTo:(NSString*)newKey forPort:(SHNumberPort*)aPort;

#pragma mark acessor methods

- (double) valueForKey:(NSString*)aKey;
- (void) setValue:(double)val forKey:(NSString*)aKey;

- (int) numberOfPortsWithKey:(NSString*)aKey;

@end
#endif