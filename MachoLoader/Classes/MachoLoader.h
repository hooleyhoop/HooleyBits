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

@class MemoryMap, SymbolicInfo;
@class IntKeyDictionary;

// How to install libiberty
//> port variants binutils
//> sudo port install binutils +universal


@interface MachoLoader : NSObject {

	struct load_command *_startOfLoadCommandsPtr;
	NSUInteger			_sizeofcmds;
	NSUInteger			_ncmds;
	NSMutableArray		*_loadCommandsArray;
	const void			*_codeAddr;
	size_t				_codeSize;
	cpu_type_t			_cputype;
	
	NSMutableDictionary *addresses_;    // Addresses and symbols (STRONG)
	
	// Symbol table
	struct nlist		*_symtable_ptr;
	struct nlist_64		*_UNUSED_symbols64;
	NSUInteger			_nsymbols;
	NSUInteger			_strings_size;
	
	char				*_strtable;
	
	// Indirect Symbol Table
	NSUInteger			_nindirect_symbols;
	const uint32_t*		_indirectSymbolTable;
	
	IntKeyDictionary	*_indirectSymbolLookup, *_cStringLookup;
	
	MemoryMap			*_memoryMap;
	MemoryMap			*_uncodedMemoryMap;

	BOOL				_MH_TWOLEVEL, _MH_FORCE_FLAT;
	NSMutableArray		*_libraries;
}

- (id)initWithPath:(NSString *)aPath;

- (SymbolicInfo *)symbolicInfoForAddress:(NSUInteger)memAddr;

- (BOOL)processSymbolItem:(struct nlist_64 *)list stringTable:(char *)table;

- (NSString *)lookupLibrary:(NSUInteger)libraryIndex;
- (void)addCstring:(NSString *)aCstring forAddress:(NSUInteger)cStringAddress;
- (NSString *)CStringForAddress:(NSUInteger)addr;

@end
