//
//  Section.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "SHMemoryBlock.h"

@interface Section : SHMemoryBlock {

	NSString		*_segName;
}

@property (readonly) NSString	*segmentName;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len;
- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len;

@end
