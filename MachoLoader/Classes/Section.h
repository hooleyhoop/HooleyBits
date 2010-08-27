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
	NSUInteger		_sect_pointer;
}

@property (readonly) NSString	*segmentName;
@property (readonly) NSUInteger	sect_pointer;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len fileAddr:(NSUInteger)fa;
- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(NSUInteger)memAddr length:(NSUInteger)len fileAddr:(NSUInteger)fa;

@end
