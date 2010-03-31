/*
 *  KeyboardProtocol.h
 *  iphonePlay
 *
 *  Created by steve hooley on 18/02/2009.
 *  Copyright 2009 BestBefore Ltd. All rights reserved.
 *
 */
@protocol KeyboardProtocol

- (BOOL)pressedKey:(NSUInteger)keyIndex;
- (void)releasedKey:(NSUInteger)keyIndex;

- (int)keyCount;

- (NSString *)nameOfKey:(NSUInteger)keyIndex;

@end

