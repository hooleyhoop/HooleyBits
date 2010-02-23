//
//  SHGlobalVarManager.m
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHGlobalVarManager.h"
#import "SHNumberPort.h"

static SHGlobalVarManager* _manager;
static BOOL flag = NO;
// static SEL updateSEL; //= @selector(didChangeValue);

/*
 * we really need to keep track of how many instances we have
 * with how many different keys!
 */
@implementation SHGlobalVarManager

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	[super initialize];
	// updateSEL = @selector(didChangeValue);
}


//=========================================================== 
// + defaultManager:
//=========================================================== 
+ (SHGlobalVarManager*) defaultManager
{
	if(!flag){
		_manager = [[SHGlobalVarManager alloc] init];
		flag = YES;
	}
	return _manager;
}

//=========================================================== 
// + disposeCachedInstance:
//=========================================================== 
+ (void) disposeCachedInstance
{
	[_manager release];
	_manager = nil;
	flag = NO;
}

#pragma mark init methods
//=========================================================== 
// - init:
//=========================================================== 
- (id)init
{
	if (![super init])
		return nil;
	// BBLog(@"SHGlobalVarManager.. init");
	_values = [[NSMutableDictionary alloc] initWithCapacity:3];
	_ports = [[NSMutableDictionary alloc] initWithCapacity:3];
	return self;
}

//=========================================================== 
// - dealloc:
//=========================================================== 
- (void)dealloc
{
	[_values release];
	[_ports release];
	
	_ports = nil;
	_values = nil;
	[super dealloc];
}

#pragma mark action methods
//=========================================================== 
// - addPort: withKey:
//=========================================================== 
- (void) addPort:(SHNumberPort*)aPort withKey:(NSString*)aKey
{
	NSMutableArray* otherPortsWithThisKey = [_ports objectForKey:aKey];
	// double defaultVal = 0.0;
	if(!otherPortsWithThisKey){
		otherPortsWithThisKey = [NSMutableArray arrayWithCapacity:1];
		[_ports setObject:otherPortsWithThisKey forKey:aKey];
		NSNumber* n = [NSNumber numberWithDouble:[aPort doubleValue]];
		[_values setObject:n forKey:aKey];
	} else {
		double defaultVal = [[_values objectForKey:aKey] doubleValue];
		[aPort updateDoubleValue:defaultVal];
		// BBLog(@"SHGlobalVarManager.. defaultVal is %f", (float)defaultVal);
	}
	[otherPortsWithThisKey addObject:aPort];
}

//=========================================================== 
// - removePort:
//=========================================================== 
- (void) removePort:(SHNumberPort*)aPort
{
	NSString* theKey = [aPort key];
	NSMutableArray* otherNodesWithThisKey = [_ports objectForKey:theKey];
	
	if([otherNodesWithThisKey count]==1){
		[_values removeObjectForKey:theKey];
		[_ports removeObjectForKey:theKey];
	} else {
		[otherNodesWithThisKey removeObject:aPort];
	}
}

//=========================================================== 
// - changeKeyTo: forPort:
//=========================================================== 
- (void) changeKeyTo:(NSString*)newKey forPort:(SHNumberPort*)aPort
{
	// get the value
	//NSString* theKey = [aPort key];
	// double val = [self valueForKey:theKey];
	// remove the port
	[self removePort:aPort];
	// add the port with the old value
	[self addPort:aPort withKey:newKey];
	
	// BBLog(@"SHGlobalVarManager.. changing key. There are now %i with key %@, and %i with newkey %@", [self numberOfPortsWithKey:theKey], theKey, [self numberOfPortsWithKey:newKey], newKey );
}

#pragma mark acessor methods

//=========================================================== 
// - valueForKey:
//=========================================================== 
- (double) valueForKey:(NSString*)aKey
{
	NSNumber* n = [_values objectForKey:aKey];
	if(!n)
		return -9999999; //ERROR!
	return [n doubleValue];
}

//=========================================================== 
// - setValue: forKey:
//=========================================================== 
- (void) setValue:(double)val forKey:(NSString*)aKey
{
	// BBLog(@"SHGlobalVarManager.. setValue to is %f", (float)val);

	NSNumber* n = [NSNumber numberWithDouble:val];
	
	[_values setObject:n forKey:aKey];
	NSMutableArray* portsWithKey = [_ports objectForKey:aKey];
	
	// [nodesWithKey makeObjectsPerformSelector:updateSEL];
	NSEnumerator *enumerator = [portsWithKey objectEnumerator];
	id port;
	while (port = [enumerator nextObject])
	{
		[port updateDoubleValue:val];
		// [port didChangeValue];
	}
}

//=========================================================== 
// - numberOfPortsWithKey:
//=========================================================== 
- (int) numberOfPortsWithKey:(NSString*)aKey
{
	int numberOfPorts;
	NSMutableArray* portsWithKey = [_ports objectForKey:aKey];
	if(portsWithKey)
		numberOfPorts = [portsWithKey count];
	else
		numberOfPorts = 0;
	return numberOfPorts;
}


@end


//if(n && _key){
//	[globalNumbers setObject:n forKey:_key];
// [super setDoubleValue:fp8];// make sure observers are notified , etc. - doh! need to update all!


