//
//  SHNamedMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class SHMemoryBlock;

@interface SHNamedMemoryBlock : SHMemoryBlock {

	NSString		*_name;
}

@property (readonly) NSString	*name;

- (id)initWithName:(NSString *)name start:(char *)memAddr length:(uint64)len;

@end
