//
//  MachoLoader.h
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

// TODO: does what i need
// check out this
// http://d.hatena.ne.jp/mteramoto/20070121/p2

// eg, dump cstrings otool -s __TEXT __cstring -v test    


@interface MachoLoader : NSObject {

	NSMutableArray		*_loadCommands;
	const void			*_codeAddr;
	size_t				_codeSize;
	
	NSMutableDictionary *addresses_;    // Addresses and symbols (STRONG)
	
	struct nlist		*symtable_ptr;
	char				*strtable;
}

- (id)initWithPath:(NSString *)aPath;

- (NSString *)sectionForMemAddress:(NSUInteger)addr;

@end
