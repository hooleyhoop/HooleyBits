//
//  SHNumberPort
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNumberPort.h"
#import "SHGlobalVarManager.h"


//static NSMutableDictionary *globalNumbers;
// static BOOL	_isDirty;

@implementation SHNumberPort

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	[super initialize];
}

#pragma mark init methods
//=========================================================== 
// - initWithNode:
//=========================================================== 
- (id) initWithNode:(id)fp8 arguments:(id)fp12
{
    if (self = [super initWithNode:fp8 arguments:fp12]) {
		// BBLog(@"SHNumberPort.. initWithNode");
		_key = @"default";
		SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];
		[varManager addPort:self withKey:_key];
    } else {
		// BBLog(@"SHNumberPort.. i didnt think this ever happened...");
	}
    return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [_key release];
	
    _key = nil;
    [super dealloc];
}

//=========================================================== 
// - portWillDeleteFromNode 
//=========================================================== 
- (void) portWillDeleteFromNode
{
	// BBLog(@"SHNumberPort.. portWillDeleteFromNode");
	SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];
	[varManager removePort:self];
	[super portWillDeleteFromNode];
}

#pragma mark accessor methods
//=========================================================== 
// - key 
//=========================================================== 
- (NSString *) key { return _key; }
- (void) setKey:(NSString *)aKey
{	
    if (_key != aKey) {
        [aKey retain];
		[[SHGlobalVarManager defaultManager] changeKeyTo:aKey forPort:self];
        [_key release];
        _key = aKey;
    }
}

//=========================================================== 
// - doubleValue 
//=========================================================== 
//- (double) doubleValue
//{
//	SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];
//	return [varManager valueForKey:_key];
//}

//=========================================================== 
// - setDoubleValue 
//=========================================================== 
- (void)setDoubleValue:(double)fp8
{
	SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];
	[varManager setValue:fp8 forKey:_key];
	//BBLog(@"SHNumberPort.. setting custom double value, %f", (float)fp8);
}

//=========================================================== 
// - updateDoubleValue 
//=========================================================== 
- (void)updateDoubleValue:(double)fp8
{
	[super setDoubleValue:fp8];
}

@end
