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
	uint64		_sect_pointer;
}

@property (readonly) NSString	*segmentName;
@property (readonly) uint64	sect_pointer;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(uint64)memAddr length:(uint64)len fileAddr:(uint64)fa;
- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(uint64)memAddr length:(uint64)len fileAddr:(uint64)fa;

@end
