//
//  Keyboard_Simplest.h
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "SoundsSourceProtocol.h"
#import "NoteLookupProtocol.h"
#import "SHooleyObject.h"
#import "KeyboardProtocol.h"

@class TemperedScale, AmplitudeCurve;

@interface Keyboard_Simplest : SHooleyObject <KeyboardProtocol> {

	AmplitudeCurve							*_amplitudeLookup;
	SHooleyObject<SoundsSourceProtocol>	*_connectedSoundSource;
	SHooleyObject<NoteLookupProtocol>		*noteLookup;
	NSMutableIndexSet							*pressedKeys;
	int											offset;
}

@property (readonly) SHooleyObject<SoundsSourceProtocol> *connectedSoundSource;
@property (retain) SHooleyObject<NoteLookupProtocol> *noteLookup;
@property int offset;

- (void)connectOutputTo:(SHooleyObject<SoundsSourceProtocol> *)soundSource;

- (BOOL)pressedKey:(int)keyIndex;
- (void)releasedKey:(int)keyIndex;

- (int)keyCount;

- (NSString *)nameOfKey:(NSUInteger)keyIndex;

- (void)setAmplitudeLookup:(AmplitudeCurve *)alup;

@end