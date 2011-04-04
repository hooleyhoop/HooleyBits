//
//  Section.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "SHMemoryBlock.h"

@interface Section : SHNamedMemoryBlock {

	NSString		*_segName;
	char			*_sect_pointer;
}

@property (readonly) NSString	*segmentName;
@property (readonly) char		*sect_pointer;

+ (id)name:(NSString *)secName segment:(NSString *)segName start:(char *)memAddr length:(uint64)len fileAddr:(char *)fa;
- (id)initWithName:(NSString *)name segment:(NSString *)segName start:(char *)memAddr length:(uint64)len fileAddr:(char *)fa;

@end
